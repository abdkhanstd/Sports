function p = addInputParameters(p,defvals,altlist)
%ADDINPUTPARAMETERS   Add parameters to the inputParser object to
%allow FFMPEG input options in the parameter name-value pairs.
%
%   p = addInputParameters(p,defvals,altlist)
%
%   altlist - a cell array of string, possibly {?}all, ?}audio, ?}video,
%   ?}{optname}} Leading + indicates inclusion, leading - indicates
%   exclusion. If leading sign is missing, it assumes exclusion. The items
%   are processed in a sequential order. 'audio' and 'video' removes all
%   options exclusively related to audio or video, respectively.
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
%      InputCustomOptions A valid ffmpeg option struct.
%                         To directly specify the options.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (04-30-2015) bug fix: "FastSeek" -> FastSearch"

args = {
   'Range',             [],        @isrange
   'Units',             'seconds', @(v)any(strcmpi(v,{'seconds' 'frames' 'samples'}))
   'FastSearch',        '',        @(v)any(strcmpi(v,{'on','off'}))
   'InputAudioCodec',   '',        @(val)iscodec(val,'audio','decoder')
   'InputSampleRate',   [],        @isposintorratio
   'InputVideoCodec',   '',        @(val)iscodec(val,'video','decoder')
   'InputFrameRate',    [],        @isframerate
   'InputPixelFormat',  [],        @ispixfmt
   'InputFrameSize',    [],        @isframesize
   'InputCustomOptions',[],        @(val)validateattributes(val,{'struct'},{'scalar'})};

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
         excopts([3 4]) = exc;
      elseif strcmpi(cmd,'video')
         excopts(5:8) = exc;
      else
         excopts(strcmpi(args(:,1),cmd)) = exc;
      end
   end
   
   args(excopts,:) = [];
end

for n = 1:size(args,1)
   p.addParameter(args{n,:});
end
