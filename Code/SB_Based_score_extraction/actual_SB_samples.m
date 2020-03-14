% Scorebox detection experiment (This time i am aiming to produce lower results)

clear;close all
warning('off','all');
clc;


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
Time_to_Skip_Between_Frames=60;    % Time in seconds
start_video_processing_from = 1;   % The video number to start from
end_video_processing_from= 104;    % The total number of videos
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
    
    map=uint8(zeros(video.Height+win_r,video.Width+win_c));
    map_=uint8(zeros(video.Height,video.Width));
    first_run=1;
    % Main loop for frame traversing 
    progBar = ProgressBar(size(Start_Time:Time_to_Skip_Between_Frames:end_time,2));
    for fnum = Start_Time:Time_to_Skip_Between_Frames:end_time   
        
        video.CurrentTime=round(fnum);
        frame = readFrame(video);                
        if (first_run==1)
            %Dont do anything on first frame
            curr_frame=rgb2gray(frame);
            first_run=0;
            [im_r im_c]=size(curr_frame);
            
            % Keeping sample for a frame
            frame_samples_rgb{video_num}=frame;
            frame_samples{video_num}=curr_frame; 
        else
            next_frame=curr_frame;
            curr_frame =rgb2gray(frame);
                
            % main code gose here
                            
                            show=0;
                            th_points=2;
                            im_a=next_frame;
                            im_b=curr_frame;

                            [im_r im_c]=size(im_a);

                            temp=uint8(zeros(im_r,im_c));

                            % Need padding
                            padding=uint8(zeros(im_r+win_r,im_c+win_c));
                            padding(1:im_r,1:im_c)=im_a(1:im_r,1:im_c);
                            im_a=padding;

                            padding=uint8(zeros(im_r+win_r,im_c+win_c));
                            padding(1:im_r,1:im_c)=im_b(1:im_r,1:im_c);
                            im_b=padding;
                            ite_x=0;
                            ite_y=0;
                            for i=1:win_r:im_r
                                ite_x=ite_x+1;
                                for j=1:win_c:im_c
                                    ite_y=ite_y+1;

                                    % subplot configs
                                    if show==1
                                        figure(1);
                                        %show figure1
                                        subplot(2,2,1);
                                        imshow(im_a);
                                        hold on;
                                        fprintf("row %d to %d, col %d to %d\n",i,ite_x*win_r,j,ite_y*win_c);
                                    end
                                        blk=im_a;
                                        blk(i:ite_x*win_r,j:ite_y*win_c)=255;
                                        content_a=im_a(i:ite_x*win_r,j:ite_y*win_c);
                                    if show==1
                                        imshow(blk);
                                    end

                                    %show figure2
                                    if show==1
                                        subplot(2,2,2);
                                        imshow(im_b);
                                        hold on;
                                    end

                                        blk=im_b;
                                        blk(i:ite_x*win_r,j:ite_y*win_c)=255;
                                        content_b=im_b(i:ite_x*win_r,j:ite_y*win_c);
                                    if show==1
                                        imshow(blk);
                                    end
                                    
                                    %Sharpening and resizing the image
                                    c_a=imsharpen(imresize(imsharpen(content_a),scale));
                                    c_b=imsharpen(imresize(imsharpen(content_b),scale));
                                    

                                    
                                    
                                    next_frame_surf_features = detectSURFFeatures(c_a);
                                    curr_frame_surf_features = detectSURFFeatures(c_b);


                                    [next_frame_extracted_features, next_frame_surf_features] = extractFeatures(c_a, next_frame_surf_features);
                                    [curr_frame_extracted_features, curr_frame_surf_features] = extractFeatures(c_b, curr_frame_surf_features);
                                    matched_features = matchFeatures(next_frame_extracted_features, curr_frame_extracted_features);


                                    matchednext_frame_surf_features = next_frame_surf_features(matched_features(:, 1), :);
                                    matchedcurr_frame_surf_features = curr_frame_surf_features(matched_features(:, 2), :);


                                    [tform, inliernext_frame_surf_features, inliercurr_frame_surf_features,status] = ...
                                    estimateGeometricTransform(matchednext_frame_surf_features, matchedcurr_frame_surf_features, 'similarity');


                                    if show==1
                                        subplot(2,2,3);
                                        imshow(content_a);
                                        hold on;
                                        plot(matchednext_frame_surf_features.Location(:, 1),matchednext_frame_surf_features.Location(:, 2),'yO');

                                        subplot(2,2,4);
                                        imshow(content_b);
                                        hold on;
                                        plot(matchednext_frame_surf_features.Location(:, 1),matchednext_frame_surf_features.Location(:, 2),'yO');
                                    end

                                    if (status == 0)
                                        if size(inliernext_frame_surf_features.Location,1) > th_points
                                            map(i:ite_x*win_r,j:ite_y*win_c)=255;
                                        end
                                    end


                                    if show==1
                                       pause(0.5)        
                                    end
                                end

                                %reset y
                                ite_y=0;
                            end
                            
