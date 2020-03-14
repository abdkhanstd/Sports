function ffmpegsetup
%FFMPEGSETUP   Set up FFmpeg Toolbox
%   Run FFMPEGSETUP before using FFmpeg Toolbox for the first time. User
%   will be asked for the location of FFmpeg executable (binary) if it
%   cannot be located automatically.

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (06-19-2013) original release

% dlgtitle = 'FFMPEG Toolbox Setup';
% ffmpegdir = fileparts(which(mfilename));

% get existing config
if ispref('ffmpeg','exepath')
   ffmpegexe = getpref('ffmpeg','exepath');
else
   ffmpegexe = '';
end

% first check if it is arleady in the system path (should be the case for
% both linux & mac
ffmpegnames = 'ffmpeg';
[fail,~] = system([ffmpegnames ' -v']);
if ~fail
   ffmpegexe = ffmpegnames;
   setpref('ffmpeg','exepath',ffmpegexe); % save for later
   return;
end

% if not found, ask user for the location of the file
switch lower(computer)
   case {'pcwin' 'pcwin64'}
      filter = {'ffmpeg.exe','FFMPEG EXE file';'*.exe','All EXE files (*.exe)'};
   otherwise % linux/mac
      filter = {'*','All files'};
end

[filename, pathname] = uigetfile(filter,'Locate FFMPEG executable file',ffmpegexe);
if numel(filename)>0 && filename(1)~=0 % cancelled
   ffmpegexe = fullfile(pathname,filename);
   if any(ffmpegexe==' '), ffmpegexe = ['"' ffmpegexe '"']; end
   
   % try
   [fail,msg] = system([ffmpegexe ' -version']);
   if fail || isempty(regexp(msg,'^ffmpeg','once'))
      ffmpegexe = '';
      disp('Invalid FFMPEG executable specified.');
   end
   
   setpref('ffmpeg','exepath',ffmpegexe);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ffmpeg = getpref('ffmpeg','exepath');
if isempty(ffmpeg)
   error('FFMPEG executable not found.');
else
   fprintf('   FFMPEG executable: %s\n',ffmpeg);
end
disp('   ...done.');
