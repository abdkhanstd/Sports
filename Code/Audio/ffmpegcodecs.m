function info = ffmpegcodecs()
%FFMPEGCODECS   Retrieves FFMpeg supported codecs
%   FFMPEGCODECS() displays all the supported codecs.
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(0,0);

% run FFmpeg
[s,msg] = system([ffmpegpath() ' -codecs']);

if s==0 && isempty(msg)
   error('ffmpegpixfmts failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'Codecs:','start','once');
if isempty(I)
   error('Incompatible FFmpeg version.');
end
msg(1:I-1) = [];

if nargout<1 % no output argument, just display the ffmpeg output
   disp(msg);
   return;
end

% skip the preamble
msg(1:regexp(msg,'-------\n','end','once')) = [];

% scan each line
info = regexp(msg,'(?<decoder>[D\.])(?<encoder>[E\.])(?<type>[VAS])(?<intraframe>[I\.])(?<lossy>[L\.])(?<lossless>[S\.])\s+(?<name>\S+)\s+(?<description>[^\n]+)\n','names');

% convert flags to logical
val = arrayfun(@(el)el.decoder=='D',info,'UniformOutput',false);
[info.decoder] = deal(val{:});

val = arrayfun(@(el)el.encoder=='E',info,'UniformOutput',false);
[info.encoder] = deal(val{:});

val = arrayfun(@(el)validatestring(el.type,{'video','audio','subtitle'}),info,'UniformOutput',false);
[info.type] = deal(val{:});

val = arrayfun(@(el)el.intraframe=='I',info,'UniformOutput',false);
[info.intraframe] = deal(val{:});

val = arrayfun(@(el)el.lossy=='L',info,'UniformOutput',false);
[info.lossy] = deal(val{:});

val = arrayfun(@(el)el.lossless=='S',info,'UniformOutput',false);
[info.lossless] = deal(val{:});

% reorder the fields so they are presented in more logical way
info = orderfields(info,[7 3 8 1 2 4 5 6]);
