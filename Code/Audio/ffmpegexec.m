function r = ffmpegexec(optstr)
%FFMPEGEXEC   Run FFMPEG with custom option argument
%   FFMPEGEXEC('OptionString') run FFmpeg using the options given in
%   OptionString argument.
%
%   References:
%      FFmpeg Home
%         http://ffmpeg.org
%      FFmpeg Documentation
%         http://ffmpeg.org/ffmpeg.html
%      FFmpeg Wiki Home
%         http://ffmpeg.org/trac/ffmpeg/wiki
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (10-24-2013) original release

narginchk(0,1);

% start constructing the command line
cmd = sprintf('%s', ffmpegpath());

if nargin>0 && ~isempty(optstr)
   if ~(ischar(optstr)&&isrow(optstr))
      error('OptionString must be a string of characters.');
   end
   cmd = sprintf('%s %s',cmd,optstr);
end

if nargout>0
   [s,r] = system(cmd); % intercepts command's output stream
   if nargin>0 && s~=0
      % if failed, report the error
      error('%s\n\n%s',cmd,r);
   end
else
   system(cmd);
end
