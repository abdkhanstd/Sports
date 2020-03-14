function ffmpegtranscode(varargin)
%FFMPEGTRANSCODE   Transcode multimedia file using FFmpeg
%   FFMPEGTRANSCODE(INFILE,OUTFILE) transcodes the input file specified by
%   the string INFILE using the H.264 video and AAC audio formats. The
%   transcoded data and outputs to the file specified by the string
%   OUTFILE. INFILE must be a FFmpeg supported multimedia file extension
%   (e.g., AVI, MP4, MP3, etc.) while the extension of OUTFILE is expected
%   to be MP4 (although it may output in other formats as well).
%
%   FFMPEGTRANSCODE(INFILE,OUTFILE,'OptionName1',OptionValue1,'OptionName2',OptionValue2,...)
%   may be used to customize the FFmpeg configuration:
%
%      Name    Description
%      ====================================================================
%      Range            Scalar or 2-element vector.
%                       Specifies the segment of INFILE to be transcoded.
%                       If scalar, Range defines the total duration to be
%                       transcoded. If vector, it specifies the starting
%                       and ending times. Range is specified with the input
%                       frame rate or with the OutputFrameRate option if it
%                       given along with FastSearch = 'off'.
%                       
%      Units            [{'seconds'}|'frames'|'samples']
%                       Specifies the units of Range option
%      FastSearch       [{'off'},'on']
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
%      ProgressFcn      ['none'|{'default')|function handle]
%                       Callback function to display transcoding progress.
%                       For a custom callback, provide a function handle
%                       with form: progress_fcn(progfile,Nframes), where
%                       'progfile' is the location of the FFmpeg generated
%                       text file containing the transcoding progress and
%                       Nframes is the expected number of video frames in
%                       the output. Note that FFmpeg appends the new
%                       updates to 'progfile'. If set 'default', the
%                       transcoding progress is shown with a waitbar if
%                       video transcoding and no action for audio
%                       transcoding.
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
%   See Also: FFMPEGSETUP, FFMPEGIMAGE2VIDEO, FFMPEGEXTRACT

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (06-19-2013) original release
% rev. 1 : (10-23-2013) Added 'VideoFlip' option
%                       Changed default x264Crf to 18
% rev. 2 : (10-24-2013) Moved getframerate off as a standalone private
%                       function
% rev. 3 : (08-17-2014) Changed PixelFormat default. 'bgr24' if 'raw' or
%                       'yuv420p' if 'x264' or 'mpeg4'.
%                       Fixed VideoCrop option handling bug
%                       Added AdditionalOptions option
% rev. 4 : (04-06-2015) Major revision. Majority of processing is moved to
%                       private functions for compatibility with other
%                       ffmpeg functions. Added animated GIF support
% rev. 5 : (04-30-2015) Bugfixes:
%                       - restored ProgressFcn support that was broken in rev. 4
%                       - fixed DeleteSource option parser
% rev. 6 : (07-22-2015) Bugfixes:
%                       - fixed bug when Range/OutputFrameRate are both set

narginchk(2,inf);

p = inputParser;
p.addRequired('infile',@(v)validateattributes(v,{'char'},{'row'}));
p.addRequired('outfile',@(v)validateattributes(v,{'char'},{'row'}));
p.addParameter('ProgressFcn','default',@isprogressfcn);
p.addParameter('VideoScale',[],@checkscale);
p.addParameter('VideoCrop',[],@(v)validateattributes(v,{'numeric'},{'numel',4,'integer'}));
p.addParameter('VideoFillColor',[],@(v)~isempty(ffmpegcolor(v)));
p.addParameter('VideoFlip',[],@(v)any(strcmpi(v,{'horizontal','vertical','both'})));
p.addParameter('DeleteSource','off',@(v)any(strcmpi(v,{'on','off'})));
addInputParameters(p);
addOutputParameters(p,{'AudioCodec','aac';'VideoCodec','x264'});
p.parse(varargin{:});

infile = p.Results.infile;
outfile = p.Results.outfile;

% check output file is given with a full path
if ~isfullpath(infile)
   infile = rel2fullfile(infile,pwd);
end

% check to make sure the input files exist
if ~exist(infile,'file')
   error('Input file does not exist.');
end

% check output file is given with a full path
if ~isfullpath(outfile)
   outfile = rel2fullfile(outfile,pwd);
end

% make sure that the filenames are not the same
if (isunix && strcmp(infile,outfile)) ||  (~isunix&&strcmpi(infile,outfile))
   error('INFILE and OUTFILE cannot be the same.');
end

% set global options
glopts = struct('y',''); %?y (global)?Overwrite output files without asking.

% Create filter chain if no custom filter is defined by user
[opts,tformcleanupfcn] = setvideofilter(p.Results);

% if animated gif, need to append the palette filter graph to opts.Filters
[opts,gifcleanupfcn] = gif_processing(opts);

% make sure Range is in seconds
[opts,fs] = get_range(opts,infile);

% Set input/output options
inopts = set_inopts(opts);
outopts = set_outopts(opts);

% configure and start progress display (if enabled)
[glopts,progcleanupfcn] = config_progress(opts.ProgressFcn,infile,opts.Range,fs,mfilename,glopts);
% run FFmpeg
try
   [~] = ffmpegexecargs(infile,outfile,inopts,outopts,glopts);
catch ME
   progcleanupfcn();
   ME.rethrow;
end
progcleanupfcn();

% delete all infiles if requested
if strcmpi(opts.DeleteSource,'on')
   delete(infile);
end

% clean up the temporarily added filters
gifcleanupfcn();
tformcleanupfcn();

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [opts,cleanupfcn] = setvideofilter(opts)


% if no spatial transformation is request, exit
if isempty(opts.VideoCrop) && isempty(opts.VideoScale) && isempty(opts.VideoFlip)
   cleanupfcn = @()[];
   return;
end

args = {'crop'                               'scale'         'flip'
        {opts.VideoCrop opts.VideoFillColor} opts.VideoScale opts.VideoFlip};

if isempty(opts.VideoFlip)
   args(:,3) = [];
end
if isempty(opts.VideoScale)
   args(:,2) = [];
end
if isempty(opts.VideoCrop)
   args(:,1) = [];
elseif isempty(opts.VideoFillColor)
   args{1,2}(2) = [];
end

% if pre & post filter graphs are given, get the insertion point
[leadf,followf,leadfg,newf] = filterprep(opts.Filters,true,true);

fg = ffmpegfiltersvideotform(args{:});

% link the palette filter graph to its leading and following filter graphs
link(leadf,fg(1));
link(fg(end),followf);
opts.Filters = [leadfg(:);fg];

cleanupfcn = @()cleanup(leadf,followf,[fg;newf]);

end

function cleanup(leadf,followf,f)
removelinks(f);
link(leadf,followf); % reconnect broken connection
delete(f);
end

function tf = checkscale(val)
try
   validateattributes(val,{'numeric'},{'positive','finite'});
   tf = any(numel(val)==[1 2]);
catch
   tf = false;
end
end

function tf = isprogressfcn(val)
tf = isa(val,'function_handle') || any(strcmpi(val,{'default','none'}));
end
