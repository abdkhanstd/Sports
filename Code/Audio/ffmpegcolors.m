function info = ffmpegcolors()
%FFMPEGCOLORS   Predefined FFMPEG color names
%   FFMPEGCOLORS displays 
%   COLORS = FFMPEGCOLORS returns the names and RGB values of the
%   predefined colors in FFMPEG.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(0,0);

% run FFmpeg
[s,msg] = system([ffmpegpath() ' -colors']);

if s==0 && isempty(msg)
   error('ffmpegpixfmts failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'name\s+#RRGGBB','start','once');
if isempty(I)
   error('Incompatible FFmpeg version.');
end
msg(1:I-1) = [];

if nargout<1 % no output argument, just display the ffmpeg output
   disp(msg);
   return;
end

% skip the preamble
msg(1:regexp(msg,'name                             #RRGGBB\n','end','once')) = [];

% scan each line
info = regexp(msg,'(?<name>\S+)\s+\#(?<rgb>[a-z0-9]{6})\n','names');

val = arrayfun(@(el)hex2dec({el.rgb([1 2]) el.rgb([3 4]) el.rgb([5 6])})'/255,info,'UniformOutput',false);
[info.rgb] = deal(val{:});
