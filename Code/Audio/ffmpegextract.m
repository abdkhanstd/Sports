function ffmpegextract(varargin)
%FFMPEGEXTRACT   Extracts a stream from multimedia file
%   FFMPEGEXTRACT(INFILE,OUTFILE,TYPE) extracts a stream in the multimedia
%   file with name INFILE and save the stream in OUTFILE. The stream is
%   chosen by TYPE which could be 'video' or 'audio'. The first stream of
%   matching type is selected by FFMPEG.
%
%   FFMPEGEXTRACT(INFILE,OUTFILE,STREAMID) maybe used to specify the exact
%   stream to be extracted. STREAMID can be a nonnegative integer
%   associated with the stream as obtained from streams.id subfield of
%   FFMPEGINFO output. Also, any valid FFMPEG stream specifier string
%   expression is supported. For example, 'a:1' picks the second audio
%   stream or 'm:language:eng' picks the English audio stream.
%
%   FFMPEGEXTRACT(INFILE,OUTFILE,STREAMID,RANGE)
%   extracts a portion of the media file by specifying the time RANGE,
%   which is given in seconds (default Units). RANGE may be a scalar value,
%   which specifies the duration of the output video, starting from the
%   beginning. Or RANGE may be a two-element vector to indicate [START END]
%   times. 
%
%   If RANGE is not specified, the extracted stream is by default simply
%   copied to the output file. Limiting the time range requires the output
%   video to be re-encoded (audio: aac, video:x264). 
%
%   FFMPEGEXTRACT(...,'Param1Name',Param1Value,'Param2Name',Param2Value,...)
%   sets options.
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
%      FastSearch       ['off',{'on'}]
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
%      AudioCodec       [{copy}|wav|mp3|{aac}]
%                       Audio codec. If full range extraction, it defaults
%                       to 'copy'; otherwise, uses 'aac' as default.
%      AudioSampleRate  Positive scalar
%                       Output audio sampling rate in samples/second.
%                       Only specify if needed to be changed.
%      Mp3Quality       Integer scalar between 0 and 9 {[]}
%                       MP3 encoder quality setting. Lower the higher
%                       quality. Empty uses the FFmpeg default.
%      AacBitRate       Integer scalar.
%                       AAC encoder's target bit rate in b/s. Suggested to
%                       use 64000 b/s per channel.
%      VideoCodec       [{copy}|raw|mpeg4|{x264}]
%                       Video codec. If full range extraction, it defaults
%                       to 'copy'; otherwise, uses 'x264' as default.
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
%      Filters          [Array of ffmpegfilters]
%                       A filtergraph to filter the output. If it is a
%                       simple filterchain, simply provide an array of
%                       unlinked ffmpegfilters without head or tail
%                       ffmpegfilter objects. The filters will be applied
%                       in the order as appears in the array. For a more
%                       complex filtergraph, the array must include one
%                       ffmpegfilter.head object and one ffmpegfilter.tail
%                       and its elements must be all linked together.
%      DeleteSource     ['on'|{'off'}]
%                       Commands to delete all the input files at the
%                       completion.
%      ProgressFcn      ['none|{'default')|function handle]
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

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (07-22-2015) Bugfixes:
%                       - fixed bug when Range/OutputFrameRate are both set

narginchk(3,inf);

p = inputParser;
p.addRequired('infile',@(v)validateattributes(v,{'char'},{'row'},mfilename,'INFILE'));
p.addRequired('outfile',@(v)validateattributes(v,{'char'},{'row'},mfilename,'OUTFILE'));
p.addRequired('streamid');
p.addOptional('Range',[],@isrange);
p.addParameter('ProgressFcn','default');

addInputParameters(p,[],{'Range'});
addOutputParameters(p,{'AudioCodec','';'VideoCodec',''},{},...
   {'copy' 'wav' 'mp3' 'aac'}, {'copy' 'raw' 'mpeg4' 'x264'});
p.parse(varargin{:});

infile = p.Results.infile;
outfile = p.Results.outfile;
streamid = p.Results.streamid;

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

% interpret the streamid/type input
if isnumeric(streamid)
   validateattributes(streamid,{'numeric'},{'scalar','nonnegative','integer'});
   streamid = num2str(streamid);
else
   try
      type = validatestring(streamid,{'video','audio'}); % video, audio, subtitle, data, attachment
      if type(1)=='v'
         streamid = 'v:0';
      else
         streamid = 'a:0';
      end
   catch
      validateattributes(streamid,{'char'},{'row'},mfilename,'TYPE/STREAMID');
   end
end

% % set the progress display function
% progopt = p.Results.ProgressFcn;
% if ischar(progopt)
%    progopt = validatestring(progopt,{'none','default'});
% else
%    validateattributes(progopt,{'function_handle'},{'scalar'});
% end
% [glopts, progstartfcn, progcleanupfcn] = config_progress(progopt);

% complete the global option by specifying no interaction
glopts.y = ''; % overwrite existing output file

% if a range is specified or any of the codecs are assigned, do not
% transcode
opts = p.Results;
if isempty(opts.Range) && isempty(opts.AudioCodec) && isempty(opts.VideoCodec)
   inopts = [];
   outopts.c = {'a','copy';'v','copy'};
else
   if isempty(opts.AudioCodec)
      opts.AudioCodec = 'aac';
   end
   if isempty(opts.VideoCodec)
      opts.VideoCodec = 'x264';
   end
   
   opts = get_range(opts,infile);
   
   inopts = set_inopts(opts);
   outopts = set_outopts(opts);
end

% set -map output option
outopts.map = sprintf('0:%s',streamid);

% run the FFMPEG
% tobj = progstartfcn(infile,[],[]);
try
   [~] = ffmpegexecargs(infile,outfile,inopts,outopts,glopts);
catch ME
%    progcleanupfcn(tobj);
   ME.rethrow;
end
% progcleanupfcn(tobj);
