clc; clear; close all

N = 512;
K = 1e4;

myReader = audioDeviceReader("SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = audioDeviceWriter("SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

for k = 1:K
    [audio_in, overrun] = myReader();
    audio_out = audio_in; %traitement, ici transparent
    %disp(overrun)
    myWriter(audio_in);
    myScope([audio_in audio_out])
    mySpec([audio_in audio_out]) %mettre break ici
end



release(myScope);
release(mySpec);
release(myReader);
release(myWriter);
