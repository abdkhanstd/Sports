function ret = compute_derivative(a)

        current=a;
        last=a;
        
        [r c]=size(a);
        last=zeros(r,c);
        last(1:r-1,:)=current(2:r,:);
        ret_=(last-current);
        ret_(r,:)=0;
        ret=ret_;