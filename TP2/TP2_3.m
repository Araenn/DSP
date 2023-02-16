clc; clear; close all

N = 1000;

myReader = dsp.AudioFileReader("Suzanne_Vega_44k.wav", "SamplesPerFrame", N);
Fs = myReader.SampleRate; %44100
frequence_sortie = 48000;
myWriter = dsp.AudioFileWriter("re_echant.wav", "SampleRate", frequence_sortie);
Scope_in = timescope("SampleRate", Fs, "YLimits", [-1, 1]);
Spec_in = dsp.SpectrumAnalyzer("SampleRate", Fs, "PlotAsTwoSidedSpectrum", false);


P = [8 5 4];
Q = [3 7 7];
Scope_out = timescope("SampleRate", frequence_sortie, "YLimits", [-1, 1]);
Spec_out = dsp.SpectrumAnalyzer("SampleRate", frequence_sortie, "PlotAsTwoSidedSpectrum", false);

state = [];
indice = 1;
while ~isDone(myReader)
    audio_in = myReader();
    for i = 1:length(Q)
        M = max(P(i), Q(i));
        fc = 1/(2*M);
        h = fir1(N, 2.*fc, "low");
        
        audio_out = zeros(length(audio_in)*P(i), 1);
        indice = length((1:audio_out(end)))-P(i); %probleme d'indice
        audio_out(indice:P(i):end) = audio_in; %sur-echantillonnage
        [audio_out, state] = filter(h, 1, audio_out, state); %fpb
        audio_out = audio_out(1:Q(i):end); %sous-echantillonnage
    end
    myWriter(audio_out);
    Scope_in(audio_in)
    Spec_in(audio_in) %mettre break ici
    Scope_out(audio_out)
    Spec_out(audio_out)
end


release(Scope_in);
release(Spec_in);
release(Scope_out);
release(Spec_out);
release(myReader);
release(myWriter);