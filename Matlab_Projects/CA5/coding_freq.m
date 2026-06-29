function sig = coding_freq(msg, bitrate)
    Mapset = make_mapset();
    R = bitrate;
    fs = 100;
    N = fs;
    t = (0:N-1)/fs;

    bits = [];
    for i = 1:length(msg)
        ch = msg(i);
        idx = find(strcmp(Mapset(1,:), ch), 1);
        bits = [bits, Mapset{2,idx}];
    end

    bitsSym = reshape(bits, R, []).';
    numSym = size(bitsSym, 1);

    M = 2^R;
    freqs = choose_freqs(M, fs);

    sig = zeros(1, numSym*N);
    for n = 1:numSym
        val = bin2dec(char(bitsSym(n,:) + '0'));
        f0 = freqs(val + 1);
        sig((n-1)*N+1:n*N) = sin(2*pi*f0*t);
    end
end

function freqs = choose_freqs(M, fs)
    fmax = fs/2 - 1;
    freqs = round(linspace(2, fmax, M));
    freqs = unique(freqs, 'stable');
    if length(freqs) < M
        pool = setdiff(1:fmax, freqs, 'stable');
        freqs = [freqs, pool(1:(M-length(freqs)))];
    else
        freqs = freqs(1:M);
    end
end
