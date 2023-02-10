clc; clear; close all

N = 512;
K = 1e4;

myReader = audioDeviceReader("SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = audioDeviceWriter("SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fn = Fs; %frequence numerique

r = 0.99;
fr = 1000; %frequence rejecteur
delta = 30; %difference a ajouter pour les frequences variables, delta = 30 efface assez le sinus

p1 = r*exp(2*1j*pi*fr/Fs);
p1c = conj(p1);
p2 = r*exp(2*1j*pi*(fr - delta)/Fs);
p2c = conj(p2);
p3 = r*exp(2*1j*pi*(fr + delta)/Fs);
p3c = conj(p3);

z1 = exp(2*1j*pi*fr/Fs);
z1c = conj(z1);
z2 = exp(2*1j*pi*(fr - delta)/Fs);
z2c = conj(z2);
z3 = exp(2*1j*pi*(fr + delta)/Fs);
z3c = conj(z3);


B = poly([z1, z1c, z2, z2c, z3, z3c]); %calcul des polynomes numerateur et denominateur
A = poly([p1, p1c, p2, p2c, p3, p3c]);

[FR, w] = freqz(B, A, 10000); %reponse en frequence du filtre rejecteur
figure(1)
f = w/(2*pi)*fn;
plot(f, abs(FR.^2))
grid()

state_in = [];
for k = 1:K
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
