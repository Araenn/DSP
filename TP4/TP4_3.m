clc; clear; close all

N = 512;
frequence_sortie = 8000;

myReader = dsp.AudioFileReader("modulation.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("demodulation.wav", "SampleRate", frequence_sortie);
Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000/Fs; %frequence porteuse
a = 0.05; %constante boucle
alpha = 0.01;

fc_fpb = 0.2; %frequence coupure fpb
ordre = 20;
h_fpb = fir1(ordre, 2*fc_fpb/Fs, "low"); %fpb phase lineaire avec frquence coupure numerique

p_old = 0;
cos_sortie = 0;
sin_sortie = 0;
comparateur_phase = zeros(N, 1);
audio_out = zeros(N, 1);

M = Fs/frequence_sortie;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];
state2 = [];

filtre_demod = fir1(256, 2*fp, "low");
[H, w] = freqz(filtre_demod, 1, 1000);
tftd_filtreDemod = abs(H);
f = w/(2*pi)*Fs;

figure(1)
plot(f, tftd_filtreDemod)
grid()

while ~isDone(myReader)
    audio_in = myReader();
    signal_echant = audio_in;
    
    for n = 1:length(signal_echant)           
        %% PLL
        signal_in = signal_echant(n) .* cos_sortie; 
        delta = sum(h_fpb.*signal_in); %sortie du filtrage passe-bas
        d = a * delta; % phase instantanee
        p = p_old + 2*fp + d; %increment de phase
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        
        %% demodulation
        signal_demodule = signal_echant(n) .* sin_sortie;
        audio_out(n) = signal_demodule;
        
    end
    audio_out = audio_out - mean(audio_out);
    [audio_out, state2] = filter(filtre_demod, 1, audio_out, state2);
    audio_out = audio_out(1:M:end);
    
    myWriter(audio_out);
    Scope_in(audio_in)
    Spec_in(audio_in) %mettre break ici
    Scope_out(audio_out)
    Spec_out(audio_out)
    
    
end


release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(myReader);
release(myWriter);