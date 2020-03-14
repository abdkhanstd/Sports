function tf = isfullpath(path)
%ISFULLPATH   True for fully expanded file path string
%   ISFULLPATH(PATH) returns true if the path string given in PAT is a full
%   path. The given path is fully specified if PATH starts with the root
%   directory. For Windows system, it is "[drive letter:]\" or "\\[server]"
%   while on a Linux/MacOSX platform, PATH must start with a forward slash
%   "/".

narginchk(1,1);

% if the input is a cellstring, run isfullpath on each string element
if iscellstr(path)
   tf = cellfun(@isfullpath,path);
   return;
end

if ~(ischar(path)&&isrow(path))
   error('PATH must be a string or a cell array of strings.');
end

if ispc()
   % separator can be forward or backward slash
   path(:) = strrep(path,'/','\');
   
   % root directory condition: "[drive letter:]\" or "\\[server]"
   cond = {'^[a-zA-Z]:\\','^\\\\[a-zA-Z0-9\-]'};
else
   cond = '^/';
end

% full path if path meets the root directory condition
tf = ~all(cellfun(@isempty,regexp(path,cond,'once')));
