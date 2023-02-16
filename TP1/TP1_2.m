clc; clear; close all

N = 512;
K = 1e4;

myReader = audioDeviceReader("SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = audioDeviceWriter("SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

ordre = 256; %ordre du filtre
fn = Fs; %frequence numerique
f1c = 300; %frequence de coupure 1
f1 = f1c/Fs; %frequence de coupure 1 numerique
f2c = 4000;
f2 = f2c/Fs; %idem frequence 2

filtrePasseBande = fir1(ordre, 2.*[f1 f2], "bandpass"); %filtre rif passe-bande
[FPB, w] = freqz(filtrePasseBande, 1, N); %reponse en frequence du filtre
figure(1)
f = w/(2*pi)*fn;
plot(f, abs(FPB.^2))
grid()

state_in = [];
for k = 1:K
    [audio_in, overrun] = myReader();
    [audio_out, state_in] = filter(filtrePasseBande, 1, audio_in, state_in); %traitement
    %disp(overrun)
    myWriter(audio_out);
    myScope([audio_in audio_out])
    mySpec([audio_in audio_out])
end



release(myScope);
release(mySpec);
release(myReader);
release(myWriter);
