clc; clear; close all

N = 576;
fe_sortie = 8000;

readerMultiplex = dsp.AudioFileReader("modulation_canaux.wav", "SamplesPerFrame", N);
Fs = readerMultiplex.SampleRate;

nu1 = 4000/Fs; %frequence porteuse
nu2 = 12000/Fs;
nu3 = 20000/Fs;

choix_canal = menu("Choix du canal à démoduler", "Canal 1", "Canal 2", "Canal 3");
if choix_canal == 1
    nu = nu1; %frequence porteuse
    myWriter = dsp.AudioFileWriter("demodulation_canal1.wav", "SampleRate", fe_sortie);
elseif choix_canal == 2
    nu = nu2;
    myWriter = dsp.AudioFileWriter("demodulation_canal2.wav", "SampleRate", fe_sortie);
else
    nu = nu3;
    myWriter = dsp.AudioFileWriter("demodulation_canal3.wav", "SampleRate", fe_sortie);
end

Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);


p = 0;

M = Fs/fe_sortie;
Scope_out = timescope("SampleRate", fe_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", fe_sortie, "PlotAsTwoSidedSpectrum", false);

a = 0.05; %constante boucle

fc_fpb = 0.2; %frequence coupure fpb
ordre = 20;
h_fpb = fir1(ordre, 2*fc_fpb/Fs, "low"); %fpb phase lineaire avec frquence coupure numerique

state = [];

nu_demod = fe_sortie/2/Fs;
filtre_demod = fir1(576, 2*nu_demod, "low"); %toujours 4000 car quand on demodule on decale le signal (shift) vers la gauche
%toujours a 4000, donc on coupe
[H, w] = freqz(filtre_demod, 1, 1000);
tftd_filtreDemod = abs(H);
f = w/(2*pi)*Fs;

figure(1)
plot(f, 20*log10(tftd_filtreDemod))
grid()

buffer = zeros(1,ordre+1);
while ~isDone(readerMultiplex)
    audio_in = readerMultiplex();
    
    signal_demodule = zeros(size(audio_in));  
    
    
    for n = 1:length(audio_in) 
        %% PLL        
        cos_sortie = cos(pi*p); % en sortie d'increment de phase
        sin_sortie = sin(pi*p);
        signal_in = audio_in(n) .* cos_sortie; 
        buffer(1:ordre-1) = buffer(2:ordre);
        buffer(ordre) = signal_in;
        delta = sum(h_fpb.*buffer); %sortie du filtrage passe-bas
        d = 2*a*delta; % phase instantanee*
        p = p + 2*nu + d; %increment de phase
        if p > 1
            p = p - 2;
        end
        
        
        %% demodulation
        signal_demodule(n) =  audio_in(n) .* sin_sortie;
        
    end
    
    [signal_demodule, state] = filter(filtre_demod, 1, signal_demodule, state);
    signal_demodule = signal_demodule - mean(signal_demodule); % met composante continue du signal nulle
    audio_out = signal_demodule(1:M:end);
    
    
    Scope_in(audio_in);
    Spec_in(audio_in);
    Scope_out(signal_demodule);
    Spec_out(signal_demodule);    
    myWriter(audio_out);
    
end


release(Scope_in);
release(Scope_out);
release(Spec_in);
release(Spec_out);
release(readerMultiplex);
release(myWriter);
