clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("sinusoide_4000_phase_variable.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
%mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

fp = 4000/Fs; %frequence porteuse
a = 0.05; %constante boucle

fc = 0.2; %frequence coupure
ordre = 20;
h = fir1(ordre, 2*fc/Fs, "low"); %fpb phase lineaire avec frquence coupure numerique

p_old = 0;
cos_sortie = 0;
sin_sortie = 0;
comparateur_phase = zeros(N, 1);
audio_out = zeros(N, 1);
while ~isDone(myReader)
    audio_in = myReader();
    signal_module = audio_in;
    
    for n = 1:length(signal_module)        
        %% PLL
        signal_in = signal_module(n) .* cos_sortie; 
        delta = sum(h.*signal_in); %filtrage passe-bas
        %delta = 0;
        d = a * delta; % phase instantanee
        p = p_old + 2*fp + d; %increment de phase
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        audio_out(n) = sin_sortie;
        
    end
    
    myScope([audio_in audio_out]);
    myWriter(audio_out);
    
    
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