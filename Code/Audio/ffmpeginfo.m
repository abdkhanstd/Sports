function info = ffmpeginfo(infile)
%FFMPEGINFO   Retrieves media file information
%   FFMPEGINFO(FILE) without any output argument displays the information
%   of the multimedia file, specified by the string FILE.
%
%   INFO = FFMPEGINFO(FILE) returns INFO struct containing the parsed media
%   information of the multimedia file. 
%
%   INFO = FFMPEGINFO({FILE1 FILE2 ...}) processes multiple media files at
%   once, returning INFO as a struct array.
%
%   INFO Struct Fields:
%   ===============================================
%      .format       file container format
%      .filename     file name/path
%      .meta         container meta data (struct)
%      .duration     total duration in seconds
%      .start        starting time offset in seconds
%      .bitrate      total bit rate in bits/second
%      .chapters     chapter markers struct
%      .programs     programs struct
%      .streams      media stream struct
%
%   INFO.CHAPTERS Substruct Fields:
%   ===============================================
%      .number       Chapter number
%      .start        Starting time in seconds
%      .end          Ending time in seconds
%      .meta         Chapter meta data (struct)
%
%   INFO.PROGRAMS Substruct Fields
%   ===============================================
%      .id           Program ID
%      .name         Program name
%      .meta         Program meta data (struct)
%
%   INFO.STREAMS Substruct Fields
%   ================================================
%      .id           Stream ID
%      .pid          Stream PID
%      .lang         Stream language
%      .type         Stream type (e.g., 'video', 'audio')
%      .codec        Stream codec info (struct)
%      .meta         Stream meta data (struct)
%
%   INFO.STREAMS.CODEC Subsubstruct Fields
%   ================================================
%   (1) Video Codec
%      .name            Codec name
%      .desc          	Codec descriptions
%      .pix_fmt         Frame pixel format
%      .bpc             Bits per coded sample
%      .size            Frame size [width height]
%      .aspectratios    Aspect Ratios struct of [num den]
%                       .SAR   Sample aspect ratio
%                       .DAR   Display aspect ratio
%      .quality         [max min] qualities
%      .bitrate         Bit rate
%      .fps             Average frame rate
%      .tbr             Estimated video stream time base
%      .tbn             Container time base
%      .tbc             Codec time base
%      .disp            List of dispositions
%
%   (2) Audio Codec
%      .name            Codec name
%      .desc          	Codec descriptions
%      .samplerate      Sampling rate
%      .channels        Channel configuration
%      .sample_fmt      Sample format
%      .bitrate         Bit rate
%      .disp            List of dispositions
%
%   (3) Other
%      .name            Codec name
%      .desc          	Codec descriptions
%      .misc            Other info
%
%   Example:
%      ffmpeginfo('xylophone.mpg') % to simply pipe FFmpeg output
%      info = ffmpeginfo('xylophone.mpg') % get parsed data
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2013 Takeshi Ikuma
% History:
% rev. - : (06-19-2013) original release

% Relevant FFMPEG source files:
%    ffmpeg.c
%    libavformat/libavformat_utils.c
%    libavcodec/libavcodec_utils.c
%    libavutil/channel_layout.c

narginchk(1,1);
if ischar(infile)
   infile = cellstr(infile);
end
if ~(iscellstr(infile) && all(cellfun(@(c)size(c,1)==1,infile)))
   error('FILE must be given as a string of characters.');
end

% check to make sure the input files exist
file = cellfun(@(f)which(f),infile,'UniformOutput',false);
I = cellfun(@isempty,file);
if any(I)
   if any(cellfun(@(f)isempty(dir(f)),infile(I)))
      error('At least one of the specified files do not exist.');
   else % if file can be located locally, let it pass ('which' function cannot resolve all the files)
      file(I) = infile(I);
   end
end

% get FFMPEG executable
ffmpegexe = ffmpegpath();

[s,msg] = system(sprintf('%s %s',ffmpegexe,sprintf('-i "%s" ',file{:})));

if s==0
   error('ffmpeginfo failed to run FFmpeg\n\n%s',msg);
end

I = regexp(msg,'Input #','start');
if isempty(I)
   error('Specified file is not FFmpeg supported media file.');
end

% remove the no output warning
msg = regexprep(msg,'At least one output file must be specified\n$','','once');

if nargout<1 % no output argument, just display the ffmpeg output
   disp(msg(I(1):end));
   return;
end

% Parse the ffmpeg output to the info struct

