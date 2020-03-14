%clear

%load record


% 03 = TP, 04= FP (missed), 05=FN (wrong detection),06 =P,07 =P

% Actual events % detected events  % accucacy
for i=1:104

    
    % Calculating true positives
    if record(i,1) > record(i,2)
            record(i,3)=record(i,2);
            record(i,4)=abs(record(i,2)-record(i,1));
            record(i,5)=0;
    
    else
        record(i,3)=record(i,1);
        record(i,4)=0;
        record(i,5)=abs(record(i,2)-record(i,1));
    end
    
    if record(i,2)==0
    
    
    
    end
    
    P=record(i,3)/(record(i,3)+record(i,4));
    record(i,6)=P;
    
    R=record(i,3)/(record(i,3)+record(i,5));
    record(i,7)=R; 
    
    if record(i,2)==0
    
        record(i,7)=1;
    
    end
    
    
end

% Remove NaN
idx=find(isnan(record)==1);
record(idx)=1;
mean(record(:,6))
mean(record(:,7))

