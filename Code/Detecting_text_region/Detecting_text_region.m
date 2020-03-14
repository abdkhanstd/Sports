




%First checking for text regions
%Finding the motion areas



% Scorebox detection experiment (This time i am aiming to produce lower results)

clear;close all
warning('off','all');
clc;



load templates


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Tuning Parameters                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rescale parameters
scale=10; 
voting_map_cutoff=2;

% windows size (can be any) for a smaller windows scale should be higher
win_r=80; % row (height of window)
win_c=110; % col (width of window)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Setting all the video parameters                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Time_to_Skip_Between_Frames=2;    % Time in seconds
start_video_processing_from = 3;   % The video number to start from
end_video_processing_from= start_video_processing_from;    % The total number of videos
duration_to_process=600;           % put 0 for full duration
Video_Extention='mp4';             % Video types/extention in the folder
Video_File_Name='vid';             % Name format vid1,vid2,vid3,vid4,vid5
Path_to_video_folder='E:\One Drive\OneDrive - std.uestc.edu.cn\Experiments\Socrebox_Paper_experiments_dataset\videos';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Bounding box margins                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
height_margin=4;
width_margin=8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Experimental margins for OCR                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ocr_h_margin=7;
ocr_w_margin=5;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Votes Variables                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

region_voting={};   % video_number,region voting 
frame_samples={};
frame_samples_rgb={};
regions=[];
maps={};
map_=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Load start time and ground truth location                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_start_time_location;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Building list of available videos                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for video_num=1:end_video_processing_from
    Video_Data{video_num,1}=strcat(Path_to_video_folder,'\vid',num2str(video_num),'.mp4');    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Actual video processing section                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for video_num=start_video_processing_from:end_video_processing_from
    
     % Reading the video and skipping the first frame
     fprintf('Processing Video # : %d\n',video_num);
     
     video = VideoReader(Video_Data{video_num,1});
     Start_Time=Video_Data{video_num,2};  
     region_votes{video_num}=zeros(video.Height,video.Width);

     if(duration_to_process~=0)
        if (video.Duration<=Start_Time+duration_to_process)
                end_time=video.Duration;
        else
               end_time=Start_Time+duration_to_process;
        end
     else
        end_time=video.Duration;
    end
        
    % Checking if the video has a shorter duration than the given 
    if(end_time > video.Duration)
         end_time=video.Duration;
    end
    

    first_run=1;  
    frun_inner=0;
    bounds=Video_Data{video_num,3};
    for fnum = Start_Time:Time_to_Skip_Between_Frames:end_time   
        
        video.CurrentTime=round(fnum);
        frame = readFrame(video);            
          if(first_run==1)
                curr_frame=rgb2gray(frame);
                first_run=0;
                [im_r im_c]=size(curr_frame);
                extracted_sb=uint8(zeros(size(templates{video_num})));
                motion_area=uint8(zeros(size(templates{video_num})));

          else
                        next_frame=curr_frame;
                        curr_frame =rgb2gray(frame);
                        result_next=isitthere(rgb2gray(templates{video_num}),next_frame);
                        result_current=isitthere(rgb2gray(templates{video_num}),curr_frame);

                       if (result_next && result_current) 
                           %crop region
                           fame_detected_curr=curr_frame(bounds(1):bounds(2),bounds(3):bounds(4),:);
                           fame_detected_next=next_frame(bounds(1):bounds(2),bounds(3):bounds(4),:);
                           extracted_sb =fame_detected_curr-fame_detected_next;
%                            extracted_sb=uint8(imbinarize(extracted_sb));
%                            motion_area=extracted_sb+motion_area;
                           imshow(uint8(imbinarize(fame_detected_curr))*255);
                           pause (0.5);
                       else
                           disp('SB Not found');
                       end
          end



                            

    end % Loop end for a single video 
end % All the videos


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




