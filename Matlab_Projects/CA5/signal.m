%1.1
fs = 50;
t_start = -1;
t_end = 1;
t = t_start:1/fs:t_end;
x1 = cos(10*pi*t);

figure;
subplot(2,1,1);
plot(t, x1);
title('x1(t) in Time Domain');
xlabel('Time (seconds)');
ylabel('Amplitude');
xlim([t_start t_end]);

X1 = fftshift(fft(x1));  
N = length(t);
f = (-fs/2):(fs/N):(fs/2)-(fs/N);

X1_abs = abs(X1)/max(abs(X1));

subplot(2,1,2);
plot(f, X1_abs);
title('Magnitude of x1(t) in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([-fs/2 fs/2]);

%1.2
fs = 100;
t_start = 0;
t_end = 1;
t = t_start:1/fs:t_end;
x2 = cos(30*pi*t + pi/4);

figure;
subplot(3,1,1);
plot(t, x2);
title('x2(t) in Time Domain');
xlabel('Time (seconds)');
ylabel('Amplitude');
xlim([t_start t_end]);

X2 = fftshift(fft(x2));  
N = length(t);
f = (-fs/2):(fs/N):(fs/2)-(fs/N);

X2_abs = abs(X2)/max(abs(X2));

subplot(3,1,2);
plot(f, X2_abs);
title('Magnitude of x2(t) in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([-fs/2 fs/2]);

tol = 1e-6;
X2(abs(X2) < tol) = 0;
theta = angle(X2);

subplot(3,1,3);
plot(f, theta/pi);
title('Phase of x2(t) in Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Phase / \pi');
xlim([-fs/2 fs/2]);
