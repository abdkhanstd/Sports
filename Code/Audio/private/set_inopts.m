function inopts = set_inopts(opts)
%INOPTS = SET_INOPTS(OPTIONS)   Helper function to convert FFMPEG toolbox
%common option struct OPTIONS to FFMPEG input option struct inopts(1).
%Following fields of OPTIONS are processed:

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (07-22-2015)
%          - Fixed error if FastSearch given but not Range case

% Specify Range in input only if FastSearch is on or starts from the first frame
if isfield(opts,'Range') && (~isempty(opts.Range) && opts.Range(1)>0 ...
      && (~isfield(opts,'FastSearch') || isempty(opts.FastSearch) || strcmp(opts.FastSearch,'off')))
   opts = rmfield(opts,'Range');
end

fnames = fieldnames(opts);
inopts = struct([]);

for n = 1:numel(fnames)
   val = opts.(fnames{n});
   if isempty(val), continue; end % guarantees only non-empty values goes forward
   
   switch fnames{n}
      case 'Range' % Scalar or 2-element vector.

         if val(1)>0
            inopts(1).ss = sprintf('%0.6f',val(1));
         end
         T = diff(val);
         if ~isinf(T)
            inopts(1).t = sprintf('%0.6f',diff(val));
         end
         
      case 'FastSearch'
         if strcmp(val,'on')
            inopts(1).noaccurate_seek = '';
         else
            inopts(1).accurate_seek = '';
         end
   
      case 'InputVideoCodec'
         if isfield(inopts,'c')
            inopts(1).c{end+1,1} = 'v';
            inopts(1).c{end,2} = val;
         else
            inopts(1).c = {'v' val};
         end
      case 'InputFrameRate' % Positive scalar
         % Set input options (only if single input file)
         % - alter input frame rate
         if numel(val)==1
            inopts(1).r = sprintf('%d',val);
         else
            inopts(1).r = sprintf('%d/%d',val(1),val(2));
         end
      case 'InputPixelFormat' % One of format string returned by FFMPEGPIXFMTS
         inopts(1).pix_fmt = val;
      case 'InputFrameSize' % Used only if the media file does not store the
         inopts(1).s = sprintf('%dx%d',val(1),val(2));
      case 'InputAudioCodec'
         if isfield(inopts,'c')
            inopts(1).c{end+1,1} = 'a';
            inopts(1).c{end,2} = val;
         else
            inopts(1).c = {'a' val};
         end
      case 'InputSampleRate' % Positive scalar
         inopts(1).ar = val;
      case 'InputCustomOptions'
         cfnames = fieldnames(val);
         for k = 1:numel(cfnames)
            inopts(1).(cfnames{k}) = val.(cfnames{k});
         end
   end
end

end
