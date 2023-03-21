clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("Meteo_silence.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("traitement_transparent.wav", "SampleRate", Fs);
Scope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

state_precedent_in = zeros(N, 1);
state_precedent_out = zeros(N, 1);
fenetre_ponderation = sin(pi*(1:2*N)/(2*N))';

while ~isDone(myReader)
    audio_in = myReader();
    
    xp = fenetre_ponderation .* [state_precedent_in;audio_in];

    
    Xp = fft(xp);
    state_precedent_in = audio_in;
    
    y = ifft(Xp);
    y = fenetre_ponderation .* y;
    
    audio_out = state_precedent_out + y(1:N);
    state_precedent_out = y(N+1:end);
    
    
    myWriter(audio_out);
    Scope([audio_in audio_out]);
    Spec([audio_in audio_out]); 
    
    
end


release(Scope);
release(Spec);
release(myReader);
release(myWriter);