function tf = isposintorratio(val)
% scalar positive integer or two-element positive
% integers representing a fraction

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

try
   validateattributes(val,{'numeric'},{'integer','positive','finite'});
   tf = any(numel(val),[1 2]);
catch
   tf = false;
end
