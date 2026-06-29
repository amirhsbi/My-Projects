function Mapset = make_mapset()
    chars = ['a':'z',' ','.',',','!','"',';'];
    codes = dec2bin(0:31,5) - '0';
    Mapset = cell(2,32);
    Mapset(1,:) = num2cell(chars);
    for i = 1:32
        Mapset{2,i} = codes(i,:);
    end
end
