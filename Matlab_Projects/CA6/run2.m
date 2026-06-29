%2.1

clc; clear; close all;

fs  = 8000;
tau = 0.025;

freq = containers.Map( ...
    {'D','E','F#','G'}, ...
    [293.6648, 329.6276, 369.9944, 391.9954] );

notes = { ...
    'D' 'D' 'G' 'F#' 'D' 'D' 'E' 'E' 'D' 'F#' 'D' ...
    'E' 'D' 'E' 'F#' 'E' 'D' 'E' 'E' 'D' 'F#' 'D' ...
    'E' 'D' 'E' 'D' 'F#' 'E' 'D' 'E' 'D' 'F#' 'E' ...
    'D' 'D' 'E' 'F#' 'E' 'F#' 'F#' 'E' 'F#' 'F#' 'D' ...
};

durs = [ ...
    0.25 0.25 0.50 0.50 0.50 0.25 0.25 0.25 0.25 0.25 0.25 ...
    0.50 0.50 0.50 0.50 0.50 0.25 0.25 0.25 0.25 0.25 0.25 ...
    0.50 0.50 0.25 0.25 0.50 0.50 0.50 0.25 0.25 0.50 0.50 ...
    0.25 0.25 0.50 0.25 0.25 0.50 0.25 0.25 0.50 0.50 0.50 ...
];

gap  = zeros(1, round(tau*fs));
fade = round(0.005*fs);

x = [];

for i = 1:numel(notes)
    f0  = freq(notes{i});
    dur = durs(i);

    t = 0:1/fs:(dur-1/fs);
    s = 0.8*sin(2*pi*f0*t);

    if fade > 1 && numel(s) > 2*fade
        w = ones(size(s));
        w(1:fade) = linspace(0,1,fade);
        w(end-fade+1:end) = linspace(1,0,fade);
        s = s .* w;
    end

    x = [x s gap];
end

sound(x, fs);





%2.2
fs  = 8000;
T   = 0.5;
tau = 0.025;

names = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
freqs = [261.6256 277.1826 293.6648 311.1270 329.6276 349.2282 369.9944 391.9954 415.3047 440.0000 466.1638 493.8833];

getf = @(s) freqs(strcmp(names,s));

notes = {'C','C','G','G','A','A','G','F','F','E','E','D','D','C'};
durs  = [T,  T,  T,  T,  T,  T,  T,  T,  T,  T,  T,  T,  T,  T];

gap  = zeros(1, round(tau*fs));
fade = round(0.005*fs);

x = [];

for i = 1:numel(notes)
    f0  = getf(notes{i});
    dur = durs(i);

    tt = 0:1/fs:(dur-1/fs);
    s  = 0.8*sin(2*pi*f0*tt);

    if fade > 1 && numel(s) > 2*fade
        w = ones(size(s));
        w(1:fade) = linspace(0,1,fade);
        w(end-fade+1:end) = linspace(1,0,fade);
        s = s .* w;
    end

    x = [x s gap];
end

x = x(:);
audiowrite('mysong.wav', x, fs, 'BitsPerSample', 16);

info = audioinfo('mysong.wav');
fprintf('BitsPerSample = %d\n', info.BitsPerSample);

sound(x, fs);








%2.3
wavFile = 'mysong.wav';

Tset = [0.25 0.5];

noteNames = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'};
noteFreqs = [261.6256 277.1826 293.6648 311.1270 329.6276 349.2282 369.9944 391.9954 415.3047 440.0000 466.1638 493.8833];

[x, fs] = audioread(wavFile);
if size(x,2) > 1, x = mean(x,2); end
x = x(:);
mx = max(abs(x));
if mx > 0, x = x/mx; end

winEnv = max(1, round(0.010*fs));
pwr = x.^2;

if exist('movmean','file') == 2
    env = movmean(pwr, winEnv);
else
    env = conv(pwr, ones(winEnv,1)/winEnv, 'same');
end

thr = 0.10 * max(env);
act = env > thr;

d = diff([0; act; 0]);
sIdx = find(d == 1);
eIdx = find(d == -1) - 1;

minLen = round(0.10*fs);
keep = (eIdx - sIdx + 1) >= minLen;
sIdx = sIdx(keep);
eIdx = eIdx(keep);

mergeGap = round(0.015*fs);
s2 = []; e2 = [];
if ~isempty(sIdx)
    cs = sIdx(1); ce = eIdx(1);
    for k = 2:numel(sIdx)
        if sIdx(k) - ce <= mergeGap
            ce = eIdx(k);
        else
            s2 = [s2; cs];
            e2 = [e2; ce];
            cs = sIdx(k); ce = eIdx(k);
        end
    end
    s2 = [s2; cs];
    e2 = [e2; ce];
end

M = numel(s2);

notesHat = strings(M,1);
durHat   = zeros(M,1);
durQ     = zeros(M,1);
fHat     = zeros(M,1);

for i = 1:M
    seg = x(s2(i):e2(i));
    durHat(i) = numel(seg)/fs;

    Nfft = 2^nextpow2(max(4096, numel(seg)*8));
    w = hannwin(numel(seg));
    S = fft(seg.*w, Nfft);

    mag = abs(S(1:floor(Nfft/2)+1));
    mag(1) = 0;

    [~,k0] = max(mag);
    f = (0:floor(Nfft/2))*(fs/Nfft);

    f0 = f(k0);
    if k0 > 1 && k0 < numel(mag)
        m1 = mag(k0-1); m0 = mag(k0); m2 = mag(k0+1);
        den = (m1 - 2*m0 + m2);
        if abs(den) > 1e-12
            dk = 0.5*(m1 - m2)/den;
            f0 = f0 + dk*(fs/Nfft);
        end
    end

    fHat(i) = f0;
    [~,ix] = min(abs(noteFreqs - f0));
    notesHat(i) = string(noteNames{ix});

    [~,iq] = min(abs(Tset - durHat(i)));
    durQ(i) = Tset(iq);
end

tStart = (s2-1)/fs;
tEnd   = (e2-1)/fs;

TBL = table((1:M)', notesHat, fHat, durHat, durQ, tStart, tEnd, ...
    'VariableNames', {'idx','note','f_est_Hz','dur_s','dur_q','t_start_s','t_end_s'});
disp(TBL);

tt = (0:numel(x)-1)/fs;
figure; plot(tt, env); grid on; hold on;
plot(tt, thr*ones(size(tt)));
for i = 1:M
    plot([tStart(i) tStart(i)], ylim);
    plot([tEnd(i) tEnd(i)], ylim);
end
xlabel('t (s)'); ylabel('env');

function w = hannwin(L)
    if L <= 1
        w = ones(L,1);
    else
        n = (0:L-1).';
        w = 0.5 - 0.5*cos(2*pi*n/(L-1));
    end
end
 