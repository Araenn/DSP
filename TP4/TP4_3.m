clc; clear; close all

N = 512;
frequence_sortie = 8000;

myReader = dsp.AudioFileReader("modulation.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("demodulation.wav", "SampleRate", frequence_sortie);
Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000/Fs; %frequence porteuse

fc_fpb = 0.2; %frequence coupure fpb
ordre = 20;
h_fpb = fir1(ordre, 2*fc_fpb/Fs, "low"); %fpb phase lineaire avec frquence coupure numerique

p = 0;
audio_out = zeros(N, 1);

a = 0.05;

M = Fs/frequence_sortie;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];

filtre_demod = fir1(256, 2*fp, "low");
[H, w] = freqz(filtre_demod, 1, 1000);
tftd_filtreDemod = abs(H);
f = w/(2*pi)*Fs;

buffer = zeros(N, 1);

figure(1)
plot(f, tftd_filtreDemod)
grid()

while ~isDone(myReader)
    audio_in = myReader();
    signal_echant = audio_in;
    signal_demodule = zeros(size(audio_in));
    
    for n = 1:length(signal_echant) 
        %% PLL
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        signal_in = signal_echant(n) .* cos_sortie; 
        buffer(1:N-1) = buffer(2:N);
        buffer(n) = signal_in;
        delta = sum(h_fpb.*buffer(n)); %sortie du filtrage passe-bas
        d = a*delta; % phase instantanee
        p = p + 2*fp + d; %increment de phase
        
        %% demodulation
        signal_demodule(n) = signal_echant(n) .* sin_sortie;
        
    end
    [signal_demodule, state] = filter(filtre_demod, 1, signal_demodule, state);
    signal_demodule = signal_demodule - mean(signal_demodule); % met composante continue du signal nulle
    audio_out = signal_demodule(1:M:end);
    
    myWriter(audio_out);
    Scope_in(audio_in);
    Spec_in(audio_in); %mettre break ici
    Scope_out(audio_out);
    Spec_out(audio_out);
    
    
end


release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(myReader);
release(myWriter);