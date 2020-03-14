function ffmpegimages2video(varargin)
%FFMPEGIMAGES2VIDEO   Create video file from a series of images
%   FFMPEGIMAGES2VIDEO(INFILE_PATTERN,OUTFILE) takes the image files
%   specified by the pattern string INFILE_PATTERN and creates a H.264
%   video file with the name specified by OUTFILE.
%
%   The pattern string must specify a sequential index. INFILE_PATTERN
%   may contain the string '%d' or '%0Nd', which specifies the position of
%   the characters representing a sequential number in each filename
%   matched by the pattern. If the form "%d0Nd" is used, the string
%   representing the number in each filename is 0-padded and N is the total
%   number of 0-padded digits representing the number. The literal
%   character '%' can be specified in the pattern with the string '%%'.
% 
%   If INFILE_PATTERN contains "%d" or "%0Nd", the first filename of the
%   file list specified by the pattern must contain a number inclusively
%   contained between 0 and 4, and all the following numbers must be
%   sequential. To change this default behavior, set InputStartNumber
%   option.
%   
%   The format of the image files is automatically determined from the
%   extension of the files. Use InputPixelFormat option to force a format.
%
%   FFMPEGIMAGES2VIDEO(INFILE_PATTERN,OUTFILE,'OptionName1',OptionValue1,'OptionName2',OptionValue2,...)
%   may be used to customize the FFmpeg configuration:
%
%      Name    Description
%      ====================================================================
%      InputVideoCodec  valid FFMPEG codec name (not validated)
%      InputFrameRate   Positive scalar
%                       Input video frame rate in frames/second. Altering
%                       the input frame rate effectively slows down or
%                       speeds up the video. This option is only valid for
%                       raw video format. Note that when both
%                       InputFrameRate and Range (with Units='seconds') are
%                       specified, Range is defined in the original frame
%                       rate.
%      InputPixelFormat One of format string returned by FFMPEGPIXFMTS
%                       Pixel format.
%      InputFrameSize   Used only if the media file does not store the
%                       frame size. 2 element [w h].
%      InputAudioCodec  One of valid codec string (not validated)
%                       Input audio codec. If 'none', audio data would not be
%                       transcoded.
%      InputSampleRate  Positive scalar
%                       Input audio sampling rate in samples/second.
%                       Only specify if needed to be changed.
%      InputLoop        ['on'|{'off'}]
%                       If set to 'on', loop over the input. 
%      InputPatternType [{'sequence'}|'glob'] 
%                       Select the pattern type used to interpret the
%                       provided filename.
%      InputStartNumber [a pair nondecreasing nonnegative integers] {[0 4]} 
%                       Set the range of index of the file matched by the
%                       image file pattern to start to read from.
%      InputTsFromFile  [{'off'},'on','fine']
%                       If set to 'on', will set frame timestamp to
%                       modification time of image file. Note that
%                       monotonity of timestamps is not provided: images go
%                       in the same order as without this option. If set to
%                       'fine', will set frame timestamp to the
%                       modification time of the image file in nanosecond
%                       precision.
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
%      VideoScale       Positive integer scalar or two-element vector
%                       Video size scaling factor. If scalar, the size of
%                       the output video is increased by the specified
%                       factor. If vector, it specifies the scaling factor
%                       as a ratio [num den]: num/den > 0 enlarges while
%                       num/den<0 shrinks the video frame size.
%      VideoCrop        4-element integer vector [left top right bottom]
%                       Video frame cropping/padding. If positive, the
%                       video frame is cropped from the respective edge. If
%                       negative, the video frame is padded on the
%                       respective edge.
%      VideoFillColor   ColorSpec
%                       Filling color for padded area.
%      VideoFlip        [horizontal|vertical|both]
%                       Flip the video frames horizontally, vertically, or
%                       both.
%      DeleteSource     ['on'|{'off'}]
%                       Commands to delete all the input files at the
%                       completion.
%
%   Example: Animation movie from a sequence of MATLAB plots:
%
%      % Generate one sinusoidal cycle with varying phase
%      t = linspace(0,1,1001);
%      phi = linspace(0,2*pi,21);
%      figure;
%      for n = 1:numel(phi)
%         plot(t,sin(2*pi*t+phi(n)))
%         print('-dpng',sprintf('test%02d.png',n)); % create an intermediate PNG file
%      end
%
%      % Create the MP4 file from the PNG files, animated at 5 fps
%      FFMPEGIMAGES2VIDEO('test%02d.png','sinedemo.mp4','InputFrameRate',5,...
%         'x264Tune','animation','DeleteSource','on');
%
%   References:
%      FFmpeg Home
%         http://ffmpeg.org
%      FFmpeg Documentation
%         http://ffmpeg.org/ffmpeg.html
%      FFmpeg Wiki Home
%         http://ffmpeg.org/trac/ffmpeg/wiki
%      Encoding VBR (Variable Bit Rate) mp3 audio
%         http://ffmpeg.org/trac/ffmpeg/wiki/Encoding%20VBR%20%28Variable%20Bit%20Rate%29%20mp3%20audio\
%      FFmpeg and AAC Encoding Guide
%         http://ffmpeg.org/trac/ffmpeg/wiki/AACEncodingGuide
%      FFmpeg and x264 Encoding Guide
%         http://ffmpeg.org/trac/ffmpeg/wiki/x264EncodingGuide
%      Xvid/Divx Encoding Guide
%         http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20encode%20Xvid%20/%20DivX%20video%20with%20ffmpeg
%      MeWiki X264 Settings
%         http://mewiki.project357.com/wiki/X264_Settings
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(2,inf);

