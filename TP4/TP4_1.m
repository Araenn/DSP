clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("sinusoide_4000_phase_variable.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
%mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000; %frequence porteuse
a = 0.05; %constante boucle

fc = 0.2; %frequence coupure
ordre = 20;
h = fir1(ordre, 2*fc/Fs, "low"); %fpb phase lineaire avec frquence coupure numerique

state = [];
p_old = 0;
cos_sortie = 0;
while ~isDone(myReader)
    audio_in = myReader();
    signal_module = audio_in;
    comparateur_phase = signal_module .* cos_sortie; 
    [comparateur_phase, state] = filter(h, 1, comparateur_phase, state);

    phi = angle(comparateur_phase); % phase du signal apres comparateur de phase et fpb
    delta = 1/2 * phi; % correction de phase
    d = a * delta; % phase instantanee
    cos_sortie = cos(pi*(p_old + 2*fp + d)); % en sortie d'increment de phase
    p = p_old + 2*fp; %increment de phase

    audio_out =  cos_sortie .* signal_module;
    
    myWriter(audio_out);
    myScope([audio_in audio_out]);
    
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