function ret = isitinside(centroid,region)



%%----------------------------------------------------------------------
% Video Path      Actual Starting Time             Scorebox      
%                                          [ X_min Y_min x_max  y_max]
%%----------------------------------------------------------------------


% x_min=region(1);
% y_min=region(2);
% x_max=region(3);
% y_max=region(4);

x_min=region(3);
y_min=region(1);
x_max=region(4);
y_max=region(2);



if (centroid(1)>=x_min && centroid(1)<=x_max) && (centroid(2)>=y_min && centroid(2)<=y_max)
    ret = 1;
else
    ret=0;
end