Ninputs = numel(I);
I = [I numel(msg)+1];
info = struct('format',{},'filename',{},'meta',{},'duration',{},'start',{},'bitrate',{},'data',{});
for n = 1:Ninputs
   input = msg(I(n):I(n+1)-1);
   info(n) = regexp(input,['Input #\d+, (?<format>.*?), from ''(?<filename>.+?)?'':\n'...
      '(?<meta>  Metadata:\n.*?\n)?'...
      '  Duration: (?<duration>(\d+:\d+:\d+\.\d+)|(N/A))'...
      '(?<start>, start: \d+\.\d+)?'...
      ', bitrate: (?<bitrate>(-?\d+ kb/s)|(N/A))\n'...
      '(?<data>.*)'],'names');
   
   if strcmp(info(n).duration,'N/A')
      info(n).duration = [];
   else
      info(n).duration = [3600 60 1]*sscanf(info(n).duration,'%d:%d:%f');
   end
   if isempty(info(n).start)
      info(n).start = [];
   else
      info(n).start = sscanf(info(n).start,', start: %f');
   end
   if strcmp(info(n).bitrate,'N/A')
      info(n).bitrate = [];
   else
      info(n).bitrate = sscanf(info(n).bitrate,'%d kb/s')*1000;
   end
   
   % parse metadata (if exists)
   info(n).meta = parse_metadata(info(n).meta,'  Metadata:\n');
   
   % separate chapters & stream info
   I0 = regexp(info(n).data,{'    Chapter','    Program','    Stream'},'start','once');
   % parse chapters (if exists)
   if isempty(I0{1})
      info(n).chapters = struct([]);
   else
      if ~isempty(I0{2})
         I1 = I0{2}-1;
      elseif ~isempty(I0{3})
         I1 = I0{3}-1;
      else
         I1 = numel(info(n).data);
      end
      data = info(n).data(I0{1}:I1);
      
      info(n).chapters = regexp(data,['    Chapter #\d+\.(?<number>\d+): '....
         'start (?<start>[\d\.]+), end (?<end>[\d\.]+)\n'...
         '(?<meta>    Metadata:\n.*?)?\n'...
         ],'names');
      
      for m = 1:numel(info(n).chapters)
         info(n).chapters(m).start = str2double(info(n).chapters(m).start);
         info(n).chapters(m).end = str2double(info(n).chapters(m).end);
         info(n).chapters(m).meta = parse_metadata(info(n).chapters(m).meta,'    Metadata:\n');
      end
   end
   
   % parse program (if exists)
   if isempty(I0{2})
      info(n).programs = struct([]);
   else
      if ~isempty(I0{3})
         I1 = I0{3}-1;
      else
         I1 = numel(info(n).data);
      end
      data = info(n).data(I0{2}:I1);
      
      info(n).programs = regexp(data,['    Program (?<id>\d+) '....
         '(?<name>[^\n]+)\n'...
         '(?<meta>    Metadata:\n.*?)?\n'...
         ],'names');
      
      for m = 1:numel(info(n).programs)
         info(n).chapters(m).meta = parse_metadata(info(n).chapters(m).meta,'    Metadata:\n');
      end
   end
   
   % parse streams
   info(n).streams = regexp(info(n).data(I0{3}:end),['    Stream #\d+:(?<id>\d+)'...
      '(?<pid>\[0x[\dabcdef]+\])?(?<lang>\(.+?\))?:'...
      ' (?<type>[^:]+): (?<codec>[^\n]+\n)(?<meta>    Metadata:\n.*?\n)?'],...
      'names');
   for m = 1:numel(info(n).streams)
      info(n).streams(m).id = str2double(info(n).streams(m).id);
      if isempty(info(n).streams(m).pid)
         info(n).streams(m).pid = '';
      else
         info(n).streams(m).pid = info(n).streams(m).pid(2:end-1);
      end
      if isempty(info(n).streams(m).lang)
         info(n).streams(m).lang = '';
      else
         info(n).streams(m).lang = info(n).streams(m).lang(2:end-1);
      end
      info(n).streams(m).type = lower(info(n).streams(m).type);
      info(n).streams(m).codec = parse_codecinfo(info(n).streams(m).type,info(n).streams(m).codec);
      info(n).streams(m).meta = parse_metadata(info(n).streams(m).meta,'    Metadata:\n');
   end
end

info = rmfield(info,'data');

end


function info = parse_codecinfo(type,str)

% %s
% buf % avcodec_string
%
% fps-tbc: with or w/o postfix 'k'
%
% codec_string
% %s{ (%d bpc)}}{, %dx%d{ [SAR %d:%d DAR %d:%d]}}{, q=%d-%d}{, SAR %d:%d DAR %d:%d}{, %f fps}{, %f tbr}{, %ftbn}{, %ftbc}{(blahblah)}{()}{()}
% type
% name
% enc->codec->name
% profile
% codec_tag
% pix_fmt - bits/raw sample
% widthxheight - [SAR DAR]
% qmin-qmax
% SAR.num SAR.den DAR.num DAR.den
% fps
% tbr
% tbn
% tbc


