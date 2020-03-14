
clear;close all
path='e:\audio_small';


% Analyse audi file
[signal,Fs] = audioread([path,'\vid_loud1.mp3']);

dt = 1/Fs;
t = 0:dt:(length(signal)*dt)-dt;
plot(t,signal); 
figure(1);
xlabel('Seconds'); 
ylabel ('Amplitude');
ylim([-1 1])

findchangepts(signal);
 on=ones(size(ipt,2));
 hold on;
 plot(ipt,ones);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Checking by deriative
% player=audioplayer(signal, Fs);
% Power spectrum estimate
% figure
% pwelch(signal,[],[],[],Fs)
