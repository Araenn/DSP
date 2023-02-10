clc; clear; close all

N = 512;
K = 1e4;

myReader = dsp.AudioFileReader("Suzanne_Vega_1000Hz.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutputTP1_3.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fn = Fs; %frequence numerique

r = 0.99;
fr = 1000; %frequence rejection 
frn = fr/fn; %frequence rejection numerique
p = r*exp(2*1j*pi*frn);
pc = conj(p);
z = exp(2*1j*pi*frn);
zc = conj(z);

B = poly([z, zc]); %calcul des polynomes numerateur et denominateur
A = poly([p, pc]);

[FR, w] = freqz(B, A, 10000); %reponse en frequence du filtre rejecteur
figure(1)
f = w/(2*pi)*fn;
plot(f, abs(FR.^2))
grid()

state_in = [];
while ~isDone(myReader)
    [audio_in, overrun] = myReader();
    [audio_out, state_in] = filter(B, A, audio_in, state_in);
    %disp(overrun)
    myWriter(audio_out);
    myScope([audio_in audio_out])
    mySpec([audio_in audio_out]) %mettre break ici
end

release(myScope);
release(mySpec);
release(myReader);
release(myWriter);
