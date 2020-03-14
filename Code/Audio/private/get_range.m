function [opts,fs] = get_range(opts,infile)
%GET_RANGE   Convert range from discrete-time to continuous-time
%   GET_RANGE(RANGE, UNITS, INFILE) converts range specified in frames or
%   samples to seconds. If RANGE is a two-element vector, it defines [START
%   END]; else if RANGE is a scalar, it indicates the duration starting
%   from the beginning. UNITS may be one of 'seconds', 'frames', or
%   'samples'. If 'seconds', no conversion will take place. If UNITS =
%   'frame', RANGE is converted using the first video frame rate. If UNITS
%   = 'samples', RANGE is converted using the first audio sampling rate.
%   RANGE values in a discrete-time units are in one-base indices. The
%   video frame rate or audio sampling rate is obtained from the media file
%   specified by INFILE string.
%
%   GET_RANGE(RANGE, UNITS, INFILE, FS_IN) is used if '-r' flag is used on
%   the input to change the frame/sampling rate. FS_IN to pass in the
%   forced rate. If FS_IN is empty, the original rates from INFILE will be
%   used.
%
%   *******************INTERNAL FUNCTION WARNING***************************
%   There is no input argument check!!!

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (04-30-2015)
%    - bug fix (private function names not updated properly
% rev. 2 : (07-22-2015)
%    - overhauled. new arguments: modifies opts
%    - fixed bug with OutputFrameRate-Range-FastSearch issue

narginchk(2,2);

units = opts.Units;
N = numel(opts.Range);

% if output frame rate is given and fastsearch is 'off', FFmpeg takes the
% Range options with OutputFrameRate.
if strcmp(units,'samples')
   fs = opts.InputSampleRate;
   if isempty(fs)
      fs = get_samplerate(infile);
   end
else
   fs = opts.InputFrameRate;
   if isempty(fs)
      fs = get_framerate(infile);
   end
end

if isempty(opts.Range)
   return;
end

if strcmp(units,'seconds') % if given in frames or samples
   if N==1
      opts.Range = [0 opts.Range];
   end
else
   try
      % additional validation
      validateattributes(opts.Range,{'numeric'},{'integer','positive'});
   catch
      if N==1
         error('Span of Range must be greater than 0.');
      else
         error('Sample/frame based Range must be given with 1-based indices.');
      end
   end
   
   if N==1
      opts.Range = [0 opts.Range/fs];
   else
      opts.Range(1) = (opts.Range(1)-1)/fs;
      opts.Range(2) = opts.Range(2)/fs;
   end
end
