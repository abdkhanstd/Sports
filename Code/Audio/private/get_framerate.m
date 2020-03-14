function [fs0,T] = get_framerate(infile)
% GETFRAMERATE   Extract (average) frame rate of the video
%   [Fs0,T] = GETFRAMERATE(INFILE)

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

info = ffmpeginfo(infile);
found = false;
for m = 1:numel(info)
   s = info(m).streams;
   for n = 1:numel(s)
      found = strcmp(s(n).type,'video');
      if found
         break;
      end
   end
end
if ~found
   error('Input file does not contain any video stream.');
end

c = s(n).codec;
if isempty(c.fps)
   if isempty(c.tbr)
      if isempty(c.tbn)
         if isempty(c.tbc)
            error('Input file does not report its frame rate.');
         else
            fs0 = c.tbc;
         end
      else
         fs0 = c.tbn;
      end
   else
      fs0 = c.tbr;
   end
else
   fs0 = c.fps;
end

if nargout>1
   T = info(m).duration;
end

end
