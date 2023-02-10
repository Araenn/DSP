clc; clear; close all

alpha = 1;
r = 0.9; %on reste stable
n0 = 0.16;
p = r*exp(2*1j*pi*n0);
pc = conj(p);
zeta = exp(2*1j*pi*n0);
zc = conj(zeta);

u = zeros(64, 1);
u(1:32) = 1;
u(33:64) = -1;
x = u;

P = 20;
for i = 1:P-1
    x = [x;u];
end
N = length(x);
t = (0:N-1)';
x = x + sin(2*pi*n0*t);

k = 500;

figure(1)
plot(t, x)
grid()
title("Signal x")
xlabel("Temps discret")
ylabel("Amplitude")

[X, w] = freqz(x, 1, k);
tftd_x = abs(X);
f = w/(2*pi);

figure(2)
plot(f, tftd_x)
grid()
title("Spectre de x")
xlabel("Frequence numerique")
ylabel("Module")

B = alpha*poly([zeta, zc]);
A = poly([p, pc]);

figure(3)
zplane(B, A)
grid()
title("Diagramme pole et zeros")
xlabel("Partie reelle")
ylabel("Partie imaginaire")

[H, w] = freqz(B, A, k);
tftd_h = abs(H.^2);

figure(4)
plot(f, tftd_h)
grid()
title("Courbe de gain du filtre")
xlabel("Frequence numerique")
ylabel("Module")

v = zeros(100, 1);
v(1) = 1;
n = (0:100-1)';

[V, w] = freqz(v, 1, k);
tftd_x = abs(V.^2);
f = w/(2*pi);

ha = hann(1000+1);
yb = fir1(1000, 2*[0.155;0.165], 'stop', ha);
yb = yb';
y = filter(B, A, v);
[Yb, w] = freqz(yb, 1, k);
tftd_yb = abs(Yb.^2);
ha = hann(N+1);

[Y, w] = freqz(y, 1, k);
tftd_y = abs(Y.^2);

h = filter(v, 1, y);
hb = filter(v, 1, yb);
figure(5)
plot(n, h)
hold on
plot((0:1000)', hb)
grid()
title("Reponse impulsionnelle des filtres AR")
xlabel("Temps discret")
ylabel("Amplitude")
legend("filtre AR", "notch")

l = filter(h, 1, x);
lb = filter(hb, 1, x);
[Lb, w] = freqz(lb, 1, k);
tftd_lb = abs(Lb.^2);
[L, w] = freqz(l, 1, k);
tftd_l = abs(L.^2);

figure(6)
plot(t, l)
hold on
plot(t, lb)
grid()
title("Forme d'onde du signal filtre")
xlabel("Temps discret")
ylabel("Amplitude")
legend("filtre AR", "notch")

figure(7)
plot(f, tftd_l)
hold on
plot(f, tftd_lb)
grid()
title("Spectre du signal filtre")
xlabel("Frequence numerique")
ylabel("Module")
legend("filtre AR", "notch")

figure(4)
hold on
[H, w] = freqz(hb, 1, k);
tftd_h = abs(H.^2);
plot(f, tftd_h)
legend("filtre AR", "notch")

figure(8)
zplane(hb, 1)
title("Diagramme pole et zero notch")
grid()

%pole proche du cercle unite = coupure a cette frequence (0.16), mais pas
%nette car pas sur le cercle (sinon instabilite)
%zero sur le cercle unite = gain 1
%filtre rejecteur car rejette une frequence particuliere (0.16)
%coupe bien frequences > 0.16, mais reste residus legers