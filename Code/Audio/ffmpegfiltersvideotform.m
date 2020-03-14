function filters = ffmpegfiltersvideotform(varargin)
%FFMPEGFILTERSVIDEOTFORM   Get FFmpeg filter chain for video spatial transformation
%   FFMPEGFILTERSVIDEOTFORM(CMD,CMDOPTS) returns a FFMPEGFILTER object
%   which performs a task specified by CMD string according to the options
%   given in CMDOPTS. Video spatial transformation commands are:
%
%   COMMAND OPTION DESCRIPTION
%   ----------------------------------------
%   'crop'         crop to given dimension
%           [x0 y0 w h] in pixels, (x0, y0) is the upper left corner
%   'pad'          pad to given dimension
%           [x0 y0 w h] in pixels, (x0, y0) is the upper left corner
%           {[x0 y0 w h], color} color for padded space
%   'cropmargin'   crop edges by given # of pixels
%   'padmargin'    pad edges by given # of pixels
%           [left bottom right top] in pixels, if negative, flips b/w crop & pad
%           {[left bottom right top],color} color for padding
%   'scale'        scale video size by given factor
%           factor  scaling factor
%           {factor,algorithm} {'fast_bilinear','bilinear','bicubic',
%                              'experimental','neighbor','area','bicublin',
%                              'gauss','sinc','lanczos','spline'}
%   'resize'       resize video to specified size
%           [w h]  new width and height in pixels
%           {[w h],algorithm} {'fast_bilinear','bilinear','bicubic',
%                              'experimental','neighbor','area','bicublin',
%                              'gauss','sinc','lanczos','spline'}
%   'flip'         flip video frame
%           'direction' - {horizontal|vertical|both}
%   'rotate'       rotate video
%           angle    in degrees, auto-resize
%           {angle resize}   if resize=false, turns off resize
%           {angle resize fillcolor} specify fill color
%   'transpose'    transpose video
%           dir                 dir: {'cclock_flip','clock','cclock','clock_flip'}
%           {dir, passthrough}  passthrough: {'none','portrait','landscape'}
%
%   FFMPEGFILTERSVIDEOTFORM(CMD1,CMDOPTS1,CMD2,CMDOPTS2,...) to create a
%   chain of filters. They are linked sequentially in the order given.
%
%   FFMPEGFILTERSVIDEOTFORM(..., '-addhead') prepends ffmpegfilter.head to
%   the generated filter chain
%
%   FFMPEGFILTERSVIDEOTFORM(..., '-addtail') appends ffmpegfilter.tail to
%   the generated filter chain
%
%   FFMPEGFILTERSVIDEOTFORM(...,'-nolinkage') does not link created filters

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

% Process the option arguments

addhead = false;
addtail = false;
linkfilters = true;

Iopts = find(cellfun(@(v)ischar(v)&&v(1)=='-',varargin));
for n = 1:numel(Iopts)
   opt = validatestring(varargin{Iopts(n)},{'-addhead','-addtail','-nolinkage'});
   if opt(5)=='h'
      addhead = true;
   elseif opt(5)=='t'
      addtail = true;
   elseif opt(4)=='l'
      linkfilters = false;
   end
end
varargin(Iopts) = []; % remove option arguments

