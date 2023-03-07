clc; clear; close all

N = 512;
frequence_sortie = 48000;

myReader = dsp.AudioFileReader("Meteo_8k.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("modulation.wav", "SampleRate", frequence_sortie);
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

M = frequence_sortie/Fs;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];
while ~isDone(myReader)
    audio_in = myReader();
    audio_out = zeros(length(audio_in)*M, 1);
    %% sur echantillonnage
    signal_echant = zeros(length(audio_in)*M, 1);
    signal_echant(1:M:end) = audio_in; %sur-echantillonnage
    [signal_echant, state] = filter(h, 1, signal_echant, state);
    
    for n = 1:length(signal_echant)   
        %% modulation
        signal_module = (signal_echant(n) + alpha) * sin(2*pi*fp*n);
        
        %% PLL
        signal_in = signal_module .* cos_sortie; 
        delta = sum(h_fpb.*signal_in); %sortie du filtrage passe-bas
        d = a * delta; % phase instantanee
        p = p_old + 2*fp + d; %increment de phase
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        audio_out(n) = sin_sortie;
        
    end
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