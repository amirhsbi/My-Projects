function sig = coding_amp(msg, bitrate)
    Mapset = make_mapset();
    bits = [];
    for k = 1:length(msg)
        idx = find([Mapset{1,:}] == msg(k), 1);
        bits = [bits, Mapset{2, idx}];
    end

    R = bitrate;
    fs = 100;
    N = fs;
    t = (0:N-1)/fs;
    base = 2*sin(2*pi*t);

    bits = reshape(bits, R, []).';
    numSym = size(bits, 1);
    sig = zeros(1, numSym*N);

    w = 2.^(R-1:-1:0).';
    for n = 1:numSym
        val = bits(n, :) * w;
        a = val / (2^R - 1);
        sig((n-1)*N+1:n*N) = a * base;
    end
end
