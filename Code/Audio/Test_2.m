
clear
path='e:\audio_small';


% Analyse audi file
[signal,Fs] = audioread([path,'\vid_loud1.mp3']);
signal=signal(:,1);
dt = 1/Fs;

timescale = 0:dt:(length(signal)*dt)-dt;

[negpks1,locidx1] = findpeaks(-signal, 'MinPeakHeight',0.4);
[negpks2,locidx2] = findpeaks(-signal, 'MinPeakHeight',0.15);
spike2idx = setdiff(locidx2, locidx1);
figure(1)
plot(timescale, signal)
hold on
plot(timescale(locidx1), -negpks1, 'vr', 'MarkerFaceColor','r')
plot(timescale(spike2idx), signal(spike2idx), 'vg', 'MarkerFaceColor','g')
hold off
grid
axis([0  0.3    ylim])
rep_rate1 = [mean(diff(timescale(locidx1)))  std(diff(timescale(locidx1)))  median(diff(timescale(locidx1)))]
rep_rate2 = [mean(diff(timescale(spike2idx)))  std(diff(timescale(spike2idx)))  median(diff(timescale(spike2idx)))]
