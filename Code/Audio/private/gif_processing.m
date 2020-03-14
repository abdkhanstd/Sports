function [opts,cleanupfcn,leadf,followf] = gif_processing(opts)
%GIF_PROCESSING   Create a filter graph to optimize gif color palette if
%output codec is 'gif'. The generated filter graph is saved in
%opts.Filters. If opts.Filters already contains a filter graph,
%GIF_PROCESSING appends its palette filter graph to the existing filter
%graph.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (04-30-2015) bug fix (invalid output argument)

% if Video Codec is not 'gif', nothing to do
if ~(isfield(opts,'VideoCodec') && strcmp(opts.VideoCodec,'gif'))
   cleanupfcn = @()[];
   return;
end
   
% prepare the options
if isfield(opts,'GifPaletteStats') && ~isempty(opts.GifPaletteStats)
   genopts.stats_mode = opts.GifPaletteStats;
else
   genopts = [];
end
if isfield(opts,'GifDither') && ~isempty(opts.GifDither)
   useopts.dither = opts.GifDither;
end
if isfield(opts,'GifDitherBayerScale') && ~isempty(opts.GifDitherBayerScale)
   useopts.bayer_scale = opts.GifDitherBayerScale;
end
if isfield(opts,'GifDitherZone') && ~isempty(opts.GifDitherZone)
   useopts.diff_mode = opts.GifDitherZone;
end
if ~exist('useopts','var')
   useopts = [];
end

% if pre & post filter graphs are given, get the insertion point
[leadf,followf,leadfg,newf] = filterprep(opts.Filters,true,true);

% create the palette filter graph
fg = ffmpegfilterspalette(genopts,useopts);

% link the palette filter graph to its leading and following filter graphs
link(leadf,fg(1));
link(fg(end),followf);
opts.Filters = [leadfg(:);fg];

if nargout>3
   cleanupfcn = @()cleanup(leadf,followf,[fg;newf]);
end
end

function cleanup(leadf,followf,f)
removelinks(f);
link(leadf,followf); % reconnect broken connection
delete(f);
end
