function BWout = myremovecom(BW, minPixels)
[L, num] = mysegmentation(BW);
BWout = false(size(BW));
if num == 0, return; end
counts = accumarray(L(L>0), 1);
keep = find(counts >= minPixels);
for k = 1:numel(keep)
    BWout = BWout | (L == keep(k));
end
end
