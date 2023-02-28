clc; clear; close all

N = 512;
myReader = dsp.AudioFileReader("sinusoide_4000_phase_variable.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
%mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

state = [];
fc = 0.2; %frequence coupure numerique
ordre = 20;
h = fir1(ordre, 2*fc, "low");
while ~isDone(myReader)
    audio_in = myReader();
    
    [audio_out, state] = filter(h, 1, audio_in, state);
    
    myWriter(audio_out)
    myScope([audio_in audio_out])
    %mySpec([audio_in audio_out]) %mettre break ici
    
end

figure(1)
[H, w] = freqz(h, 1, N);
tftd = abs(H);
f = w/(2*pi);
plot(f, tftd)
grid()

release(myScope);
%release(mySpec);
release(myReader);
release(myWriter);