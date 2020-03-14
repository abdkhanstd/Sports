
close all
clc

load ours_data_ok;

b=bar(a(:,1),'stacked')
hold on;
b=bar(a(:,2),'stacked')
b=bar(a(:,3),'stacked')



l{1}='GTTR';
l{2}='DTR'
l{3}='NTR'


hleg=legend(l);

x0=0;
y0=0;
width=650;
height=220
set(gcf,'position',[x0,y0,width,height])
set(gca, 'FontName', 'Times new roman');
set(gca,'FontSize',8)

ylabel('Number of text regions')
xlabel('Video ID')
