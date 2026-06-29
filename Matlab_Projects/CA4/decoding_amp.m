function msg = decoding_amp(sig, bitrate)
    Mapset = make_mapset();
    R = bitrate;
    fs = 100;
    N = fs;
    t = (0:N-1)/fs;
    base = 2*sin(2*pi*t);
    numSym = length(sig)/N;

    bits = zeros(1, numSym*R);
    levels = (0:(2^R-1))/(2^R-1);
    corrNorm = 0.01*sum(base.^2);

    for i = 1:numSym
        s = sig((i-1)*N+1:i*N);
        c = 0.01*sum(s.*base);
        a_hat = c/corrNorm;
        a_hat = min(max(a_hat,0),1);
        [~, idxLevel] = min(abs(a_hat - levels));
        val = idxLevel - 1;
        b = dec2bin(val, R) - '0';
        bits((i-1)*R+1:i*R) = b;
    end

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
