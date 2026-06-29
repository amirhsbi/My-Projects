%1.3
msg = 'signal';

y1 = coding_amp(msg, 1);
y2 = coding_amp(msg, 2);
y3 = coding_amp(msg, 3);

figure;
plot(y1);
title('signal - bitrate = 1 bit/s');

figure;
plot(y2);
title('signal - bitrate = 2 bit/s');

figure;
plot(y3);
title('signal - bitrate = 3 bit/s');
 
%1.4
msg = 'signal';

for R = 1:3
    s = coding_amp(msg, R);
    d = decoding_amp(s, R);
    fprintf('bitrate = %d --> decoded = %s\n', R, d);
end

%1.5
x = randn(1,3000);     
figure;
histogram(x,50,'Normalization','pdf'); 
m = mean(x)         
v = var(x)           

%1.6
msg = 'signal';
sigma = sqrt(0.0001);

for R = 1:3
    s = coding_amp(msg, R);
    noise = sigma * randn(1, length(s));
    rcv = s + noise;
    dec = decoding_amp(rcv, R);
    fprintf('bitrate = %d  -->  decoded = "%s"\n', R, dec);
end

