function G = mygrayfun(img)
if ndims(img) == 2
    G = im2double(img);
    return;
end
img = im2double(img);
R = img(:,:,1);
Gg = img(:,:,2);
B = img(:,:,3);
G = 0.299*R + 0.578*Gg + 0.114*B;
end