% Check for valid command structure (even # of arguments & cmds are all string)
Nargs = numel(varargin);
Ncmds = floor(Nargs/2);
if (Ncmds*2~=Nargs || ~iscellstr(varargin(1:2:end)))
   error('');
end

% create a null filter array
filters(2*Ncmds+addhead+addtail,1) = ffmpegfilter.null;

% add head if requested
if addhead
   filters(1) = ffmpegfilter.head;
   n_offset = 2;
else
   n_offset = 1;
end

for n = 0:Ncmds-1
   % get & validate the n-th command
   cmd = validatestring(varargin{2*n+1},{'crop','cropmargin','pad','padmargin','scale','resize','flip','rotate','transpose'});
   cmdopts = varargin{2*n+2};
   if ~iscell(cmdopts)
      cmdopts = {cmdopts};
   end
   
   switch cmd
      case 'crop' % crop to given dimension
         f = create_crop(cmdopts);
      case 'pad' % pad to given dimension
         f = create_pad(cmdopts);
      case 'cropmargin' %  crop edges by given # of pixels
         f = create_cropmargin(cmdopts,true);
      case 'padmargin' %   pad edges by given # of pixels
         f = create_padmargin(cmdopts,false);
      case 'scale' %       scale video size by given factor
         f = create_scale(cmdopts);
      case 'resize' % resize video to specified size
         f = create_resize(cmdopts);
      case 'flip' % flip video frame
         f = create_flip(cmdopts);
      case 'rotate' %      rotate video
         f = create_rotate(cmdopts);
      case 'transpose' %   transpose video
         f = create_transpose(cmdopts);
   end
   
   if isscalar(f)
      filters(n+n_offset) = f;
   else
      Nf = numel(f);
      filters(n+n_offset:n+n_offset+Nf-1) = f;
      n_offset = n_offset + Nf - 1;
   end
end

if addtail
   filters(Ncmds+n_offset) = ffmpegfilter.tail;
   n_offset = n_offset + 1;
end

filters(Ncmds+n_offset:end) = [];

if linkfilters
   for n = 1:numel(filters)-1
      link(filters(n),filters(n+1));
   end
end

end

function f = create_crop(cmdopts)
%           [x0 y0 w h] in pixels, (x0, y0) is the upper left corner
if ~isscalar(cmdopts)
   error('Invalid number of CMDOPTS for ''crop'' CMD.');
end
validateattributes(cmdopts{1},{'numeric'},{'numel',4,'integer','positive'});
f = ffmpegfilter.crop;
f.x = cmdopts{1}(1);
f.y = cmdopts{1}(2);
f.w = cmdopts{1}(3);
f.h = cmdopts{1}(4);
end

function f = create_pad(cmdopts)
% [x0 y0 w h] in pixels, (x0, y0) is the upper left corner
% {[x0 y0 w h],color} color for padding
if all(numel(cmdopts)~=[1 2])
   error('''pad'' needs 1 or 2 options.');
end

validateattributes(cmdopts{1},{'numeric'},{'numel',4,'integer','positive'});

f = ffmpegfilter.pad;    % 2
f.x = cmdopts{1}(1);
f.y = cmdopts{1}(2);
f.w = cmdopts{1}(3);
f.h = cmdopts{1}(4);

if numel(cmdopts)>1
   f.color = ffmpegcolor(cmdopts{2});
end
end

function f = create_cropmargin(cmdopts,iscrop)

% [left bottom right top] in pixels, if negative, equivalent to 'padmargin'
% {[left bottom right top],color} color for padding

if all(numel(cmdopts)~=[1 2])
   error('Invalid # of CMDOPTS for ''cropmargin'' or ''padmargin'' CMD.');
end
validateattributes(cmdopts{1},{'numeric'},{'numel',4,'integer','finite'});

crop = cmdopts{1};
if iscrop % cropmargin
   pad = max(-crop,0);
   crop(:) = max(crop,0);
else % padmargin
   pad = max(crop,0);
   crop = max(-crop,0);
end

if any(crop>=0)
   f = ffmpegfilter.pad;
   f.trim_margin(crop);
else
   f = ffmpegfilter.crop.empty;
end
if any(pad>=0)
   f(end+1) = ffmpegfilter.pad;
   f(end).pad_margin(pad);
   if numel(cmdopts)>1
      f(end).color = ffmpegcolor(cmdopts{2});
   end
end

end

function f = create_scale(cmdopts)
% factor  scaling factor
if all(numel(cmdopts)~=[1 2])
   error('''scale'' CMD requires 1 or 2 option value.');
end
f = ffmpegfilter.scale;
f.scale_frame(cmdopts{1});

if numel(cmdopts)>1
   algo = validatestring(cmdopts{2},{'fast_bilinear','bilinear','bicubic',...
      'experimental','neighbor','area','bicublin','gauss','sinc','lanczos','spline'});
   f.flags = algo;
end

end

function f = create_resize(cmdopts)
% [w h]  new width and height in pixels
% {[w h],algorithm} {'fast_bilinear','bilinear','bicubic',
%                    'experimental','neighbor','area','bicublin',
%                    'gauss','sinc','lanczos','spline'}
if all(numel(cmdopts)~=[1 2])
   error('''resize'' CMD requires 1 or 2 option value.');
end
validateattributes(cmdopts{1},{'numeric'},{'numel',2,'positive','integer'});
f = ffmpegfilter.scale; 
f.w = cmdopts{1}(1);
f.h = cmdopts{1}(2);

if numel(cmdopts)>1
   algo = validatestring(cmdopts{2},{'fast_bilinear','bilinear','bicubic',...
      'experimental','neighbor','area','bicublin','gauss','sinc','lanczos','spline'});
   f.flags = algo;
end

end

function f = create_flip(cmdopts)
% 'direction' - {horizontal|vertical|both}
if ~isscalar(cmdopts)
   error('''resize'' CMD only takes 1 option value.');
end

dir = validatestring(cmdopts{1},{'horizontal','vertical','both'});

if any(dir(1)=='hb')
   f = ffmpegfilter.hflip;
else
   f = ffmpegfilter.hflip.empty;
end
if any(dir(1)=='vb')
   f(end+1) = ffmpegfilter.vflip;
end
end

function f = create_rotate(cmdopts)
%   'rotate'       rotate video
%           angle in degrees
%           {angle resize}
%           {angle resize fillcolor}
if all(numel(cmdopts)~=[1 2 3])
   error('''rotate'' takes 1 to 3 option values.');
end
validateattributes(cmdopts{1},{'numeric'},{'scalar'});
f = ffmpegfilter.rotate;
f.angle = cmdopts{1}*180/pi;
f.out_auto = 'off';

if numel(cmdopts)>1
   validateattributes(cmdopts{2},{'logical'},{'scalar'});
   if cmdopts{2}
      f.out_auto = 'on';
   else
      f.out_auto = 'off';
   end
end

if numel(cmdopts)>2
   f.color = cmdopts{3};
end

end

function f = create_transpose(cmdopts)
%           dir                 dir: {'cclock_flip','clock','cclock','clock_flip'}
%           {dir, passthrough}  passthrough: {'none','portrait','landscape'}
if all(numel(cmdopts)~=[1 2])
   error('''rotate'' takes 1 or 2 option values.');
end
f = ffmpegfilter.transpose;
f.dir = cmdopts{1};
if numel(cmdopts)>1
   f.passthrough = cmdopts{2};
end

end
