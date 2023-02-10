clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("Suzanne_Vega_44_mono.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

while ~isDone(myReader)
    audio_in = myReader();
    audio_out = audio_in; %traitement, ici transparent
    myWriter(audio_in);
    myScope([audio_in audio_out])
    mySpec([audio_in audio_out]) %mettre break ici
end



release(myScope);
release(mySpec);
release(myReader);
release(myWriter);
