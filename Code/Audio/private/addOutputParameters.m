function addOutputParameters(p,defvals,altlist,optacodecs,optvcodecs)
%ADDOUTPUTPARAMETERS   Add parameters to the inputParser object to
%allow FFMPEG output options in the parameter name-value pairs.
%
%   addOutputParameters(p,defvals,altlist)
%
%   altlist - a cell array of string, possibly {±all, ±audio, ±video,
%   ±{optname}} Leading + indicates inclusion, leading - indicates
%   exclusion. If leading sign is missing, it assumes exclusion. The items
%   are processed in a sequential order. 'audio' and 'video' removes all
%   options exclusively related to audio or video, respectively.
%
%   optacodecs - optional audio codec names
%   optvcodecs - optional video codec names
%
%Followoutg fields of OPTIONS are processed:
%
%      Name    Description
%      ====================================================================
%      AudioCodec       [none|{copy}|wav|mp3|aac]
%                       Audio codec. If 'none', audio data would not be
%                       transcoded.
%      AudioSampleRate  Positive scalar
%                       Output audio sampling rate in samples/second.
%                       Only specify if needed to be changed.
%      Mp3Quality       Integer scalar between 0 and 9 {[]}
%                       MP3 encoder quality setting. Lower the higher
%                       quality. Empty uses the FFmpeg default.
%      AacBitRate       Integer scalar.
%                       AAC encoder's target bit rate in b/s. Suggested to
%                       use 64000 b/s per channel.
%      VideoCodec       [none|copy|raw|mpeg4|{x264}|gif]
%                       Video codec. If 'none', video data would not be
%                       transcoded.
%      OutputFrameRate  Positive scalar
%                       Output video frame rate in frames/second.
%      PixelFormat      One of format string returned by FFMPEGPIXFMTS
%                       Pixel format. Default to 'yuv420p' for Apple
%                       QuickTime compatibility if VideoCodec = 'mpeg4' or
%                       'x264' or to 'bgr24' if VideoCodec = 'raw'.
%      x264Preset       [ultrafast|superfast|veryfast|faster|fast|medium|slow|slower|veryslow|placebo]
%                       x264 video codec options to trade off compression
%                       efficiency against encoding speed.
%      x264Tune         film|animation|grain|stillimage|psnr|ssim|fastdecode|zerolatency
%                       x264 video codec options to further optimize for
%                       input content.
%      x264Crf          Integer scaler between 1 and 51 {18}
%                       x264 video codec constant rate factor. Lower the
%                       higher quality, and 18 is considered perceptually
%                       indistinguishable to lossless. Change by ±6 roughly
%                       doubles/halves the file size.
%      Mpeg4Quality     Integer scalar between 1 and 31 {1}
%                       Mpeg4 video codec quality scale. Lower the higher
%                       quality
%      GifLoop          ['off'|{'indefinite'}|positive integer]
%                       Number of times to loop
%      GifFinalDelay    [{'same'}|nonnegative value]
%                       Force the delay (expressed in seconds) after the
%                       last frame. Each frame ends with a delay until the
%                       next frame. If 'same', FFmpeg re-uses the previous
%                       delay. In case of a loop, you might want to
%                       customize this value to mark a pause for instance.
%      GifPaletteStats  [{'full'}|'diff']
%                       Palette is generated based on pixel color
%                       statistics from ('full') every pixels evenly or
%                       ('diff') weighs more on the pixels where changes
%                       occur. Use 'diff' if animation is overlayed on a
%                       still image.
%      GifDither        ['bayer'|'heckbert'|'floyd_steinberg'|'sierra2'|{'sierra2_4a'}]
%                       Dithering algorithm
%      GifDitherBayerScale [0-5] 
%                       Reduce or increase crosshatch patter when Bayer
%                       dithering algorithm is used.
%      GifDitherZone    [{'off'},'rectangle']
%                       Using 'rectangle' option limits re-dithering on a
%                       rectangle section of a frame where motion occurs.
%      Filters          [Array of ffmpegfilters]
%                       A filtergraph to filter the output. If it is a
%                       simple filterchain, simply provide an array of
%                       unlinked ffmpegfilters without head or tail
%                       ffmpegfilter objects. The filters will be applied
%                       in the order as appears in the array. For a more
%                       complex filtergraph, the array must include one
%                       ffmpegfilter.head object and one ffmpegfilter.tail
%                       and its elements must be all linked together.
%      OutputCustomOptions A valid ffmpeg option struct.
%                       To directly specify the options.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

if nargin<4 || isempty(optacodecs)
   optacodecs = {'none','copy','wav','mp3','aac'};
else
   if isempty(altlist), altlist = {}; end
   if ~any(strcmpi(optacodecs,'mp3'))
      altlist{end+1} = '-Mp3Quality';
   end
   if ~any(strcmpi(optacodecs,'aac'))
      altlist{end+1} = '-AacBitRate';
   end
