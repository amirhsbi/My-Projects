clc; close all; clear;
load MAPSET;
totalLetters = size(TRAIN,2);
[file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif'}, 'Choose a plate image');
if isequal(file,0) || isequal(path,0)
    error('No image selected.');
end
img = imread(fullfile(path, file));
figure; subplot(1,2,1); imshow(img); title('Original');
img = imresize(img, [300 500]);
subplot(1,2,2); imshow(img); title('Resized 300x500');

gray = mygrayfun(img);
figure; imshow(gray,[]); title('Grayscale');

thr = 0.5;
BW = mybinaryfun(gray, thr);
BW = ~BW;
figure; imshow(BW); title('Binary');

figure;
subplot(1,3,1); imshow(BW); title('Input');
BW_clean = myremovecom(BW, 200);
subplot(1,3,2); imshow(BW_clean); title('After myremovecom(200)');
BG = myremovecom(BW_clean, 3000);
BW_fg = BW_clean & ~BG;
subplot(1,3,3); imshow(BW_fg); title('Foreground');

[L, num] = mysegmentation(BW_fg);

stats = regionprops(L, 'BoundingBox');
if isempty(stats)
    error('No segments found.');
end
[~, sortIdx] = sort(arrayfun(@(s) s.BoundingBox(1), stats));

figure; imshow(BW_fg); title(sprintf('Segments = %d', num)); hold on;
for i = 1:numel(sortIdx)
    rectangle('Position',stats(sortIdx(i)).BoundingBox,'EdgeColor','g','LineWidth',2);
end
hold off;

final_output = [];
figure; colormap gray;
for idx = 1:numel(sortIdx)
    n = sortIdx(idx);
    [r, c] = find(L == n);
    if isempty(r) || isempty(c), continue; end
    Y = BW_fg(min(r):max(r), min(c):max(c));
    Y = imresize(Y, [42 24]);
    imagesc(Y); axis image off; title(sprintf('Segment %d',n)); drawnow;

    ro = zeros(1, totalLetters);
    for k = 1:totalLetters
        ro(k) = corr2(TRAIN{1,k}, Y);
    end
    [MAXRO, pos] = max(ro);
    if MAXRO > 0.45
        ch = TRAIN{2, pos};
        final_output = [final_output ch];
    end
end

disp(['Plate: ', final_output]);
fid = fopen('number_Plate.txt','wt');
fprintf(fid, '%s\n', final_output);
fclose(fid);
winopen('number_Plate.txt');











