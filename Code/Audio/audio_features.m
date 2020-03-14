


path='E:\Audio_splits\52';

fname_pre='\52_00';
khz=44100;
tota_files=8;
chunk={};
th= 0.565;
ws=15;

for i=0:tota_files-1

    
    
    % Read audio file chunks
    fname=[path fname_pre num2str(i) '.mp3']
    [signal fs]=audioread(fname);
    sav=signal;
    dt = 1/fs;
    t = 0:dt:(length(signal)*dt)-dt;
     signal_x=(abs(signal(:,1))+abs(signal(:,2)))/2;

     th=max(signal_x)-mean(signal_x);

     [b, a] = butter(7,[300 3200]/(fs/2));
     signal = filter(b, a, signal);
     
     
      signal=(abs(signal(:,1))+abs(signal(:,2)))/2;
      
      idx_1=find(abs(signal) > th);
      signal_=zeros(size(signal));
      
      signal_(idx_1)=1;
      
      signal=compute_derivative(sum(signal_,2)/2);
      
      %Computing key frames 
      
      % Bringing from sample space to timeline in seconds
      signal_tl=zeros(1,round(length(signal)/khz));
      signal_t1(ceil(idx_1/khz))=1;
      
      
      %plot(abs(signal_t1));
       chunk{i+1}=signal_t1;
       
       
       
       % Moving a window on 
       

end


% Merge chunks

cntr=1;
merged=[];
for i=1:tota_files
    
    for j= 1:size(chunk{i},2)
        merged(1,cntr)=chunk{i}(j);
        cntr=cntr+1;
    end
       
    
end



ite_y=1;
for i=1:ws:size(merged,2)
    % Traverse window
   
    if(ite_y*ws < size(merged,2))
        if (sum(merged(1,i:ite_y*ws)) > 1 )
            
            tmp=zeros(1,ws);
            merged(1,i:ite_y*ws)=tmp(1:ws);
            
        end
        ite_y=ite_y+1;

        
    end
    
    
end
      


width=300;
height=130
close all
    
figure
h=stem(merged)
set(h, 'Marker', 'none')
set(gcf,'position',[0,0,width,height])
set(gca, 'FontName', 'Times new roman');
set(gca,'FontSize',8)
ylabel('Event')
xlabel('Time (seconds)')



