function message = decoding(img_in, Mapset, blockSize, varThresh)
    if nargin<3 || isempty(blockSize), blockSize = [5 5]; end
    if nargin<4 || isempty(varThresh), varThresh = -Inf; end

    if size(img_in,3)>1, img_in = rgb2gray(img_in); end
    if ~isa(img_in,'uint8'), img = im2uint8(img_in); else, img = img_in; end

    [H,W] = size(img); bh = blockSize(1); bw = blockSize(2);
    nBh = floor(H/bh); nBw = floor(W/bw);
    H2 = nBh*bh; W2 = nBw*bw; img = img(1:H2,1:W2);

    V = zeros(nBh,nBw);
    for by = 1:nBh
        for bx = 1:nBw
            yy = (by-1)*bh + (1:bh);
            xx = (bx-1)*bw + (1:bw);
            V(by,bx) = var(double(img(yy,xx)),0,'all');
        end
    end

    [vSorted, order] = sort(V(:),'descend');
    if isfinite(varThresh)
        cand = order(vSorted >= varThresh);
    else
        cand = order;
    end

    bits = [];
    for k = 1:numel(cand)
        [by,bx] = ind2sub([nBh,nBw], cand(k));
        yy = (by-1)*bh + (1:bh);
        xx = (bx-1)*bw + (1:bw);
        bvec = img(yy,xx); bvec = bvec(:);
        bits = [bits; bitand(bvec,1)];
    end
    bits = bits(:).';

    chars = [Mapset{1,:}];
    codes = Mapset(2,:);
    msg = [];
    numChunks = floor(numel(bits)/5);
    for i = 1:numChunks
        chunk = bits((i-1)*5 + (1:5));
        found = false;
        for j = 1:32
            if isequal(chunk, codes{j})
                ch = chars(j);
                msg(end+1) = ch; 
                found = true;
                break
            end
        end
        if ~found || ch==';', break; end
    end

    if isempty(msg), message = ''; else, message = char(msg); end
    fprintf('%s\n', message);
end

