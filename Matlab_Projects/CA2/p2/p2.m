clc; clear; close all;

[filename, pathname] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select Plate Image');
if isequal(filename,0)
    return;
end

img = imread(fullfile(pathname, filename));
img = imresize(img, [300 500]);
gray = rgb2gray(img);
bw = imbinarize(gray);
bw = imcomplement(bw);
bw = bwareaopen(bw, 80);

[L, num] = bwlabel(bw);
stats = regionprops(L, 'BoundingBox');

if num == 0
    error('No characters detected.');
end

[~, idx] = sort(arrayfun(@(x)x.BoundingBox(1), stats));
stats = stats(idx);

db_files = dir(fullfile('database', '*.png'));
if isempty(db_files)
    error('No database images found.');
end

db = cell(1, numel(db_files));
db_names = strings(1, numel(db_files));

for k = 1:numel(db_files)
    fpath = fullfile('database', db_files(k).name);
    t = imread(fpath);
    if size(t,3)==3, t = rgb2gray(t); end
    if ~islogical(t), t = imbinarize(t); end
    db{k} = im2double(imresize(t, [42 24]));
    [~, name, ~] = fileparts(fpath);
    db_names(k) = string(name);
end

result = strings(1, num);

for i = 1:num
    bbox = stats(i).BoundingBox;
    ch = imcrop(bw, bbox);

    if isempty(ch)
        continue;
    end

    ch = imresize(ch, [42 24]);
    ch = im2double(ch);

    max_corr = -inf;
    best = "";

    for k = 1:numel(db)
        db_img = db{k};
        [r1, c1] = size(ch);
        [r2, c2] = size(db_img);
        if r1 ~= r2 || c1 ~= c2
            db_img = imresize(db_img, [r1 c1]);
        end
        try
            val = corr2(ch, db_img);
        catch
            continue;
        end
        if val > max_corr
            max_corr = val;
            best = db_names(k);
        end
    end

    result(i) = best;
end

plate_str = join(result, '');
disp(['Recognized Plate: ', plate_str]);
fid = fopen('plate_output.txt', 'w');
fprintf(fid, '%s', plate_str);
fclose(fid);

figure('Name','Plate Recognition Result','NumberTitle','off');
imshow(img);
title(['Recognized Plate: ', plate_str],'FontSize',14,'Color','b');
hold on
for i = 1:num
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1);
end
hold off
