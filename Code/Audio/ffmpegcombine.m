function ffmpegcombine(varargin)
%FFMPEGCOMBINE   Marge multiple multimedia files using FFmpeg
%   FFMPEGCOMBINE(INFILES,OUTFILE,FILTERGRAPH) combines input files
%   specified by the strings in the cellstr array INFILES, using the filter
%   graph specified by FILTERGRAPH vector of class objects from
%   FFMPEGFILTER class package. The resulting media is saved to a file as
%   specified by OUTFILE, using the H.264 video and AAC audio formats.
%   INFILEs must be a FFmpeg supported multimedia file extension (e.g.,
%   AVI, MP4, MP3, etc.) while the extension of OUTFILE is expected to be
%   MP4 (although it may output in other formats as well).
%
%   FFMPEGTRANSCODE(...,'OptionName1',OptionValue1,'OptionName2',OptionValue2,...)
%   may be used to customize the output file:
%
%      Name             Description
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
%      VideoCodec       [none|copy|raw|mpeg4|{x264}]
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
%   Example: Overlay a transparent mask image over a video
%
%      videofile = 'video.mp4';
%      maskfile = 'mask.png';  % same size as video.mp4 frame
%                              % video is shown thru transparent pixels
%      filtgraph = [ffmpegfilter.head ffmpegfilter.overlay ffmpegfilter.tail];
%      filtgraph(1).link(filtgraph(2),'0:v'); % video.mp4 as the main
%      filtgraph(1).link(filtgraph(2),'1:v',true); % mask.png as overlayed
%      filtgraph(2).link(filtgraph(3));
%
%      ffmpegcombine({'videofile.mp4' 'maskfile'},'output.mp4',filtgraph);


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

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (07-06-2015) original release

narginchk(2,inf);

p = inputParser;
p.addRequired('infiles',@iscellstr);
p.addRequired('outfile',@(v)validateattributes(v,{'char'},{'row'}));
p.addRequired('fg',@(v)validateattributes(v,{'ffmpegfilter.base'},{}));
p.addParameter('ProgressFcn','default',@isprogressfcn);
% addInputParameters(p);
addOutputParameters(p,{'AudioCodec','aac';'VideoCodec','x264'});
p.parse(varargin{:});

infiles = p.Results.infiles;
outfile = p.Results.outfile;
fg = p.Results.fg;

% check output file is given with a full path
idx = ~isfullpath(infiles);
if any(idx)
   infiles(idx) = rel2fullfile(infiles(idx),pwd);
end

% check to make sure the input files exist
if ~all(cellfun(@(f)exist(f,'file'),infiles))
   error('One or more input files does not exist.');
end

% check output file is given with a full path
if ~isfullpath(outfile)
   outfile = rel2fullfile(outfile,pwd);
end

% make sure that the filenames are not the same
if (isunix && any(strcmp(infiles,outfile))) ||  (~isunix&&any(strcmpi(infiles,outfile)))
   error('INFILE and OUTFILE cannot be the same.');
end

% make sure filtergraph has the matching # of inputs and single output
head = fg(arrayfun(@(f)isa(f,'ffmpegfilter.head'),fg));
if ~isscalar(head)
   error('FILTERGRAPH must contain a ffmpegfilter.head object.');
end
if numel(head.outports)>numel(infiles)
   error('FILTERGRAPH takes more input files than given.');
end

% make sure filtergraph has the matching # of inputs and single output
tail = fg(arrayfun(@(f)isa(f,'ffmpegfilter.tail'),fg));
if ~isscalar(tail)
   error('FILTERGRAPH must contain a ffmpegfilter.tail object.');
end
if isempty(tail.inports)
   error('FILTERGRAPH must output at least one stream.');
end

% set global options
glopts = struct('y','','filter_complex',['"' ffmpegfiltergraph(fg) '"']); %?y (global)?Overwrite output files without asking.

% Set input/output options
outopts = set_outopts(p.Results);

% Add map option
if ~isempty(tail.inlabels)
   outopts.map = ['"[' tail.inlabels{1} ']"'];
end

% configure and start progress display (if enabled)
[glopts,progcleanupfcn] = config_progress(p.Results.ProgressFcn,infiles,[],[],mfilename,glopts);

% run FFmpeg
try
   [~] = ffmpegexecargs(infiles,outfile,[],outopts,glopts);
catch ME
   progcleanupfcn();
   ME.rethrow;
end
progcleanupfcn();

end

function tf = isprogressfcn(val)
tf = isa(val,'function_handle') || any(strcmpi(val,{'default','none'}));
end
