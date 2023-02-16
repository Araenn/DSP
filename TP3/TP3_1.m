clc; clear; close all

N = 512;
myReader = dsp.AudioFileReader("Suzanne_Vega_44_mono.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate;
%myWriter = dsp.AudioFileWriter("myOutput.wav", "SampleRate", Fs);
myScope = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
mySpec = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);

t_M = 1e-3; %s
t_D = 100e-3;
a_M = 1 - exp(-2.2/(t_M * Fs));
a_D = exp(-2.2/(t_M * Fs));

lv_old = 0;
f = waitbar(lv_old, "Debut")
pause(0.5)
while ~isDone(myReader)
    audio_in = myReader();
    
    for i = 1:N
        z = max(abs(audio_in(i)) - lv_old, 0) ;
        lv(i) = a_M * z + a_D * lv_old ;
        lv_old = lv(i);        
    end
    waitbar(mean(lv)^(1/4), f, "Level")
    pause(0.01)
    myScope([audio_in lv'])
    mySpec([audio_in lv']) %mettre break ici
    
end

close(f)
release(myScope);
release(mySpec);
release(myReader);
%release(myWriter);