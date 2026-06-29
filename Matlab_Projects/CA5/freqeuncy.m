T = 1;
fs = 20;
t = 0:1/fs:T-1/fs;
N = length(t);
delta_f = 1/T;

x1 = exp(1j*2*pi*5*t) + exp(1j*2*pi*8*t);
x2 = exp(1j*2*pi*5*t) + exp(1j*2*pi*5.1*t);

X1 = fftshift(fft(x1));   
X2 = fftshift(fft(x2));

f = (-fs/2):(fs/N):(fs/2)-(fs/N);

X1_abs = abs(X1)/max(abs(X1));
X2_abs = abs(X2)/max(abs(X2));

figure;
subplot(2,1,1);
plot(f, X1_abs);
title('Magnitude of X1(t) in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

subplot(2,1,2);
plot(f, X2_abs);
title('Magnitude of X2(t) in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
