% simple script to use ffmpeg to convert wma files to mp3
% 
% wanted to be able to play my music on iPod, so I wrote this to convert my files
%
% based on WinFF program, which is a frontend for FFMPEG
% WinFF: http://biggmatt.com/winff/
% FFMPEG: http://ffmpeg.mplayerhq.hu/
%
% Written for an installation of WinFF. I haven't tried just installing ffmpeg.
%	WinFF installs ffmpeg into it's directory.
%
% Use:
% put this script in main music directory (i.e. ...\My Music\)
% then run and it will look through all subdirs and convert any wma files to mp3
% deletes wma file after conversion
% 
% defaults:
%	convert to: mp3
%	bitrate = 160k'	
%	numchannels = 2
%	sample rate = 44100
%
%
% I know this is probably lame and written horribly, but it works and didn't take me any time.
% Kind of embarrassed to post it, but maybe it'll be useful to someone...



% WinFF directory to find FFMPEG.exe
path_ffmpeg = '"C:\Program Files\WinFF\ffmpeg.exe"';


% scan through all subdirectories and find all wma files
% add files to structure
a.file_mp3 = {''};
a.file_wma = {''};
a.dir = {''};
while 1;
	dirlist = dir;
	numlist = numel(dirlist);
	path_curr = cd;
	for m = 3:numlist	% skip . & ..
		if dirlist(m).isdir == 0	% file
			if strcmpi(dirlist(m).name(end-2:end),'wma')
				path_wma = ['"',path_curr,'\',dirlist(m).name,'"'];
				a.file_wma = [a.file_wma,path_wma];
				% change path/name from .wma to .mp3
				path_mp3 = path_wma;
				path_mp3(end-3:end-1) = 'mp3';
				a.file_mp3 = [a.file_mp3,path_mp3];
			end
		else						% directory
			path_dir = [path_curr,'\',dirlist(m).name];
			a.dir = [a.dir,path_dir];
		end
	end
	if numel(a.dir) > 1
		cd(a.dir{end});
		a.dir(end) = [];
	else
		break
	end
end
	


% convert all wma files found above	to mp3, then delete wma
options = ' -acodec mp3 -ab 160k -ac 2 -ar 44100 ';
for m = 2:numel(a.file_wma)	% 1st one is blank
	dos([path_ffmpeg,' -i ',a.file_wma{m},options,a.file_mp3{m}]);
	delete(a.file_wma{m}(2:end-1));	% have to remove quotes - not sure why...
end

