function tf = ispixfmt(v)
%ISPIXFMT returns true if v is a valid pix_fmt string

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

info = ffmpegpixfmts;
tf = any(strcmpi(v,{info.name}));
