function expr = ffmpegcolor(val)
%FFMPEGCOLOR   Convert MATLAB color expression to FFMPEG's color expression
%   FFMPEGCOLOR(RGB) returns an FFMPEG string expression which represents
%   3-element RGB vector, each element between values 0 and 1. If RGB is
%   an integer type, the elements range are 0 and 255.
%
%   FFMPEGCOLOR(RGBA) takes 4-element vector with RGB plus the alpha value.
%
%   FFMPEGCOLOR('color_expression') takes either MATLAB or FFMPEG color
%   names. If two programs defines color names differently, MATLAB name
%   takes the precedence
%
%   FFMPEGCOLOR('random') picks a random color.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

if isinteger(val)
   validateattributes(val,{'uint8','uint16','uint32','uint64','int8','int16','int32','int64'},...
      {'>=',0,'<=',255});
   if numel(val)<3 || numel(val)>4
      error('Expects 3 or 4 elements');
   end
   
   expr = sprintf('0x%02X%02X%02X',val(1:3));
   if numel(val)>3
      expr = sprintf('%s%02X',str,val(4));
   end
elseif isnumeric(val)
   validateattributes(val,{'double','single'},{'>=',0,'<=',1});
   if numel(val)<3 || numel(val)>4
      error('Expects 3 or 4 elements');
   end
   
   val(:) = round(val*255);
   expr = sprintf('0x%02X%02X%02X',val(1:3));
   if numel(val)>3
      expr = sprintf('%s%02X',str,val(4));
   end
elseif ischar(val)
   
   switch lower(val)
      case {'y','yellow'}
         expr = 'Yellow';
      case {'m' 'magenta'}
         expr = 'Magenta';
      case {'c' 'cyan'}
         expr = 'Cyan';
      case {'r' 'red'}
         expr = 'Red';
      case {'g' 'green'}
         expr = 'Lime';
      case {'b' 'blue'}
         expr = 'Blue';
      case {'w' 'white'}
         expr = 'White';
      case {'k' 'black'}
         expr = 'Black';
      otherwise
         info = ffmpegcolors();
         if any(strcmpi(val,{info.name}))
            expr = val;
         else
            error('Unknown color name');
         end
   end
else
   error('Color must be given as a numeric vector or string expression.');
end
