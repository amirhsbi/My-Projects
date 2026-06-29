clc; clear; close all;
di = dir('mapset');
names = {di.name};
names = names(~ismember(names, {'.','..'}));
len = numel(names);
TRAIN = cell(2, len);
for i = 1:len
    I = imread(fullfile('mapset', names{i}));
    if ~islogical(I)
        if ndims(I)==3
            I = rgb2gray(I);
        end
        if exist('imbinarize','file')
            I = imbinarize(I);
        else
            T = graythresh(I);
            I = I > T;
        end
    end
    I = imresize(I, [42 24]);
    TRAIN(1,i) = {I};
    temp = names{i};
    TRAIN(2,i) = {temp(1)};
end
save('MAPSET.mat','TRAIN');
