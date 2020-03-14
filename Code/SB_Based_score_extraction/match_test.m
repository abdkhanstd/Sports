clear
clc

show=0;
th_points=2;
im_a=imread('1.jpg');
im_b=imread('2.jpg');

[im_r im_c]=size(im_a);

% windows size (can be any)
win_r=60; % row 
win_c=60; % col

Total_grids=0;
grid_rows=0;
grid_cols=0;

temp=uint8(zeros(im_r,im_c));

% Need padding
padding=uint8(zeros(im_r+win_r,im_c+win_c));
padding(1:im_r,1:im_c)=im_a(1:im_r,1:im_c);
im_a=padding;

padding=uint8(zeros(im_r+win_r,im_c+win_c));
padding(1:im_r,1:im_c)=im_b(1:im_r,1:im_c);
im_b=padding;

map=uint8(zeros(im_r,im_c));

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
        
        next_frame_surf_features = detectSURFFeatures(content_a);
        curr_frame_surf_features = detectSURFFeatures(content_b);
        
        
        [next_frame_extracted_features, next_frame_surf_features] = extractFeatures(content_a, next_frame_surf_features);
        [curr_frame_extracted_features, curr_frame_surf_features] = extractFeatures(content_a, curr_frame_surf_features);
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
            else
                
            end
        end
        

        if show==1
           pause(0.5)        
        end
    end
    Total_grids=Total_grids+1;
        
   
    
    
    %reset y
    ite_y=0;
end

% Filling the holes in the matched grid
ite_x=0;
ite_y=0;

for i=1:im_r
    ite_x=ite_x+1;
     s_row=map(i,:);
    for j=1:win_c:im_c
        ite_y=ite_y+1;
  
        % First run
        if j==1
            items_in_window_next=s_row(1,j+win_c:(ite_y+1)*win_c);
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
        elseif j<im_c-(4*win_r)
            items_in_window_prev=s_row(1,j-win_c:(ite_y-1)*win_c);
            items_in_window_next=s_row(1,j+win_c:(ite_y+1)*win_c);
            items_in_window_current=s_row(1,j:ite_y*win_c);
            
            
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
       fprintf('p=%d, c=%d,n=%d\n',p,c,n);
       if (p==1 && c==0 && n==1)           
         map(i,j:ite_y*win_c)=255;  
       end
    
        
        
    end
    %reset y
    ite_y=0;
end


figure(2);
im_a=imread('1.jpg');
map=uint8(imbinarize(map(1:im_r,1:im_c)));
imshow(map.*im_a);



















