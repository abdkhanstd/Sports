



score=data_score_{5};

% Converting and plotting data
% clean score


score_=[];
wkt_=[];
idx=[];

for i=1:size(score,2)
    
    sample=score{i};
    sample = strrep(sample,'o','0');
    sample = strrep(sample,'O','0');
    
    sample = strrep(sample,'A','');
    sample = strrep(sample,'B','');
    sample = strrep(sample,'C','');
    sample = strrep(sample,'D','');
    sample = strrep(sample,'E','');
    sample = strrep(sample,'F','');
    sample = strrep(sample,'G','');
    sample = strrep(sample,'H','');
    sample = strrep(sample,'I','');
    sample = strrep(sample,'K','');    
    sample = strrep(sample,'K','');
    sample = strrep(sample,'L','');
    sample = strrep(sample,'M','');
    sample = strrep(sample,'N','');    
    sample = strrep(sample,'P','');
    sample = strrep(sample,'Q','');    
    sample = strrep(sample,'R','');
    sample = strrep(sample,'S','');    
    sample = strrep(sample,'T','');
    sample = strrep(sample,'U','');    
    sample = strrep(sample,'V','');
    sample = strrep(sample,'W','');    
    sample = strrep(sample,'X','');
    sample = strrep(sample,'Y','');    
    sample = strrep(sample,'Z','');

    sample = strrep(sample,'a','');
    sample = strrep(sample,'b','');
    sample = strrep(sample,'c','');
    sample = strrep(sample,'d','');
    sample = strrep(sample,'e','');
    sample = strrep(sample,'f','');
    sample = strrep(sample,'g','');
    sample = strrep(sample,'h','');
    sample = strrep(sample,'i','');
    sample = strrep(sample,'j','');    
    sample = strrep(sample,'k','');
    sample = strrep(sample,'l','1');
    sample = strrep(sample,'m','');
    sample = strrep(sample,'n','');    
    sample = strrep(sample,'p','');
    sample = strrep(sample,'q','');    
    sample = strrep(sample,'r','');
    sample = strrep(sample,'s','');    
    sample = strrep(sample,'t','');
    sample = strrep(sample,'u','');    
    sample = strrep(sample,'v','');
    sample = strrep(sample,'w','');    
    sample = strrep(sample,'x','');
    sample = strrep(sample,'y','');    
    sample = strrep(sample,'z','');
    % Removing confusions    
    
    
    % Removing confusions   
    % Removing confusions
    
    
    % Divide streams
    
    
    stream{i}=split(sample,"/");
    
    
        if (str2num(stream{i}{1})>0)
        score_(i)=str2num(stream{i}{1});
        else
            if (i>1)
                score_(i)=score_(i-1);
            else
                 score_(i)=0;
            end
        end
        
        if (i>1)
            
                if (score_(i-1) > score_(i))
                    score_(i)=score_(i-1);
                end
        end
    
    if (size(stream{i},2) >1)
        wkt_(i)=str2num(stream{i}{2});
    end
    idx(i)=i;
    
    
    
    
end

plot(score_)
