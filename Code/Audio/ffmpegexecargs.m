function r = ffmpegexecargs(infiles,outfiles,inopts,outopts,glopts)
%FFMPEGEXECARGS   Run FFMPEG with arguments
%   FFMPEGEXEC(INFILE,OUTFILE,INOPTS,OUTOPTS,GLOPTS) run FFmpeg with input
%   file, given by the string INFILE, and output file, given by the string
%   OUTFILE. The input file options are set according to the struct INOPTS.
%   Likewise, The struct OUTOPTS specifies the output file options. The
%   final option struct, GLOPTS, sets the global options. All option
%   structs must be given with its field names to specify the names of the
%   options and their values for the option value. If an option does not
%   require a value, leave its struct field value empty. If an option can
%   be set per stream, its struct field value should be a 2-column cell
%   matrix with each row specifying {stream_specifier option_value}.
%
%   FFMPEGEXEC(INFILES,OUTFILES,INOPTS,OUTOPTS,GLOPTS) can receive multiple
%   input or output files (and their options) by passing cell strings
%   INFILES or OUTFILES. If INFILES or OUTFILES are given as cell strings,
%   their options can be given as a struct if the same option applies to
%   all files or as a cell array of struct with matching size to the file
%   cell strings.
%
%   References:
%      FFmpeg Home
%         http://ffmpeg.org
%      FFmpeg Documentation
%         http://ffmpeg.org/ffmpeg.html
%      FFmpeg Wiki Home
%         http://ffmpeg.org/trac/ffmpeg/wiki
%
%   See Also: FFMPEGSETUP, FFMPEGTRANSCODE

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(2,5);

% set the global options
if nargin>4 && ~isempty(glopts)
   validateattributes(glopts,{'struct'},{},mfilename,'GLOPTS');
   argstr = [opts_to_string(glopts,'GLOPTS',[]) ' '];
else
   argstr = '';
end

% process the input files
if ischar(infiles)
   infiles = {infiles};
end
if ~(iscellstr(infiles) && all(cellfun(@isrow,infiles)))
   error('INFILES must be a (single-row) string or an cell array of (single-row) strings');
end
Nin = numel(infiles);

optgiven = nargin>2 && ~isempty(inopts);
if optgiven
   optind = isstruct(inopts);
   if optind % single option for all inputs
      optstr = opts_to_string(inopts,'INOPTS',[]);
   elseif ~(iscell(inopts) && numel(inopts)==Nin)
      error('INOPTS must be given as a struct or a cell array with matching number of structs as INFILES.');
   end
   optind = ~optind;
end

for n = 1:Nin
   if optgiven % option given
      if optind
         optstr = opts_to_string(inopts{n},'INOPTS',n);
      end
      argstr = sprintf('%s%s ',argstr,optstr);
   end
   argstr = sprintf('%s-i "%s" ',argstr,infiles{n});
end

% process the output files
if ischar(outfiles)
   outfiles = {outfiles};
end
if ~(iscellstr(outfiles) && all(cellfun(@isrow,outfiles)))
   error('OUTFILES must be a (single-row) string or an cell array of (single-row) strings');
end
Nout = size(outfiles);

optgiven = nargin>3 && ~isempty(outopts);
if optgiven
   optind = isstruct(outopts);
   if optind % single option for all inputs
      optstr = opts_to_string(outopts,'OUTOPTS',[]);
   elseif ~(iscell(outopts) && numel(outopts)==Nout)
      error('OUTOPTS must be given as a struct or a cell array with matching number of structs as OUTFILES.');
   end
   optind = ~optind;
end

for n = 1:Nout
   if optgiven % option given
      if optind
         optstr = opts_to_string(outopts{n},'OUTOPTS',n);
      end
      argstr = sprintf('%s%s ',argstr,optstr);
   end
   argstr = sprintf('%s"%s" ',argstr,outfiles{n});
end

% execute FFMPEG program
r = ffmpegexec(argstr);

end

function str = opts_to_string(opt,argname,argelem)

if isempty(argelem)
   argstr = argname;
else
   argstr = sprintf('%s {%d}',argname,argelem);
end

try
   fnames = fieldnames(opt);
catch
   error('%s must be a struct.',argstr);
end

str = '';
for n = 1:numel(fnames)
   fname = fnames{n};
   
   fval = opt.(fname);
   if iscell(fval) % per-stream option
      validateattributes(fval,{'cell'},{'2d','ncols',2},mfilename,sprintf('%s.%s',argstr,fname));
      
      for k = 1:size(fval,1)
         str = sprintf('%s-%s:',str,fname);
         if ischar(fval{k,1})
            str = sprintf('%s%s ',str,fval{k,1});
         else
            try
               str = sprintf('%s%s ',str,num2str(fval{k,1}));
            catch
               error('The stream_specifier value of %s.%s cannot be converted to a string.');
            end
         end
         if ~isempty(fval{k,2})
            if ischar(fval{k,2})
               str = sprintf('%s%s ',str,fval{k,2});
            else
               try
                  str = sprintf('%s%s ',str,num2str(fval{k,2}));
               catch
                  error('The option value of %s.%s cannot be converted to a string.');
               end
            end
         end
      end
   else % regular option
      str = sprintf('%s-%s ',str,fname);
      if ~isempty(fname)
         if ischar(fval)
            str = sprintf('%s%s ',str,fval);
         else
            try
               str = sprintf('%s%s ',str,num2str(fval));
            catch
               error('The value of %s.%s cannot be converted to a string.');
            end
         end
      end
   end
end

end
