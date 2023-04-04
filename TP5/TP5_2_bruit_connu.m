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

alpha = 0.4; %constante debruitage
count = 0;
audio_out = zeros(N, 1);
estimation_spectre_bruit = zeros(2*N, 1);
compt = 0;

while ~isDone(myReader)
    audio_in = myReader();
    
    signal_entree_pondere = fenetre_ponderation .* [state_precedent_in; audio_in];
    spectre_entree_pondere = abs(fft(signal_entree_pondere)).^2; %spectre signal bruité
    
    if count <= 2*Fs
        estimation_spectre_bruit = estimation_spectre_bruit + abs(fft(signal_entree_pondere)).^2; %spectre estimé du bruit
        compt = compt + 1;
    elseif count <= 2*Fs+N
        estimation_spectre_bruit = estimation_spectre_bruit ./ compt; %moyenne de l'estimation spectrale du bruit
    else
        
        if mean(spectre_entree_pondere ./ estimation_spectre_bruit') > 1 %si il y a du signal
            if mean(spectre_entree_pondere - estimation_spectre_bruit)/estimation_spectre_bruit > (1 - estimation_spectre_bruit)
                
                module_signal_debruite = max(spectre_entree_pondere - alpha*estimation_spectre_bruit, 0);
                
            else
                estimation_spectre_bruit = mean(abs(fft(signal_entree_pondere)).^2); %recalcul de l'estimation du bruit
            end
        else
            module_signal_debruite = 0;
        end
        
        
        signal_sortie = real(ifft( sqrt(module_signal_debruite) .* exp(1j * angle(fft(signal_entree_pondere))) ));
        signal_sortie_pondere = fenetre_ponderation .* signal_sortie;

        audio_out = state_precedent_out + signal_sortie_pondere(1:N);
        state_precedent_out = signal_sortie_pondere(N+1:end);
        state_precedent_in = audio_in;
        
    end
    
    count = count + N;

    myWriter(audio_out);
    Scope([audio_in audio_out]);
    Spec([audio_in audio_out]); 
    
    
end


release(Scope);
release(Spec);
release(myReader);
release(myWriter);
