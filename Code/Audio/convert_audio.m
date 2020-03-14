
data_folder='E:\videos\';
dest_folder='E:\audio_conv\';
for i=1:104


              source= strcat(data_folder,'vid',num2str(i),'.mp4')
              dest=[dest_folder,'vid_loud',num2str(i),'.mp3'];
              command= sprintf('ffmpeg -i %s -vn -acodec mp3 %s',source,dest)
              %command= sprintf('ffmpeg -i %s -ss 0 -t 3000 -vn -acodec copy %s',source,dest)
              %command= sprintf('ffmpeg -i %s -ss 2640 -t 600 -vn -acodec mp3 %s',source,dest)

              system(command)
              
              
%              ffmpegtranscode(source, dest, 'AudioCodec', 'aac', 'VideoCodec', 'x264');

end