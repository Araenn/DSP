clc; clear; close all

N = 576;
frequence_sortie = 48000;

readerMultiplex = dsp.AudioFileReader("modulation_canaux.wav", "SamplesPerFrame", N);
Fs = readerMultiplex.SampleRate;

fp1 = 4000/frequence_sortie; %frequence porteuse
fp2 = 12000/frequence_sortie;
fp3 = 20000/frequence_sortie;

choix_canal = menu("Choix du canal à démoduler", "Canal 1", "Canal 2", "Canal 3");
if choix_canal == 1
    fp = fp1; %frequence porteuse
elseif choix_canal == 2
    fp = fp2;
else
    fp = fp3;
end

Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

myWriter = dsp.AudioFileWriter("demodulation_canaux.wav", "SampleRate", frequence_sortie);

p_old = 0;
cos_sortie = 0;
sin_sortie = 0;

M = frequence_sortie/Fs;
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

state = [];

filtre_demod = fir1(256, 2*fp, "low");
[H, w] = freqz(filtre_demod, 1, 4000);
tftd_filtreDemod = abs(H);
f = w/(2*pi)*frequence_sortie;

figure(1)
plot(f, tftd_filtreDemod)
grid()
while ~isDone(readerMultiplex)
    audio_in = readerMultiplex();
    
    signal_demodule = zeros(N*M, 1);    
    
    for n = 1:N*M 
        %% PLL        
        signal_in = audio_in(n) .* cos_sortie; 
        p = p_old + 2*fp;
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        
        p_old = p;
        
        %% demodulation
        signal_demodule(n) = audio_in(n) .* sin_sortie;
        
    end
    audio_out = signal_demodule - mean(signal_demodule); % met composante continue du signal nulle
    [audio_out, state] = filter(filtre_demod, 1, audio_out, state);
    audio_out = audio_out(1:M:end);
    
    myWriter(audio_out);
    Scope_in(audio_in);
    Spec_in(audio_in);
    Scope_out(audio_out);
    Spec_out(audio_out);    
    
end


release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(readerMultiplex);
release(myWriter);