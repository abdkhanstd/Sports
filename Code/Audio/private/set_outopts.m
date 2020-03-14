function outopts = set_outopts(opts)
%OUTOPTS = SET_OUTOPTS(OPTIONS)   Helper function to convert FFMPEG toolbox
%common option struct OPTIONS to FFMPEG output option struct outopts(1).
%See addOutputParameters for all the options

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (06-22-2015) fixed a bug in processing PixelFormat option
% rev. 2 : (07-22-2015) fixed a bug with empty Range option

% if OutputFrameRate is not given or FastSearch is on, Range is given in
% input time scale
if isfield(opts,'Range') && (isempty(opts.Range) || opts.Range(1)==0 ...
      || ~(isfield(opts,'FastSearch') || isempty(opts.FastSearch) || strcmp(opts.FastSearch,'off')))
   opts = rmfield(opts,'Range');
end

fnames = fieldnames(opts);
outopts = struct([]);
for n = 1:numel(fnames)
   val = opts.(fnames{n});
   if isempty(val), continue; end % guarantees only non-empty values goes forward
   
   switch fnames{n}
      case 'Range' % Scalar or 2-element vector.

         if val(1)>0
            outopts(1).ss = sprintf('%0.6f',val(1));
         end
         T = diff(val);
         if ~isinf(T)
            outopts(1).t = sprintf('%0.6f',diff(val));
         end
         
      case 'AudioCodec' % specify audio codec and its private options
         if isfield(outopts,'c')
            Irow = size(outopts(1).c,1)+1;
         else
            Irow = 1;
         end
         switch val
            case 'none'
               outopts(1).an = '';
            case 'copy'
               outopts(1).c{Irow,1} = 'a';
               outopts(1).c{Irow,2} = 'copy';
            case 'wav'
               outopts(1).c{Irow,1} = 'a';
               outopts(1).c{Irow,2} = 'pcm_s16le';
            case 'mp3'
               outopts(1).c{Irow,1} = 'a';
               outopts(1).c{Irow,2} = 'mp3';
               
               q = opts.Mp3Quality;
               if ~isempty(q)
                  if isfield(outopts,'q')
                     outopts(1).q{end+1,1} = 'a';
                  else
                     outopts(1).q{1} = 'a';
                  end
                  outopts(1).q{end,2} = q;
               end
            case 'aac'
               outopts(1).c{Irow,1} = 'a';
               outopts(1).c{end,2} = 'aac';
               outopts(1).strict = '-2';
               
               b = opts.AacBitRate;
               if ~isempty(b)
                  if isfield(outopts,'b')
                     outopts(1).b = {'a' b};
                  else
                     outopts(1).b{end+1,1} = 'a';
                     outopts(1).b{end,2} = b;
                  end
               end
            otherwise
               outopts(1).c{Irow,[1 2]} = {'a' val};
         end
      case 'AudioSampleRate' % Positive scalar
         if isfield(outopts,'r')
            outopts(1).r{end+1,1} = 'a';
         else
            outopts(1).r{1} = 'a';
         end
         if numel(val)==1
            outopts(1).r{end,2} = val;
         else
            outopts(1).r{end,2} = sprintf('%d/%d',val(1),val(2));
         end
      case 'VideoCodec' %      [none|copy|raw|mpeg4|{x264}]
         if isfield(outopts,'c')
            Irow = size(outopts(1).c,1)+1;
         else
            Irow = 1;
         end
         switch val
            case 'none'
               outopts(1).vn = '';
            case 'copy'
               outopts(1).c(Irow,[1 2]) = {'v' 'copy'};
            case 'raw'
               outopts(1).c(Irow,[1 2]) = {'v' 'rawvideo'};
               if ~isfield(outopts,'pix_fmt')
                  outopts(1).pix_fmt = 'bgr24';
               end
            case 'mpeg4'
               outopts(1).c(Irow,[1 2]) = {'v','mpeg4'};
               q = opts.Mpeg4Quality;
               if isfield(outopts,'q')
                  Irow = size(outopts(1).q,1)+1;
               else
                  Irow = 1;
               end
               outopts(1).q(Irow,[1 2]) = {'v',q};
               if ~isfield(outopts,'pix_fmt')
                  outopts(1).pix_fmt = 'yuv420p';
               end
            case 'x264'
               outopts(1).c(Irow,[1 2]) = {'v','libx264'};
               
               q = opts.x264Crf;
               outopts(1).crf = q;
               
               s = opts.x264Preset;
               if ~isempty(s)
                  outopts(1).preset = s;
               end
               
               s = opts.x264Tune;
               if ~isempty(s)
                  outopts(1).tune = s;
               end
               if ~isfield(outopts,'pix_fmt')
                  outopts(1).pix_fmt = 'yuv420p';
               end
            case 'gif'
               outopts(1).c(Irow,[1 2]) = {'v' 'gif'};
               s = opts.GifLoop;
               if ~isempty(s)
                  if ischar(s)
                     if strcmp(s,'off')
                        outopts.loop = -1;
                     else
                        outopts.loop = 0;
                     end
                  else
                     outopts.loop = s;
                  end
               end
               s = opts.GifFinalDelay;
               if ~isempty(s)
                  outopts.final_delay = round(s*100);
               end
            otherwise
               outopts(1).c{Irow,[1 2]} = {'v' val};
         end
      case 'OutputFrameRate'
         if isfield(outopts,'r')
            Irow = size(outopts(1).r,1)+1;
         else
            Irow = 1;
         end
         if numel(val)==1
            outopts(1).r(Irow,[1 2]) = {'v',val};
         else
            outopts(1).r(Irow,[1 2]) = {'v',sprintf('%d/%d',val(1),val(2))};
         end
      case 'PixelFormat'
         outopts(1).pix_fmt = val;
      case 'Filters'
         [fg,iscomplex] = ffmpegfiltergraph(val);
         if ~iscomplex
            outopts(1).filter = sprintf('"%s"',fg);
         end
      case 'OutputCustomOptions'
         cfnames = fieldnames(val);
         for k = 1:numel(cfnames)
            outopts(1).(cfnames{k}) = val.(cfnames{k});
         end
   end
end
