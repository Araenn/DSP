clc; clear; close all

N = 512;
frequence_sortie = 48000;

readerCanal1 = dsp.AudioFileReader("Canal1.wav", "SamplesPerFrame", N);
FsCanal1 = readerCanal1.SampleRate;
readerCanal2 = dsp.AudioFileReader("Canal2.wav", "SamplesPerFrame", N);
FsCanal2 = readerCanal2.SampleRate;
readerCanal3 = dsp.AudioFileReader("Canal3.wav", "SamplesPerFrame", N);
FsCanal3 = readerCanal3.SampleRate;

Scope_in1 = timescope("SampleRate", FsCanal1, "YLimits", [-1, 1]);
Spec_in1 = dsp.SpectrumAnalyzer("SampleRate", FsCanal1, "PlotAsTwoSidedSpectrum", false);
Scope_in2 = timescope("SampleRate", FsCanal2, "YLimits", [-1, 1]);
Spec_in2 = dsp.SpectrumAnalyzer("SampleRate", FsCanal2, "PlotAsTwoSidedSpectrum", false);
Scope_in3 = timescope("SampleRate", FsCanal3, "YLimits", [-1, 1]);
Spec_in3 = dsp.SpectrumAnalyzer("SampleRate", FsCanal3, "PlotAsTwoSidedSpectrum", false);

myWriter = dsp.AudioFileWriter("multiplex.wav", "SampleRate", frequence_sortie);


fp1 = 4000/frequence_sortie; %frequence porteuse
fp2 = 12000/frequence_sortie;
fp3 = 16000/frequence_sortie;
a = 0.05; %constante boucle
alpha = 0.01;

fc_fpb = 0.2; %frequence coupure fpb
ordre = 20;
h_fpb = fir1(ordre, 2*fc_fpb/FsCanal1, "low"); %fpb phase lineaire avec frquence coupure numerique

p_old = 0;
cos_sortie = 0;
sin_sortie = 0;
comparateur_phase = zeros(N, 1);
M = frequence_sortie/FsCanal1;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];

filtre_demod = fir1(256, 2*fp1, "low");
[H, w] = freqz(filtre_demod, 1, 1000);
tftd_filtreDemod = abs(H);
f = w/(2*pi)*FsCanal1;

figure(1)
plot(f, tftd_filtreDemod)
grid()
while ~isDone(readerCanal1)
    audio_in = readerCanal1() + readerCanal2() + readerCanal3();
    
    
    signal_demodule = zeros(N*M, 1);
    signal_echant = zeros(N*M, 1);
    signal_echant(1:M:end) = M*audio_in; %sur-echantillonnage
    [signal_echant, state] = filter(h, 1, signal_echant, state);
    
    for n = 1:N*M 
        signal_module =  (signal_echant(n) + alpha) * sin_sortie; %modulation
        %% PLL
        signal_in = signal_module .* cos_sortie; 
        delta = sum(h_fpb.*signal_in); %sortie du filtrage passe-bas
        d = 0; % phase instantanee
        p = p_old + 2*fp1 + d; %increment de phase
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        
        %% demodulation
        signal_demodule(n) = signal_echant(n) .* sin_sortie;
        
    end
    audio_out = signal_demodule - mean(signal_demodule); % met composante continue du signal nulle
    [audio_out, state] = filter(filtre_demod, 1, audio_out, state);
    audio_out = audio_out(1:M:end); % sous echantillonnage
    
    myWriter(audio_out);
    Scope_in1(audio_in);
    Spec_in1(audio_in); %mettre break ici
    Scope_out(audio_out);
    Spec_out(audio_out);
    
    
end


release(Scope_in1);
release(Scope_in2);
release(Scope_in3);

release(Scope_out);
release(Spec_in1);
release(Spec_out);
release(readerCanal1);
release(readerCanal2);
release(readerCanal3);
release(myWriter);