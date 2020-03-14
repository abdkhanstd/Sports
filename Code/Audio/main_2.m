path='e:\audio_small';


% Analyse audi file
[data,fs] = audioread([path,'\vid1.mp3']);


t = 0:dt:1;  % Time
N = length(data);
f = (1:N/2+1)*fs/N;  % Frequency

clip = 205;  % Clip size (number of points)

X = zeros(clip, length(data)-clip);  % Clips matrix
Y = zeros(length(f), length(data)-clip);  % Spectrogram
for i = 1:length(data)-clip
    X(:,i) = data(i:i+clip-1);
    tmpS = fft(X(:,i), N);
    Y(:,i) = abs(tmpS(1:N/2+1));
end
imagesc(t, f, (Y))
title('Spectrogram of Hidden words');
xlabel('Time [s]')
ylabel('Frequency [Hz]')