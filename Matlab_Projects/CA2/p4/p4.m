clc; clear; close all;

[filename, pathname] = uigetfile({'*.mp4;*.avi;*.mov'}, 'Select Video');
if isequal(filename,0)
    return;
end

vid = VideoReader(fullfile(pathname, filename));
fps = vid.FrameRate;
frame_count = floor(vid.Duration * fps);

firstFrame = readFrame(vid);
gray_prev = rgb2gray(firstFrame);

positions = [];
frame_idx = 1;

while hasFrame(vid)
    frame = readFrame(vid);
    gray = rgb2gray(frame);
    diff_img = imabsdiff(gray, gray_prev);
    bw = imbinarize(diff_img);
    bw = bwareaopen(bw, 200);
    stats = regionprops(bw, 'BoundingBox', 'Area');
    if ~isempty(stats)
        [~, idx] = max([stats.Area]);
        bbox = stats(idx).BoundingBox;
        center_x = bbox(1) + bbox(3)/2;
        positions(end+1) = center_x;
    else
        positions(end+1) = NaN;
    end
    gray_prev = gray;
    frame_idx = frame_idx + 1;
end

positions = fillmissing(positions, 'linear');
time = (0:length(positions)-1) / fps;
dist_px = positions - positions(1);
scale_factor = 0.1; 
dist_m = dist_px * scale_factor;

total_distance = dist_m(end);
total_time = time(end);
avg_speed_mps = total_distance / total_time;
avg_speed_kmh = avg_speed_mps * 3.6;

disp(['Average Speed: ', num2str(avg_speed_kmh, '%.2f'), ' km/h']);

figure('Name','Car Tracking','NumberTitle','off');
plot(time, dist_m);
xlabel('Time (s)');
ylabel('Distance (m)');
title(['Average Speed = ', num2str(avg_speed_kmh, '%.2f'), ' km/h']);
grid on;
