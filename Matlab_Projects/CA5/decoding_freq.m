function msg = decoding_freq(sig, bitrate)
    Mapset = make_mapset();
    R = bitrate;
    fs = 100;
    N = fs;

    numSym = floor(length(sig)/N);
    sig = sig(1:numSym*N);

    M = 2^R;
    freqs = choose_freqs(M, fs);

    f = (-fs/2):(fs/N):(fs/2 - fs/N);
    candIdx = zeros(1, M);
    for k = 1:M
        candIdx(k) = find(f == freqs(k), 1);
    end

    bits = zeros(1, numSym*R);
    for i = 1:numSym
        s = sig((i-1)*N+1:i*N);
        Y = fftshift(fft(s));
        mag = abs(Y);

        [~, midx] = max(mag(candIdx));
        val = midx - 1;

        b = dec2bin(val, R) - '0';
        bits((i-1)*R+1:i*R) = b;
    end

    bits = bits(1:floor(length(bits)/5)*5);
    bits5 = reshape(bits, 5, []).';

    codes = zeros(32,5);
    for k = 1:32
        codes(k,:) = Mapset{2,k};
    end

    msgChars = repmat(' ', 1, size(bits5,1));
    for j = 1:size(bits5,1)
        idx = find(ismember(codes, bits5(j,:), 'rows'), 1);
        msgChars(j) = Mapset{1,idx};
    end

    msg = msgChars;
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
