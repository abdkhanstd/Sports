


sep='-';

folder='.\scores';
target_folder='.\score_streams\';

matfiles=dir(folder);



%for kk=3:size(matfiles,1)
%name=strcat(folder,'\',matfiles(kk).name);
kk=23


name=strcat(folder,'\','Sc_data_vid00',num2str(kk));

fprintf('%s\n',name);
load(name);


        
        expression = '[0-9]+\-[0-9]+';
        scores_streams=[];
        time_record=[];

        in=1;
        for i=1:size(score_record,2)
            str=score_record{i};
            
            if size(find(str=='/'),2)>0 || size(find(str=='\'),2)>0                
                str=strrep(str,'-','');
                str=strrep(str,'/','-');
                str=strrep(str,'\','-');
                str=strrep(str,' ','');
                str=strrep(str,char(10),'');

            end
             

            if size(str,2)> 10
                str='';
                
            end
            
            

            if size(str,2) > 0
             [startIndex,endIndex]=regexp(str,expression) ;
             str=str(startIndex:endIndex);                          

             

             idx=startIndex;
                if size(idx,1) > 0



                   %Build streams
                   parts=strsplit(str,sep);
                   
                   
                   scores_streams(1,in)=str2num(parts{1});
                   scores_streams(2,in)=str2num(parts{2});
                    fprintf('%s \n',str);                              
% 
% %                   % See if current score is very large than before
%                    if in==1
%                    
%                    elseif abs(scores_streams(1,in)-scores_streams(1,in-1))  > 15 && scores_streams(1,in) ~=0
%                     scores_streams(1,in)=scores_streams(1,in-1);
%                    end
%                    
%                    if in==1
%                    
%                    elseif abs(scores_streams(2,in)-scores_streams(2,in-1)) > 15 && scores_streams(2,in) ~=0
%                     scores_streams(2,in)=scores_streams(2,in-1);
%                    end
% %                    
                   
                   time_record(1,in)=i;
                   
                   scores_streams(3,in)=i;

                   in=in+1;



                end                   
            end
        end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%one more parse streams
scores_streams(1,1)=0;
scores_streams(2,1)=0;
for i=2:size(scores_streams,2)-1
    p_1=scores_streams(1,i-1); c_1=scores_streams(1,i);
    n_1=scores_streams(1,i+1);
    
    p_2=scores_streams(2,i-1); c_2=scores_streams(2,i);
    n_2=scores_streams(2,i+1);
    
        
    
    if p_1 > c_1 && c_1 < n_1 && sum(scores_streams(1,i:i+1))~=0
        scores_streams(1,i)=scores_streams(1,i-1);
    end
    
    if p_2 > c_2 && c_2 < n_2 && sum(scores_streams(2,i:i+1))~=0
        scores_streams(2,i)=scores_streams(2,i-1);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if p_1 < c_1 && c_1 > n_1 && sum(scores_streams(1,i:i+1))~=0
        scores_streams(1,i)=scores_streams(1,i-1);
    end
 
    
    if p_2 < c_2 && c_2 > n_2 && sum(scores_streams(2,i:i+1))~=0
        scores_streams(2,i)=scores_streams(2,i-1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if p_1 == c_1 && c_1 > n_1
        scores_streams(1,i+1)=scores_streams(1,i);
    end
 
    
    if p_2 == c_2 && c_2 > n_2
        scores_streams(2,i+1)=scores_streams(2,i);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if p_1 == n_1
        scores_streams(1,i+1)=scores_streams(1,i);
    end
 
    
    if p_2 == n_2
        scores_streams(2,i+1)=scores_streams(2,i);
    end
end

name=strcat(target_folder,matfiles(kk).name);


% name=strcat(target_folder,'Sc_data_vid00',num2str(kk));
save(name,'scores_streams','time_record');
close all
%test_plots
     t=scores_streams';
%end
sum(myder(scores_streams))



