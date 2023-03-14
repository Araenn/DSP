clc; clear; close all

N = 512;
frequence_sortie = 48000;

myReader = dsp.AudioFileReader("Meteo_8k.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("modulation.wav", "SampleRate", frequence_sortie);
Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000/frequence_sortie; %frequence porteuse
alpha = 0.01;


p_old = 0;
sin_sortie = 0;

M = frequence_sortie/Fs;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];
gmax = 1;
while ~isDone(myReader)
    audio_in = myReader();
    audio_out = zeros(N*M, 1);
    %% sur echantillonnage
    signal_echant = zeros(N*M, 1);
    signal_echant(1:M:end) = M*audio_in; %sur-echantillonnage
    [signal_echant, state] = filter(h, 1, signal_echant, state);
    
    for n = 1:N*M   
        %% modulation
        
        signal_module =  gmax * (signal_echant(n) + alpha) * sin_sortie; %modulation
        
        %% PLL
        p = p_old + 2*fp; %increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        audio_out(n) = signal_module;
        
    end
    Scope_in(audio_in);
    Spec_in(audio_in); %mettre break ici
    Scope_out(audio_out);
    Spec_out(audio_out);
    myWriter(audio_out);

    
end

release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(myReader);
release(myWriter);