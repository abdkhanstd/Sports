function [rm rms rfr ratio ratio_u] = check_precision(found,actual) %ground truth
    %ymin ymax xmin xmax

f=[found(1) found(3) found(2)-found(1)+1 found(4)-found(3)];

a=[actual(1) actual(3) actual(2)-actual(1) actual(4)-actual(3)];

ratio=bboxOverlapRatio(a,f,'ratioType','Min');
ratio_u=bboxOverlapRatio(a,f,'ratioType','Union');



count_in=0;
count_out=0;
tot_c=0;
for x=found(3):found(4)
    for y=found(1):found(2)
        
        tot_c=tot_c+1;
            
        if (isitinside([x y],actual))
       
                count_in=count_in+1; %common area
        else
                count_out=count_out+1; %num of points not matching
        end
        
    end
end
    
% My brain is not working counting total via loop
total=0;
for x=actual(3):actual(4)
    for y=actual(1):actual(2)        
    total=total+1;
        end
    end



rm=count_in/total;
rms=1-rm;
rfr=1-count_in/tot_c;