switch type
   case 'video'
      info = regexp(str,['(?<name>.+?)'...
         '(?<desc> \(.+?\))?'... % assuming no commas in description parentheses
         '(?<pix_fmt>, [^\s\d][^,]+))?'...
         '(?<bpc> \(\d+ bpc\))?'...
         '(?<size>, \d+x\d+)?'...
         '(?<aspectratios> \[SAR \d+:\d+ DAR \d+:\d+\])?'...
         '(?<quality>, q=\d+:\d+)?'...
         '(?<bitrate>, \d+ kb/s)?'...
         '(?<aspectratios>, SAR \d+:\d+ DAR \d+:\d+)?'...
         '(?<fps>, [\d\.]+k? fps)?'...
         '(?<tbr>, [\d\.]+k? tbr)?'...
         '(?<tbn>, [\d\.]+k? tbn)?'...
         '(?<tbc>, [\d\.]+k? tbc)?'...
         '(?<disps> \(.*\))?'],'names','once');
      if isempty(info)
         info = str;
      else
         if isempty(info.desc)
            info.desc = {};
         else
            info.desc = cellfun(@(c)c{1},regexp(info.desc,' \((.+?)\)','tokens'),'UniformOutput',false);
         end
         
         if isempty(info.bpc)
            info.bpc = [];
         else
            info.bpc = sscanf(info.bpc,' (%d bpc)');
         end
         if isempty(info.size)
            info.size = [];
         else
            info.size = sscanf(info.size,', %dx%d').';
         end
         if isempty(info.quality)
            info.quality = [];
         else
            info.quality = sscanf(info.quality,', q=%d-%d').';
         end
         if isempty(info.bitrate)
            info.bitrate = [];
         else
            info.bitrate = sscanf(info.bitrate,', %d kb/s')*1000;
         end
         if isempty(info.aspectratios)
            info.aspectratios = struct('SAR',[],'DAR',[]);
         else
            if info.aspectratios(1)==' '
               ratios = sscanf(info.aspectratios,' [SAR %d:%d DAR %d:%d]');
            else
               ratios = sscanf(info.aspectratios,', SAR %d:%d DAR %d:%d');
            end
            info.aspectratios = struct('SAR',ratios(1:2).','DAR',ratios(3:4).');
         end
         info.fps = parse_fps(info.fps,'fps');
         info.tbr = parse_fps(info.tbr,'tbr');
         info.tbn = parse_fps(info.tbn,'tbn');
         info.tbc = parse_fps(info.tbc,'tbc');
         if isempty(info.disps)
            info.disps = {};
         else
            info.disps = cellfun(@(c)c{1},regexp(info.disps,' \((.+?)\)','tokens'),'UniformOutput',false);
         end
         
      end
   case 'audio'
      % example:  dts (DTS-HD MA), 48000 Hz, 5.0(side), fltp, 1536 kb/s (default)
      %           'aac, 48000 Hz, stereo, fltp
      info = regexp(str,['(?<name>[^\s\(,]+)(?<desc> \(.+?\))?'...
         '(?<samplerate>, \d+ Hz)?'...
         '(?<channels>, [^,]+)?'...
         '(?<sample_fmt>, [^,]+)?'...
         '(?<aspectratios>, SAR \d+:\d+ DAR \d+:\d+)?'... % not likely but cannot ruled out on source
         '(?<bitrate>, \d+ kb/s)?'...
         '(?<disps> \(.*\))?'],'names','once');
      if isempty(info)
         info = str;
      else
         if isempty(info.desc)
            info.desc = {};
         else
            info.desc = cellfun(@(c)c{1},regexp(info.desc,' \((.+?)\)','tokens'),'UniformOutput',false);
         end
         
         info = rmfield(info,'aspectratios');
         if isempty(info.samplerate)
            info.samplerate = [];
         else
            info.samplerate = sscanf(info.samplerate,', %d Hz');
         end
         if isempty(info.bitrate)
            info.bitrate = [];
         else
            info.bitrate = sscanf(info.bitrate,', %d kb/s')*1000;
         end
         if isempty(info.disps)
            info.disps = {};
         else
            info.disps = cellfun(@(c)c{1},regexp(info.disps,' \((.+?)\)','tokens'),'UniformOutput',false);
         end
      end
   case 'subtitle'
      info = regexp(str,['(?<name>[^\s\(,]+)(?<desc> \(.+?\))?'...
         '(?<misc>.*)\n'],'names','once');
   otherwise
      info = str;
end

if isstruct(info)
   info = structfun(@(s)strfieldcleanup(s),info,'UniformOutput',false);
end

end

function fps = parse_fps(str,postfix)
if isempty(str)
   fps = [];
else
   toks = regexp(str,[', ([\d\.]+)(k?) ' postfix],'tokens','once');
   if isempty(toks{2})
      fps = sscanf(toks{1},['%f' postfix]);
   else
      fps = sscanf(toks{1},['%f' postfix])*1000;
   end
end
end


function meta = parse_metadata(str,hdr)

if isempty(str)
   meta = str;
else
   data = regexprep(str,['^' hdr],'','once');
   data = regexp(data,'([^:]+):\s([^\n]+)','tokens');
   data = cat(1,data{:});
   data = cellfun(@strtrim,data,'UniformOutput',false);
   I = find(cellfun(@isempty,data(:,1)));
   for i = fliplr(I(:)')
      if i==1
         data{1,1} = 'unknown';
      else
         data{i-1,2} = sprintf('%s\n%s',data{i-1,2},data{i,2});
      end
   end
   data(I,:) = [];
   data = data.';
   meta = struct(data{:});
end

end

function str = strfieldcleanup(str)

if ischar(str) && numel(str)>0
   if str(1)==','
      str(1) = [];
   end
   str = strtrim(str);
end

end
