%2.3
msg = 'signal';  
bitrate1 = 1;     
bitrate5 = 5;     

sig1 = coding_freq(msg, bitrate1);  
sig5 = coding_freq(msg, bitrate5);  

figure;
subplot(2,1,1);
plot(sig1);
title('Signal for 1 bit per second');
xlabel('Sample Index');
ylabel('Amplitude');

subplot(2,1,2);
plot(sig5);
title('Signal for 5 bits per second');
xlabel('Sample Index');
ylabel('Amplitude');

%2.4
msg0 = 'signal';

s1 = coding_freq(msg0, 1);
d1 = decoding_freq(s1, 1);

s5 = coding_freq(msg0, 5);
d5 = decoding_freq(s5, 5);

fprintf('bitrate = 1  --> decoded = %s\n', d1);
fprintf('bitrate = 5  --> decoded = %s\n', d5);

%2.5
msg0 = 'signal';

s1 = coding_freq(msg0, 1);
s5 = coding_freq(msg0, 5);

sigma = sqrt(0.0001);

r1 = s1 + sigma*randn(size(s1));
r5 = s5 + sigma*randn(size(s5));

d1 = decoding_freq(r1, 1);
d5 = decoding_freq(r5, 5);

fprintf('bitrate = 1 , decoded = %s\n', d1);
fprintf('bitrate = 5 , decoded = %s\n', d5);

%2.6