p = inputParser;
p.addRequired('infile',@(v)validateattributes(v,{'char'},{'row'}));
p.addRequired('outfile',@(v)validateattributes(v,{'char'},{'row'}));
% p.addParameter('ProgressFcn','default',@isprogressfcn);
p.addParameter('DeleteSource','off',@(v)any(strcmpi(v,{'on','off'})));
addImage2Parameters(p);
addInputParameters(p,{'InputFrameRate',25},{'-Range','-Units','-audio','-FastSearch'});
addOutputParameters(p,{'VideoCodec','x264'},{'-audio'});
p.parse(varargin{:});

infilepattern = p.Results.infile;
outfile = p.Results.outfile;

% check output file is given with a full path
if ~isfullpath(outfile)
   outfile = rel2fullfile(outfile,pwd);
end

% set global options
glopts = struct('y',''); %?y (global)?Overwrite output files without asking.

% if animated gif, need to append the palette filter graph to opts.Filters
[opts,gifcleanupfcn] = gif_processing(p.Results);

% Set input & output options
inopts = set_inopts(opts);
inopts(1).f = 'image2';
inopts = set_image2opts(inopts,opts);
outopts = set_outopts(opts);

% get progress file location
% [glopts,progstartfcn,progcleanupfcn] = config_progress(opts.ProgressFcn,glopts);

% set timer for progress
% tobj = progstartfcn('',[],opts.InputFrameRate);
% try
   [~] = ffmpegexecargs(infilepattern,outfile,inopts,outopts,glopts);
% catch ME
%    progcleanupfcn(tobj);
%    ME.rethrow;
% end
% progcleanupfcn(tobj);

% clean up the temporarily added filters
gifcleanupfcn();

% delete all infiles if requested
if strcmpi(opts.DeleteSource,'on')
   [p,f,e] = fileparts(infilepattern);
   if isempty(p), p = '.'; end
   files = dir(fullfile(p,['*' e]));
   files = {files.name};
   
   I = cellfun(@(file)isempty(sscanf(file,[f e])),files);
   files(I) = [];
   for m = 1:numel(files)
      delete(fullfile(p,files{m}));
   end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function tf = isprogressfcn(val)
% tf = isa(val,'function_handle') || any(strcmpi(val,{'default','none'}));
% end

function addImage2Parameters(p)
%      InputLoop        ['on'|{'off'}]
%                       If set to 'on', loop over the input. 
%      InputPatternType [{'sequence'}|'glob'] 
%                       Select the pattern type used to interpret the
%                       provided filename.
%      InputStartNumber [a pair nondecreasing nonnegative integers] {[0 4]} 
%                       Set the range of index of the file matched by the
%                       image file pattern to start to read from.
%      InputTsFromFile  [{'off'},'on','fine']
%                       If set to 'on', will set frame timestamp to
%                       modification time of image file. Note that
%                       monotonity of timestamps is not provided: images go
%                       in the same order as without this option. If set to
%                       'fine', will set frame timestamp to the
%                       modification time of the image file in nanosecond
%                       precision.

args = {
   'InputLoop',         '',   @(val)any(strcmpi(val,{'on','off'}))
   'InputPatternType',  '',   @(val)any(strcmpi(val,{'sequence' 'glob'}))
   'InputStartNumber',  [],   @(val)validateattributes(val,{'numeric'},{'numel',2,'nonnegative','integer','nondecreasing'})
   'InputTsFromFile',   '',   @(val)any(strcmpi(val,{'off' 'on','fine'}))
   };

for n = 1:size(args,1)
   p.addParameter(args{n,:});
end

end

function inopts = set_image2opts(inopts,opts)
   if ~isempty(opts.InputLoop)
      if strcmpi(opts.InputLoop,'on')
         inopts(1).loop = 1;
      else
         inopts(1).loop = 0;
      end
   end
   if ~isempty(opts.InputPatternType)
      inopts(1).pattern_type = opts.InputPatternType;
   end
   if ~isempty(opts.InputStartNumber)
      inopts(1).start_number = opts.InputStartNumber(1);
      inopts(1).start_number_range = diff(opts.InputStartNumber)+1;
   end
   if ~isempty(opts.InputTsFromFile)
      if strcmpi(opts.InputTsFromFile,'off')
         inopts(1).ts_from_file = 0;
      elseif strcmpi(opts.InputTsFromFile,'on')
         inopts(1).ts_from_file = 1;
      else % if strcmpi(opts.InputTsFromFile,'fine')
         inopts(1).ts_from_file = 2;
      end
   end
end
