function img_out = coding(message, img_in, Mapset)
    if isempty(message) || message(end) ~= ';', message = [message ';']; end
    chars = [Mapset{1,:}]; codes = Mapset(2,:);
    bits = [];
    for i = 1:numel(message)
        idx = find(chars==message(i),1);
        if isempty(idx), error('unsupported character: %s', message(i)); end
        bits = [bits, codes{idx}]; 
    end
    if size(img_in,3)>1, img_in = rgb2gray(img_in); end
    restoreClass = class(img_in);
    if ~isa(img_in,'uint8'), img = uint8(round(double(img_in))); else, img = img_in; end
    [H,W] = size(img); bh = 5; bw = 5;
    nBh = floor(H/bh); nBw = floor(W/bw);
    H2 = nBh*bh; W2 = nBw*bw;
    img_c = img(1:H2,1:W2);
    V = zeros(nBh,nBw);
    for by = 1:nBh
        for bx = 1:nBw
            yy = (by-1)*bh + (1:bh);
            xx = (bx-1)*bw + (1:bw);
            V(by,bx) = var(double(img_c(yy,xx)),0,'all');
        end
    end
    [~,order] = sort(V(:),'descend');
    bitsPerBlock = bh*bw;
    needBlocks = ceil(numel(bits)/bitsPerBlock);
    if needBlocks > numel(order), error('Insufficient capacity.'); end
    use = order(1:needBlocks);
    img_out = img;
    bitPtr = 1;
    for k = 1:numel(use)
        [by,bx] = ind2sub([nBh,nBw],use(k));
        yy = (by-1)*bh + (1:bh);
        xx = (bx-1)*bw + (1:bw);
        bvec = img_out(yy,xx); bvec = bvec(:);
        for p = 1:numel(bvec)
            if bitPtr > numel(bits), break; end
            v = bvec(p); b = bits(bitPtr);
            if bitand(v,1) ~= b
              if b==1, v = min(255,v+1); else, v = max(0,v-1); end
            end
            bvec(p) = v; bitPtr = bitPtr + 1;
        end
        img_out(yy,xx) = reshape(bvec,bh,bw);
        if bitPtr > numel(bits), break; end
    end
    img_out = cast(img_out, restoreClass);
end
