clc; clear; close all

N = 512;
K = 1e4;
myReader = dsp.AudioFileReader("Suzanne_Vega_44_mono.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

% myReader = audioDeviceReader("SamplesPerFrame", N);
% Fs = myReader.SampleRate;
% myWriter = audioDeviceWriter("SampleRate", Fs);
% myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
% mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

t_M = 1e-3; %temps de montee
t_D = 100e-3; %temps de descente
a_M = 1 - exp(-2.2/(t_M * Fs));
a_D = exp(-2.2/(t_D * Fs));
Ly = 0.5; %cible du gain en sortie
gmax = 100; %valeur max du gain

lv_old = 0;
f = waitbar(lv_old, "Debut");
pause(0.5);
while ~isDone(myReader)
    audio_in = myReader();
    
    audio_out = zeros(size(audio_in));
    lv = zeros(size(audio_in));
    
    for i = 1:N
        z = max(abs(audio_in(i)) - lv_old, 0) ;
        lv(i) = a_M * z + a_D * lv_old ;
        lv_old = lv(i); 
        ngmax = min( gmax, 1/(max( abs( audio_in(i) ) ) ) ); %double borne du gain
        gain = min(Ly/lv(i), ngmax); %traitement du gain en temps reel
        audio_out(i) = audio_in(i) * gain; 
    end
    
    
    
    waitbar(mean(lv)^(1/4), f, "Level"); %affichage du niveau avec waitbar
    myWriter(audio_out);
    myScope([audio_in lv audio_out]);
    mySpec([audio_in lv audio_out]); %mettre break ici
    
end

close(f)
release(myScope);
release(mySpec);
release(myReader);
release(myWriter);