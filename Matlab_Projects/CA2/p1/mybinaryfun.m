function BW = mybinaryfun(gray, thr)
if ~isa(gray,'double')
    gray = im2double(gray);
end
if thr < 0 || thr > 1
    error('Threshold must be in [0,1].');
end
BW = logical(gray > thr);
end
