clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("sinusoide_4000_phase_variable.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
%mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000; %frequence porteuse
a = 0.05; %constante boucle

fc = 0.02; %frequence coupure numerique
ordre = 20;
h = fir1(ordre, 2*fc, "low"); %fpb phase lineaire

state = [];
p_old = 0;
cos_sortie = 0;
while ~isDone(myReader)
    audio_in = myReader();
    %porteuse = cos(2*pi*fp*(0:length(audio_in)-1)');
    
    signal_module = audio_in ;
    comp = signal_module .* cos_sortie;
    [comp, state] = filter(h, 1, comp, state);
    
    
    
    phi = angle(signal_module);
    delta = 1/2 * phi;
    d = a * delta;
    
    cos_sortie = cos(pi*(p_old + 2*fp + d));
    p = p_old + 2*fp;
    p_old = p;
    
    audio_out = comp;
    
%     signal_synchro = porteuse' .* cos_sortie;
%     audio_out = 2 * signal_synchro .* signal_module;
    
    
    
    
    myWriter(audio_out);
    myScope([audio_in audio_out]);
    %mySpec([audio_in audio_out]); %mettre break ici
    
end

figure(1)
[H, w] = freqz(h, 1, 1000);
tftd = abs(H);
f = w/(2*pi);
plot(f, tftd)
grid()

release(myScope);
%release(mySpec);
release(myReader);
release(myWriter);