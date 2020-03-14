% Obtaining templates from all videos

function [bool xoffSet yoffSet]=isitthere(template,image)


     image_=(image);
     c = normxcorr2(template,image_);
 

     [ypeak, xpeak] = find(c==max(c(:)));

     yoffSet = ypeak-size(template,1);
     xoffSet = xpeak-size(template,2);
                            
     if  max(max(c)) > 0.55
          bool=1;

     else
                            
          bool=0;
                           
     end
%      
%      
%      pos_rect=[abs(xoffSet+1), abs(yoffSet+1), size(template,2), size(template,1)]
%      newimage = image(pos_rect(2) + (0:pos_rect(4)), pos_rect(1) + (0:pos_rect(3)),:);
%      
newimage=0;

