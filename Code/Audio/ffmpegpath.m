function ffmpegexe = ffmpegpath
%FFMPEGPAT   Returns the FFMPEG exe path

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (05-15-2013) original release
% rev. 1 : (04-23-2014)
%          * If deployed, expect ffmpeg to be found in the app folder or in
%            the system path

if isdeployed()
   ffmpegexe = 'ffmpeg'; % assume ffmpeg executable is in the same folder or in the system path
elseif ispref('ffmpeg','exepath')
   ffmpegexe = getpref('ffmpeg','exepath');
else
   error('FFMPEG path not set. Run ffmpegsetup first.');
end
