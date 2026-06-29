%1.1
clc; clear; close all;

fc = 5;
fs = 100;
tstart = 0;
tend = 1;

Ts = 1/fs;
t = tstart : Ts : (tend - Ts);

x = cos(2*pi*fc*t);

figure;
plot(t, x, 'LineWidth', 1.5);
grid on;
xlabel('t (s)');
ylabel('x(t)');
title('x(t) = cos(2\pi f_c t)');





%1.2
fc = 5;
fs = 100;
tstart = 0;
tend = 1;

alpha = 0.5;
beta = 0.3;
V = 180;
R = 250;

c0 = 3e5;
rho = 2/c0;

fd = beta*V;
td = rho*R;

Ts = 1/fs;
t = tstart:Ts:(tend-Ts);

y = alpha*cos(2*pi*(fc+fd).*(t-td));

figure;
plot(t, y, 'LineWidth', 1.5);
grid on;
xlabel('t (s)');
ylabel('y(t)');
title('y(t) = \alpha cos(2\pi(f_c+f_d)(t-t_d))');






%1.3
fc = 5;
fs = 100;
T  = 1;

alpha = 0.5;
beta  = 0.3;

V0 = 180;
R0 = 250;

c0  = 3e5;
rho = 2/c0;

t  = 0:1/fs:(T-1/fs);
N  = numel(t);

fd0 = beta*V0;
td0 = rho*R0;

y = alpha*cos(2*pi*(fc+fd0).*(t-td0));

Y = fftshift(fft(y));
f = (-N/2:N/2-1)*(fs/N);

pos = find(f > 0);
[~,ii] = max(abs(Y(pos)));
k = pos(ii);
fpk = f(k);

cand = [fpk, fs-fpk];
if abs(cand(1)-cand(2)) < 1e-9
    cand = cand(1);
end

best.err = inf;

for f0 = cand
    C = [cos(2*pi*f0*t(:)) sin(2*pi*f0*t(:))];
    p = C\y(:);
    a = p(1); b = p(2);

    A   = hypot(a,b);
    phi = atan2(-b,a);

    td = mod(-phi/(2*pi*f0), 1/f0);

    yh = A*cos(2*pi*f0*(t-td));
    e  = mean((y - yh).^2);

    if e < best.err
        best.err = e;
        best.f   = f0;
        best.phi = phi;
        best.td  = td;
        best.A   = A;
    end
end

f_new   = best.f;
phi_new = best.phi;
t_d     = best.td;

V_hat = (f_new - fc)/beta;
R_hat = t_d/rho;

fprintf('f_new   = %.6f Hz\n', f_new);
fprintf('phi_new = %.6f rad\n', phi_new);
fprintf('t_d     = %.9f s\n', t_d);
fprintf('V_hat   = %.6f km/h\n', V_hat);
fprintf('R_hat   = %.6f km\n', R_hat);

figure; plot(f, abs(Y)); grid on; xlabel('f (Hz)'); ylabel('|Y|');
figure; plot(f, angle(Y)); grid on; xlabel('f (Hz)'); ylabel('angle(Y)');






%1.4
rng(1);

fc = 5;
fs = 120;
T  = 1;

alpha = 0.5;
beta  = 0.3;

Vtrue = 180;
Rtrue = 250;

c0  = 3e5;
rho = 2/c0;

t = 0:1/fs:(T-1/fs);

fd = beta*Vtrue;
td = rho*Rtrue;

y = alpha*cos(2*pi*(fc+fd).*(t-td));

sigRms = sqrt(mean(y.^2));
sigmaList = sigRms * [0 0.01 0.02 0.04 0.06 0.08 0.10 0.30 0.40 0.60 0.80 1.00 9.00];

out = zeros(numel(sigmaList), 6);

for i = 1:numel(sigmaList)
    sigma = sigmaList(i);

    yN = y + sigma*randn(size(y));

    [Vhat, Rhat, fnew, tdHat] = estVR_noalias(yN, t, fs, fc, beta, rho);

    eV = abs(Vhat - Vtrue)/abs(Vtrue);
    eR = abs(Rhat - Rtrue)/abs(Rtrue);

    out(i,:) = [sigma, Vhat, Rhat, eV, eR, fnew];
end

disp(array2table(out, 'VariableNames', {'sigma','V_hat','R_hat','relErrV','relErrR','f_new'}));

figure; plot(out(:,1), out(:,4), 'o-'); grid on;
xlabel('sigma'); ylabel('relErr(V)');

figure; plot(out(:,1), out(:,5), 'o-'); grid on;
xlabel('sigma'); ylabel('relErr(R)');

