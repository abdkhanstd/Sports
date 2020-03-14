%clear

load record


% Actual events % detected events  % accucacy
for i=1:104

    
    if record(i,1) < record(i,2)
            record(i,3)=1;
    
    elseif record(i,1)==0 && record(i,2)==0 
           record(i,3)=1;

    else
        record(i,3)=record(i,2)/record(i,1);
    end
    
    
    
    
end
mean(record(:,3))

