

pre=[];
miss=[];
fr=[];
recall=[];
recall=0;

for i=start_video_processing_from:end_video_processing_from





[a b c r r_u]=check_precision(detected_region_coordinates{i},Video_Data{i,3});
    fprintf('precision video #:%d precision:%s  missrate: %s falserate:%s Iou: %s \n',i,num2str(a),num2str(b),num2str(c),num2str(r));
    data(i,1)=a;
    miss(i,1)=b;
    fr(i,1)=c;
    rr(i,1)=r;
    rr_u(i,1)=r_u;

if a>.85
    recall=recall+1;
end

end

mean(data);
mean(miss);
mean(fr);

fprintf('\n mAP: %s,Mean Miss Rate: %s, Mean False rate: %s recall:%s Mean IOU=%s IOU_Union=%s\n ',num2str(mean(data)),num2str(mean(miss)),num2str(mean(fr)),num2str(recall/104),num2str(mean(rr)),num2str(mean(rr_u)));