function [Vhat, Rhat, fnew, td] = estVR_noalias(y, t, fs, fc, beta, rho)
    N = numel(t);

    Y = fftshift(fft(y));
    f = (-N/2:N/2-1)*(fs/N);

    ip = find(f > 0);
    [~,im] = max(abs(Y(ip)));
    k = ip(im);

    fnew = f(k);
    if fnew < 1e-9
        fnew = 1e-9;
    end

    C = [cos(2*pi*fnew*t(:)) sin(2*pi*fnew*t(:))];
    p = C\y(:);

    a = p(1);
    b = p(2);

    A = hypot(a,b);
    phi = atan2(-b,a);

    td = mod(-phi/(2*pi*fnew), 1/fnew);

    Vhat = (fnew - fc)/beta;
    Rhat = td/rho;
end







%1.5
fc = 5;
fs = 100;
t = 0:1/fs:(1-1/fs);

beta = 0.3;

R1 = 250; V1 = 180; a1 = 0.5;
R2 = 200; V2 = 216; a2 = 0.6;

c0 = 3e5;
rho = 2/c0;

fd1 = beta*V1;
fd2 = beta*V2;

td1 = rho*R1;
td2 = rho*R2;

y = a1*cos(2*pi*(fc+fd1).*(t-td1)) + a2*cos(2*pi*(fc+fd2).*(t-td2));

figure;
plot(t, y, 'LineWidth', 1.5);
grid on;
xlabel('t (s)');
ylabel('y(t)');
title('Received signal: sum of two echoes');







%1.6
rng(1);

fc = 5;
fs = 100;
T  = 1;

beta = 0.3;

c0  = 3e5;
rho = 2/c0;

t = 0:1/fs:(T-1/fs);

R1 = 250; V1 = 180; A1 = 0.5;
R2 = 200; V2 = 216; A2 = 0.6;

fd1 = beta*V1;  td1 = rho*R1;
fd2 = beta*V2;  td2 = rho*R2;

y = A1*cos(2*pi*(fc+fd1).*(t-td1)) + A2*cos(2*pi*(fc+fd2).*(t-td2));

Nfft = 16384;

Y = fft(y, Nfft);
f = (0:Nfft/2)*fs/Nfft;
mag = abs(Y(1:Nfft/2+1));
mag(1) = 0;

pk = find(mag(2:end-1) > mag(1:end-2) & mag(2:end-1) >= mag(3:end)) + 1;
if numel(pk) < 2
    [~,ix] = sort(mag,'descend');
    pk = ix(1:2);
end

[~,ord] = sort(mag(pk),'descend');
pk = pk(ord);

k1 = pk(1);
k2 = pk(find(abs(pk - k1) >= 10, 1, 'first'));
if isempty(k2)
    k2 = pk(2);
end

df = fs/Nfft;

f1obs = quad_refine(f, mag, k1, df);
f2obs = quad_refine(f, mag, k2, df);

C = [cos(2*pi*f1obs*t(:)) sin(2*pi*f1obs*t(:)) cos(2*pi*f2obs*t(:)) sin(2*pi*f2obs*t(:))];
p = C\y(:);

a1 = p(1); b1 = p(2);
a2 = p(3); b2 = p(4);

phi1 = atan2(-b1,a1);
phi2 = atan2(-b2,a2);

[f1, td1h, V1h, R1h] = decode_one(f1obs, phi1, fs, fc, beta, rho);
[f2, td2h, V2h, R2h] = decode_one(f2obs, phi2, fs, fc, beta, rho);

if V2h > V1h
    [f1,f2] = deal(f2,f1);
    [td1h,td2h] = deal(td2h,td1h);
    [V1h,V2h] = deal(V2h,V1h);
    [R1h,R2h] = deal(R2h,R1h);
end

fprintf('Target 1: f=%.4f Hz, td=%.6f s, V=%.3f, R=%.3f\n', f1, td1h, V1h, R1h);
fprintf('Target 2: f=%.4f Hz, td=%.6f s, V=%.3f, R=%.3f\n', f2, td2h, V2h, R2h);

figure; plot(f, mag, 'LineWidth', 1.1); grid on;
xlabel('f (Hz)'); ylabel('|Y|');

figure; plot(t, y, 'LineWidth', 1.1); grid on;
xlabel('t (s)'); ylabel('y(t)');

function f0 = quad_refine(f, mag, k, df)
    if k <= 1 || k >= numel(mag)
        f0 = f(k);
        return;
    end
    m1 = mag(k-1); m0 = mag(k); m2 = mag(k+1);
    den = (m1 - 2*m0 + m2);
    if abs(den) < 1e-12
        d = 0;
    else
        d = 0.5*(m1 - m2)/den;
    end
    f0 = f(k) + d*df;
end

function [ftrue, td, V, R] = decode_one(fobs, phi, fs, fc, beta, rho)
    fA = fobs;
    tdA = mod(-phi/(2*pi*fA), 1/fA);
    VA = (fA - fc)/beta;
    RA = tdA/rho;

    fB = fs - fobs;
    tdB = mod(+phi/(2*pi*fB), 1/fB);
    VB = (fB - fc)/beta;
    RB = tdB/rho;

    if (RB < RA) && (VB > 0)
        ftrue = fB; td = tdB; V = VB; R = RB;
    else
        ftrue = fA; td = tdA; V = VA; R = RA;
    end
end
