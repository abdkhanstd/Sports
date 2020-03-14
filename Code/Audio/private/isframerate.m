function tf = isframerate(val)
% postive integer or ratio or abbreviation

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (07-21-2015) removed integer contraint

try
   %validateattributes(val,{'numeric'},{'positive','integer','finite'});
   validateattributes(val,{'numeric'},{'positive','finite'});
   tf = any(numel(val)==[1 2]);
catch
   abbr = {'ntsc' 'pal' 'qntsc' 'qpal' 'sntsc' 'spal' 'film' 'ntsc-film'};
   tf = any(strcmpi(val,abbr));
end
