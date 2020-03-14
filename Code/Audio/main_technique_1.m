
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1 Merge the channels

%signal=signal(:,1);

fs=Fs;% Filter the signal
fc = 34; % Make higher to hear higher frequencies.
% Design a Butterworth filter.
[b, a] = butter(7,[300 3200]/(fs/2));
% figure(2);

%freqz(b,a)
% Apply the Butterworth filter.
signal = filter(b, a, signal);


% Smoothing
windowWidth = 27;
polynomialOrder = 3;
%signal = sgolayfilt(signal, polynomialOrder, windowWidth);


% figure(3);
% plot(t,filteredSignal);
% ylim([-1 1])

 mean_=mean(abs(signal));
   
 idx_1=find(abs(signal(:,1)) >0.35);
 idx_2=find(abs(signal(:,2)) > 0.35);
 signal_=zeros(size(signal));
 
 
 signal_(idx_1,1)=signal(idx_1,1);
 signal_(idx_2,2)=signal(idx_2,2);
 signal=compute_derivative(sum(signal_,2)/2);
% clearvars signal_;


 
 figure(4);
 plot(t,abs(signal_));

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Checking by deriative

%player=audioplayer(signal, Fs);



% Power spectrum estimate
%  figure
%  pwelch(signal,[],[],[],Fs)
