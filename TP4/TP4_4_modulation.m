clc; clear; close all

N = 576;
frequence_sortie = 48000;

readerCanal1 = dsp.AudioFileReader("Canal1.wav", "SamplesPerFrame", N);
readerCanal2 = dsp.AudioFileReader("Canal2.wav", "SamplesPerFrame", N);
readerCanal3 = dsp.AudioFileReader("Canal3.wav", "SamplesPerFrame", N);

Fs = readerCanal1.SampleRate;

fp1 = 4000/frequence_sortie; %frequence porteuse
fp2 = 12000/frequence_sortie;
fp3 = 20000/frequence_sortie;

Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

myWriter = dsp.AudioFileWriter("modulation_canaux.wav", "SampleRate", frequence_sortie);

alpha = 0.01;

p_old1 = 0;
sin_sortie1 = 0;

p_old2 = 0;
sin_sortie2 = 0;

p_old3 = 0;
sin_sortie3 = 0;

p_old = 0;
cos_sortie = 0;
sin_sortie = 0;

M = frequence_sortie/Fs;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(576, 2*fc, "low");
state = [];
state1 = [];
state2 = [];
state3 = [];

while ~isDone(readerCanal1)
    audio_in1 = readerCanal1();
    audio_in2 = readerCanal2();
    audio_in3 = readerCanal3();
    
    signal_module = zeros(N*M, 1);
    
    canal1_echant = zeros(N*M, 1);
    canal1_echant(1:M:end) = M*audio_in1; %sur-echantillonnage
    [canal1_echant, state1] = filter(h, 1, canal1_echant, state1);
    
    canal2_echant = zeros(N*M, 1);
    canal2_echant(1:M:end) = M*audio_in2; %sur-echantillonnage
    [canal2_echant, state2] = filter(h, 1, canal2_echant, state2);
    
    canal3_echant = zeros(N*M, 1);
    canal3_echant(1:M:end) = M*audio_in3; %sur-echantillonnage
    [canal3_echant, state3] = filter(h, 1, canal3_echant, state3);
    
    for n = 1:N*M 
        %% Modulation
        canal1_module =  (canal1_echant(n) + alpha) * sin_sortie1; %modulation
        p1 = p_old1 + 2*fp1; %increment de phase
        sin_sortie1 = sin(pi*p1);
        
        p_old1 = p1;
        
        canal2_module =  (canal2_echant(n) + alpha) * sin_sortie2; %modulation
        p2 = p_old2 + 2*fp2; %increment de phase
        sin_sortie2 = sin(pi*p2);
        
        p_old2 = p2;
        
        canal3_module =  (canal3_echant(n) + alpha) * sin_sortie3; %modulation
        p3 = p_old3 + 2*fp3; %increment de phase
        sin_sortie3 = sin(pi*p3);
        
        p_old3 = p3;
        
        signal_module(n) = canal1_module + canal2_module + canal3_module;
        
        
    end
    audio_out = signal_module;

    
    myWriter(audio_out);
    Scope_in(signal_module);
    Spec_in(signal_module);
    Scope_out(audio_out);
    Spec_out(audio_out);
    
    
end


release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(readerCanal1);
release(readerCanal2);
release(readerCanal3);
release(myWriter);