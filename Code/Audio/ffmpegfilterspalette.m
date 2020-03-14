function f = ffmpegfilterspalette(genopts,useopts,varargin)
%FFMPEGFILTERSPALETTE   Get a FFmpeg filter graph to decimate # of colors
%   FFMPEGFILTERSPALETTE() returns ffmpegfilter array which is configured
%   as a SISO filter graph consisting of split, palettegen, and paletteuse
%   filters.
%
%   FFMPEGFILTERSPALETTE(GENOPTS) sets palettegen options as given in
%   GENOPTS struct. See ffmpegfilter.palettegen for available options.
%
%   FFMPEGFILTERSPALETTE(GENOPTS,USEOPTS) sets paletteuse options as given
%   in USEOPTS struct. See ffmpegfilter.paletteuse for available options.
%
%   FFMPEGFILTERSPALETTE(..., '-addhead') prepends ffmpegfilter.head to the
%   generated filter graph.
%
%   FFMPEGFILTERSPALETTE(..., '-addtail') appends ffmpegfilter.tail to
%   the generated filter graph

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(0,4);

% create filters
f = [
   ffmpegfilter.split
   ffmpegfilter.palettegen
   ffmpegfilter.paletteuse
   ];

try
   % set palettegen options
   if nargin>0 && ~isempty(genopts)
      fnames = fieldnames(genopts);
      for n = 1:numel(fnames)
         fname = fnames{n};
         f(2).(fname) = genopts.(fname);
      end
   end
   
   
   % set paletteuse options
   if nargin>1 && ~isempty(useopts)
      fnames = fieldnames(useopts);
      for n = 1:numel(fnames)
         fname = fnames{n};
         f(3).(fname) = useopts.(fname);
      end
   end
   
   % link filters
   link(f([1 2]),f(3),{'PU_V','PG_PU'},false);
   link(f(1),f(2),'PG_V',true);
   
   if nargin>2 && any(strcmp(varargin,'-addhead'))
      f = [ffmpegfilter.head;f];
      link(f(1),f(2));
   end
   
   if nargin>2 && any(strcmp(varargin,'-addtail'))
      f = [f;ffmpegfilter.tail];
      link(f(end-1),f(end));
   end
   
catch ME
   delete(f)
   rethrow(ME);
end
