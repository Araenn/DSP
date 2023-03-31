clc; clear; close all

N = 512;

myReader = dsp.AudioFileReader("Meteo_bruit.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("traitement_bruit_connu.wav", "SampleRate", Fs);
Scope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

state_precedent_in = zeros(N, 1);
state_precedent_out = zeros(N, 1);
fenetre_ponderation = sin(pi*(1:2*N)/(2*N))';

alpha = 1; %constante debruitage
count = 0;

while ~isDone(myReader)
    audio_in = myReader();
    
    signal_entree_pondere = fenetre_ponderation .* [state_precedent_in; audio_in];
    spectre_entree_pondere = fft(signal_entree_pondere); %spectre signal bruité
    
    if count == 0
        for k = 1:2*Fs/N %pour 2s de bruit
           estimation_spectre_bruit = mean(abs(fft(audio_in).^2)); %spectre estimé du bruit
        end
        count = 1;
    else
        signal_debruite = max(spectre_entree_pondere - alpha*estimation_spectre_bruit, 0); %signal debruité

        signal_sortie = ifft(signal_debruite);
        signal_sortie_pondere = fenetre_ponderation .* signal_sortie;

        audio_out = state_precedent_out + signal_sortie_pondere(1:N);
        state_precedent_out = signal_sortie_pondere(N+1:end);
        state_precedent_in = audio_in;

        myWriter(audio_out);
        Scope([audio_in audio_out]);
        Spec([audio_in audio_out]); 
    end
    
    
    
end


release(Scope);
release(Spec);
release(myReader);
release(myWriter);