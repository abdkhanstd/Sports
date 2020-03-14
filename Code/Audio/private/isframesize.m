function tf = isframesize(val)
% framesize: [w h] or string

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

try
   validateattributes(val,{'numeric'},{'numel',2,'positive','integer','finite'});
   tf = true;
catch
   abbr = {'ntsc' 'pal' 'qntsc' 'qpal' 'sntsc' 'spal' 'film' 'ntsc-film' ...
      'sqcif' 'qcif' 'cif' '4cif' '16cif' 'qqvga' 'qvga' 'vga' 'svga' 'xga' ...
      'uxga' 'qxga' 'sxga' 'qsxga' 'hsxga' 'wvga' 'wxga' 'wsxga' 'wuxga' ...
      'woxga' 'wqsxga' 'wquxga' 'whsxga' 'whuxga' 'cga' 'ega' 'hd480'
      'hd720' 'hd1080' '2k' '2kflat' '2kscope' '4k' '4kflat' '4kscope'
      'nhd' 'hqvga' 'wqvga' 'fwqvga' 'hvga' 'qhd'};
   tf = any(strcmpi(val,abbr));
end
