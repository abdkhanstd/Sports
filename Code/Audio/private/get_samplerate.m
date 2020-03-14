function [fs0,T] = get_samplerate(infile)
% Returns sample rate of the first audio stream in INFILE

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

info = ffmpeginfo(infile);
found = false;
for m = 1:numel(info)
   s = info(m).streams;
   for n = 1:numel(s)
      found = strcmp(s(n).type,'audio');
      if found
         break;
      end
   end
end
if ~found
   error('Input file does not contain any audio stream.');
end

fs0 = s(n).codec.samplerate;
if isempty(fs0)
   error('Input file''s audio stream does not specify sampling rate.');
end

if nargout>1
   T = info(m).duration;
end

end
