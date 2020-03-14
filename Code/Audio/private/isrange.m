function tf = isrange(val)
% RANGE: scalar or two-element vector of finite positive values

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

try
   validateattributes(val,{'numeric'},{'nonnegative','increasing','nonnan','finite'});
   tf = any(numel(val)==[1 2]);
catch
   tf = false;
end
