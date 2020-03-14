function d = tracking(video)
if ischar(video)
    % Load the video from an avi file.
    avi = aviread(video);
    pixels = double(cat(4,avi(1:2:end).cdata))/255;
    clear avi
else
    % Compile the pixel data into a single array
    pixels = double(cat(4,video{1:2:end}))/255;
    clear video
end

% Convert to RGB to GRAY SCALE image.
nFrames = size(pixels,4);
for f = 1:nFrames

%     F = getframe(gcf);
%     [x,map]=frame2im(F);
%     imwrite(x,'fln.jpg','jpg');
% end
    pixel(:,:,f) = (rgb2gray(pixels(:,:,:,f)));  
end
rows=240;
cols=320; 
nrames=f;
for l = 2:nrames
d(:,:,l)=(abs(pixel(:,:,l)-pixel(:,:,l-1)));

k=d(:,:,l);
% imagesc(k);
% drawnow;
% himage = imshow('d(:,:,l)');
% hfigure = figure;
% impixelregionpanel(hfigure, himage);

% datar=imageinfo(imagesc(d(:,:,l)));
% disp(datar);


   bw(:,:,l) = im2bw(k, .2);
   
   bw1=bwlabel(bw(:,:,l));
   imshow(bw(:,:,l))
   hold on
   
% %    for h=1:rows
%     for w=1:cols
%                         
%             if(d(:,:,l)< 0.1)
%                  d(h,w,l)=0;
%            end
%     end
%   
% end
   
% % disp(d(:,:,l));
% % size(d(:,:,l))
cou=1;
for h=1:rows
    for w=1:cols
     if(bw(h,w,l)>0.5)
        
        
%          disp(d(h,w,l));
      toplen = h;
      
             if (cou == 1)
            tpln=toplen;
           
        end
         cou=cou+1;
      break
     end
     
    end
end

disp(toplen);

coun=1;
for w=1:cols
    for h=1:rows
     if(bw(h,w,l)>0.5)
        
      leftsi = w;
      
    
   if (coun == 1)
            lftln=leftsi;
            coun=coun+1;
   end
      break
     end
     
    end
end

disp(leftsi);
 disp(lftln);   

 % % drawnow;
% %    d = abs(pixel(:, :, l), pixel(:, :, l-1));
% %    disp(d);
   
%    s = regionprops(bw1, 'BoundingBox');
% %    centroids = cat(1, s.Centroid);
% 
% %    ang=s.Orientation;
%    
% %    plot(centroids(:,1), centroids(:,2), 'r*')
%    for r = 1 : length(s)   
%    rectangle('Position',s(r).BoundingBox,'EdgeColor','r');
% 
% %   plot('position',s(r).BoundingBox,'faceregion','r');
%    end   
%    

% %    disp(ang);
%  %  imaqmontage(k);

widh=leftsi-lftln;
heig=toplen-tpln;

widt=widh/2;
disp(widt);
heit=heig/2;
with=lftln+widt;
heth=tpln+heit;
wth(l)=with;
hth(l)=heth;

disp(heit);
disp(widh);
disp(heig);
rectangle('Position',[lftln tpln widh heig],'EdgeColor','r');
disp(with);
disp(heth);
plot(with,heth, 'r*');
drawnow;
hold off

end;
% wh=square(abs(wth(2)-wth(nrames)));
% ht=square(abs(hth(2)-hth(nrames)));
% disp(wth(1
% distan=sqrt(wh+ht);
% 
% disp(distan);