end

if nargin<5 || isempty(optvcodecs)
   optvcodecs = {'none','copy','raw','mpeg4','x264','gif'};
else % if optvcodecs specified
   if isempty(altlist), altlist = {}; end
   if ~any(strcmpi(optvcodecs,'mpeg4')) % no mpeg4 codec, remove associated options
      altlist{end+1} = '-Mpeg4Quality';
   end
   if ~any(strcmpi(optvcodecs,'x264')) % no x264 codec, remove associated options
      altlist{end+1} = '-x264Preset';
      altlist{end+1} = '-x264Tune';
      altlist{end+1} = '-x264Crf';
   end
   if ~any(strcmpi(optvcodecs,'gif')) % no gif format, remove associated options
      altlist{end+1} = '-GifLoop';
      altlist{end+1} = '-GifFinalDelay';
      altlist{end+1} = '-GifPaletteStats';
      altlist{end+1} = '-GifDither';
      altlist{end+1} = '-GifDitherBayerScale';
      altlist{end+1} = '-GifDitherZone';
   end
end

args = {
   'AudioCodec',   'copy',    @(val)iscodec(val,'audio','encoder',optacodecs)
   'OutputSampleRate', [],    @isposintorratio
   'Mp3Quality',      [],     @(v)validateattributes(v,{'numeric'},{'scalar','integer','>=',0,'<',10})
   'AacBitRate',      [],     @(v)validateattributes(v,{'numeric'},{'scalar','positive','finite'})
   'VideoCodec',   'copy',    @(val)iscodec(val,'video','encoder',optvcodecs)
   'OutputFrameRate', [],     @isframerate
   'PixelFormat',     [],     @ispixfmt
   'x264Preset',      '',     @(v)any(strcmpi(v,{'ultrafast' 'superfast' 'veryfast' 'faster' 'fast' 'medium' 'slow' 'slower' 'veryslow' 'placebo'}))
   'x264Tune',        '',     @(v)any(strcmpi(v,{'film' 'animation' 'grain' 'stillimage' 'psnr' 'ssim' 'fastdecode' 'zerolatency'}))
   'x264Crf',         18,     @(v)validateattributes(v,{'numeric'},{'scalar','integer','>',0,'<',52})
   'Mpeg4Quality',    1,      @(v)validateattributes(v,{'numeric'},{'scalar','integer','>',0,'<',32})
   'GifLoop',         [],     @isgifloop
   'GifFinalDelay',   [],     @isgiffinaldelay
   'GifPaletteStats', [],     @(v)isvalidfilteropt('palettegen','stats_mode',v)
   'GifDither',       [],     @(v)isvalidfilteropt('paletteuse','dither',v)
   'GifDitherBayerScale',[],  @(v)isvalidfilteropt('paletteuse','bayer_scale',v)
   'GifDitherZone',   [],     @(v)isvalidfilteropt('paletteuse','diff_mode',v)
   'Filters',         [],     @(v)isa(v,'ffmpegfilter.base')
   'OutputCustomOptions', [], @(){}
   };

if nargin>1 && ~isempty(defvals) % add default values
   [tf,I] = ismember(defvals(:,1),args(:,1));
   for n = find(tf)'
      args{I(n),2} = defvals{n,2};
   end
end

if nargin>2 && ~isempty(altlist)
   excopts = false(size(args,1),1);
   for n = 1:numel(altlist)
      cmd = altlist{n};
      if cmd(1)=='+'
         cmd(1) = [];
         exc = false;
      else
         if cmd(1)=='-'
            cmd(1) = [];
         end
         exc = true;
      end
      if strcmpi(cmd,'all')
         excopts(:) = exc;
      elseif strcmpi(cmd,'audio')
         excopts(1:4) = exc;
      elseif strcmpi(cmd,'video')
         excopts(5:11) = exc;
      else
         excopts(strcmpi(args(:,1),cmd)) = exc;
      end
   end
   
   args(excopts,:) = [];
end

for n = 1:size(args,1)
   p.addParameter(args{n,:});
end
end

function tf = isgifloop(val)

if ischar(val)
   validatestring(val,{'off','indefinite'});
else
   validateattributes(v,{'numeric'},{'scalar','positive','finite','integer'});
end
tf = true;

end

function tf = isgiffinaldelay(val)
if ischar(val)
   validatestring(val,{'same'});
else
   validateattributes(v,{'numeric'},{'scalar','nonnegative','finite'});
end
tf = true;
end

function tf = isvalidfilteropt(filter,name,val)
f = ffmpegfilter.(filter);
try
   f.(name) = val;
   tf = true;
catch ME
   delete(f)
   rethrow(ME);
end

end
