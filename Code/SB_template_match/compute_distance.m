function [d]= compute_distance(x,y)

    
    diff=x-y;
    sqr=diff.^2;
    sum_=sum(sqr);
    
    d=sqrt(sum_);
