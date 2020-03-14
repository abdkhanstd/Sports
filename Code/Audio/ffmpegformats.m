function info = ffmpegformats()
%FFMPEGFORMATS   Retrieves FFMpeg supported formats
%   FFMPEGCODECS() displays all the supported formats.
%
%   S = FFMPEGCODECS() returns struct array S containing the supported
%   formats. The sturct fields are: name, description, demux, and mux
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(0,0);

% run FFmpeg
[s,msg] = system([ffmpegpath() ' -formats']);

if s==0 && isempty(msg)
   error('ffmpegpixfmts failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'File formats:','start','once');
if isempty(I)
   error('Incompatible FFmpeg version.');
end
msg(1:I-1) = [];

if nargout<1 % no output argument, just display the ffmpeg output
   disp(msg);
   return;
end

% skip the preamble
msg(1:regexp(msg,'--\n','end','once')) = [];

% scan each line
info = regexp(msg,'(?<demux>[D\ ])(?<mux>[E\ ])\s+(?<name>\S+)\s+(?<description>[^\n]+)\n','names');

% convert flags to logical
val = arrayfun(@(el)el.demux=='D',info,'UniformOutput',false);
[info.demux] = deal(val{:});

val = arrayfun(@(el)el.mux=='E',info,'UniformOutput',false);
[info.mux] = deal(val{:});

% reorder the fields so they are presented in more logical way
info = orderfields(info,[3 4 1 2]);
