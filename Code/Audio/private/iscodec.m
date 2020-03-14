function tf = iscodec(val,type,coder,others)
%ISCODEC   Returns true if val is a valid codec name
%   type - 'audio','video','subtitle'
%   coder - 'encoder','decoder'
%   others - cell array of strings representing other acceptable codec names

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

if nargin>2 && ~isempty(others)
   tf = any(strcmpi(val,others));
   if tf, return; end
end

codecs = ffmpegcodecs();
codecs(~[codesc.(coder)]) = [];
codecs(~strcmp({codecs.type},type)) = [];
tf = any(strcmpi(val,{codecs.name}));