%                             figure(2);                            
%                             imshow(map);
%                             pause(0.5)        
%      
        end
        
        % Filling the holes in the matched grid
        ite_x=0;
        ite_y=0;

        for i=1:im_r
            ite_x=ite_x+1;
             s_row=map(i,1:im_c);
            for j=1:win_c:im_c-win_r
                ite_y=ite_y+1;
                % First run
                if j==1
                    if ((ite_y+1)*win_c <im_c)
                        items_in_window_next=s_row(1,j+win_c:(ite_y+1)*win_c);
                    else
                        items_in_window_next=zeros(1,win_c);
                    end
                    items_in_window_current=s_row(1,j:ite_y*win_c);

                    p=0;
                    if(sum(items_in_window_current) > 0)
                        c=1;
                    else
                        c=0;
                    end
                    if(sum(items_in_window_next) > 0)
                        n=1;
                    else
                        n=0;
                    end

                % Normal Run
                elseif j<im_c-(2*win_r)
                    
                    items_in_window_prev=s_row(1,j-win_c:(ite_y-1)*win_c);
                    if ((ite_y+1)*win_c <im_c)
                        items_in_window_next=s_row(1,j+win_c:(ite_y+1)*win_c);
                    else
                        items_in_window_next=zeros(1,win_c);
                    end


                    if(sum(items_in_window_prev) > 0)
                        p=1;
                    else
                        p=0;
                    end

                    if(sum(items_in_window_current) > 0)
                        c=1;
                    else
                        c=0;
                    end
                    if(sum(items_in_window_next) > 0)
                        n=1;
                    else
                        n=0;
                    end

                %Last run        
                else            
                    items_in_window_prev=s_row(1,j-win_c:(ite_y-1)*win_c);
                    items_in_window_current=s_row(1,j:end);

                    if(sum(items_in_window_prev) > 0)
                        p=1;
                    else
                        p=0;
                    end

                    if(sum(items_in_window_current) > 0)
                        c=1;
                    else
                        c=0;
                    end
                         n=0;
                end

               % Fill the hole
               %fprintf('p=%d, c=%d,n=%d\n',p,c,n);
               if (p==1 && c==0 && n==1)           
                 map(i,j:ite_y*win_c)=255;  
               end



            end
            %reset y
            ite_y=0;
        end   
        map=uint8(imbinarize(map(1:im_r,1:im_c)));
        map_=map_+map;
        
    progBar([], [], []);

    end % Loop end for a single video 
        maps{video_num}=map_;
    	progBar.release();

end % All the videos


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Filtering Out the scorebox                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filtering out the regions from region_votes
Actual_region={};
Show_detected={};

for video_num=start_video_processing_from:end_video_processing_from
    
        % filtering out the max votes cutting off at the midlevel
       
        max_=max(max(maps{video_num}));
        min_=min(min(maps{video_num}));
        
        % cutoff level
        cut_off=(max_+min_)/voting_map_cutoff;
        index_=find(maps{video_num}>=cut_off);
       
        Actual_region{video_num}=uint8(zeros(size(region_votes{video_num})));
        Actual_region{video_num}(index_)=1;
        Show_detected{video_num}=Actual_region{video_num}.*frame_samples{video_num};
        Show_detected_rgb{video_num}=Actual_region{video_num}.*frame_samples_rgb{video_num};
        
end











