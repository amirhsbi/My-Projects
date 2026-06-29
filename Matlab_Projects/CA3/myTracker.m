[fn, fp] = uigetfile({'*.mp4'}, 'Select IR video');
if isequal(fn,0), return; end
inPath = fullfile(fp,fn);
vr = VideoReader(inPath);

frame = readFrame(vr);
if size(frame,3)>1, frame = rgb2gray(frame); end
frame = im2uint8(frame);

figure('Name','myTracker'); imshow(frame);
title('Draw roi around the airplane, then confirm');

try
    roi = drawrectangle('Color','g');
    wait(roi);
    pos = round(roi.Position);
    delete(roi);
catch
    h = imrect(gca);
    pos = round(wait(h));
    delete(h);
end

template = imcrop(frame, pos);

scaleList   = 0.85:0.05:1.25;
alphaUpdate = 0.10;
minScore    = 0.30;
searchMargin= 2.0;

[~, baseName] = fileparts(inPath);
outFile = fullfile(fp, [baseName '_tracked.mp4']);
vw = VideoWriter(outFile,'MPEG-4'); vw.FrameRate = vr.FrameRate; open(vw);

cx = pos(1)+pos(3)/2; cy = pos(2)+pos(4)/2; w = pos(3); hgt = pos(4);
frameIdx = 1;

while hasFrame(vr)
    frame = readFrame(vr);
    if size(frame,3)>1, frame = rgb2gray(frame); end
    frame = im2uint8(frame);

    r = round(searchMargin * max(w,hgt));
    x1 = max(1, round(cx - r)); y1 = max(1, round(cy - r));
    x2 = min(size(frame,2), round(cx + r)); y2 = min(size(frame,1), round(cy + r));
    searchImg = frame(y1:y2, x1:x2);

    bestScore = -Inf; bestBBox = [pos(1) pos(2) w hgt];
    for s = scaleList
        tmpl = imresize(template, s, 'bilinear');
        if any(size(tmpl) >= size(searchImg)), continue; end
        C = ncc2(searchImg, tmpl);
        [mval, imax] = max(C(:));
        if mval > bestScore
            [ypeak, xpeak] = ind2sub(size(C), imax);
            xoff = xpeak - size(tmpl,2);
            yoff = ypeak - size(tmpl,1);
            bestScore = mval;
            bestBBox = [x1 + xoff, y1 + yoff, size(tmpl,2), size(tmpl,1)];
        end
    end

    if bestScore >= minScore
        pos = round(bestBBox);
        cx = pos(1)+pos(3)/2; cy = pos(2)+pos(4)/2; w = pos(3); hgt = pos(4);
        newPatch = safeCrop(frame, pos);
        if ~isempty(newPatch)
            newPatch = imresize(newPatch, size(template));
            template = uint8((1-alphaUpdate)*double(template) + alphaUpdate*double(newPatch));
        end
    end

    imshow(frame); title(sprintf('Frame %d | NCC=%.2f', frameIdx, bestScore));
    hold on; rectangle('Position', pos, 'EdgeColor','g', 'LineWidth', 2); hold off; drawnow;
    F = getframe(gca); writeVideo(vw, F.cdata);
    frameIdx = frameIdx + 1;
end

close(vw); fprintf('Saved: %s\n', outFile);

function C = ncc2(img, tmpl)
    if exist('normxcorr2','file')
        C = normxcorr2(tmpl, img);
    else
        img = double(img); tmpl = double(tmpl);
        img = (img - mean(img(:))) / (std(img(:))+eps);
        tmpl = (tmpl - mean(tmpl(:))) / (std(tmpl(:))+eps);
        C = conv2(img, rot90(tmpl,2), 'valid');
        mx = sqrt(conv2(img.^2, ones(size(tmpl)), 'valid') .* sum(tmpl(:).^2));
        C = C ./ (mx + eps);
    end
end

function patch = safeCrop(I, rect)
    x = max(1, rect(1)); y = max(1, rect(2));
    w = rect(3); h = rect(4);
    x2 = min(size(I,2), x + w - 1); y2 = min(size(I,1), y + h - 1);
    if x2<=x || y2<=y, patch = []; return; end
    patch = I(y:y2, x:x2);
end

