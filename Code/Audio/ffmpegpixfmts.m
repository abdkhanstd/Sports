function info = ffmpegpixfmts()
%FFMPEGPIXFMTS   Retrieves FFMpeg supported video pixel formats
%   FFMPEGPIXFMTS() without any output argument displays the supported
%   pixel formats directly from FFmpeg output.
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (06-15-2013) original release

narginchk(0,0);

% run FFmpeg
[s,msg] = system([ffmpegpath() ' -pix_fmts']);

if s==0 && isempty(msg)
   error('ffmpegpixfmts failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'Pixel formats:','start','once');
if isempty(I)
   error('Incompatible FFmpeg version.');
end
msg(1:I-1) = [];

if nargout<1 % no output argument, just display the ffmpeg output
   disp(msg);
   return;
end

info = regexp(msg(I+1:end),['(?<input>[I\.])(?<output>[O\.])(?<hwaccel>[H\.])'...
   '(?<paletted>[P\.])(?<bitstream>[B\.]) (?<name>\S+)\s+'...
   '(?<Ncomponents>\d+)\s+(?<bpp>\d+)'],'names');

fnames = fieldnames(info);
info = struct2cell(info.');
info(1,:) = cellfun(@(s)strcmp(s,'I'),info(1,:),'UniformOutput',false);
info(2,:) = cellfun(@(s)strcmp(s,'O'),info(2,:),'UniformOutput',false);
info(3,:) = cellfun(@(s)strcmp(s,'H'),info(3,:),'UniformOutput',false);
info(4,:) = cellfun(@(s)strcmp(s,'P'),info(4,:),'UniformOutput',false);
info(5,:) = cellfun(@(s)strcmp(s,'B'),info(5,:),'UniformOutput',false);
info([7 8],:) = cellfun(@(s)str2double(s),info([7 8],:),'UniformOutput',false);

I = [6:8 1:5];
[~,J] = sort(info(6,:));
info = cell2struct(info(I,J),fnames(I),1);

end
