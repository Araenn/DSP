clc; clear; close all

N = 1000;

myReader = dsp.AudioFileReader("Suzanne_Vega_48k.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
frequence_sortie = 8000;
myWriter = dsp.AudioFileWriter("sousEchant.wav", "SampleRate", frequence_sortie);
Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);


M = Fs/frequence_sortie;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

fc = 1/(2*M);
h = fir1(N, 2*fc, "low");
state = [];
while ~isDone(myReader)
    audio_in = myReader();
    [audio_in, state] = filter(h, 1, audio_in, state);
    audio_out = audio_in(1:M:end); %sous-echantillonnage
    
    myWriter(audio_out);
    Scope_in(audio_in)
    Spec_in(audio_in) %mettre break ici
    Scope_out(audio_out)
    Spec_out(audio_out)
end


release(Scope_in);
release(Spec_in);
release(Scope_out);
release(Spec_out);
release(myReader);
release(myWriter);