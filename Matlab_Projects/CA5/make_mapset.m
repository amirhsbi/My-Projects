function Mapset = make_mapset()
symbols = [arrayfun(@(c) char(c), 'a':'z', 'UniformOutput', false), {' '},{'.'},{','},{'!'},{';'},{'"'}];
Mapset = cell(2,32);
for k = 1:32
    Mapset{1,k} = symbols{k};
    Mapset{2,k} = dec2bin(k-1,5) - '0';
end
end
