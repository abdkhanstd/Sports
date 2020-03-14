% FFmpeg Toolbox
% Version 22-Jul-2015 22-Jul-2015
%
% FFmpeg Toolbox contains a collection of FFmpeg wrapper functions to
% perform multimedia conversion.
%
% Toolbox Setup
%   ffmpegsetup       - Run this first to use this toolbox
%
% FFmpeg feature list functions
%   ffmpegcodecs      - Gets supported video codecs
%   ffmpegcolor       - Convert color expression from MATLAB to FFmpeg
%   ffmpegcolors      - Gets FFmpeg color names and their RGB values
%   ffmpegformats     - Gets multimedia file formats
%   ffmpegpixfmts     - Gets supported video pixel formats
%
% FFmpeg wrapper functions
%   ffmpegextract     - Extract a stream from a media file
%   ffmpegimage2video - Create video file from a series of images
%   ffmpeginfo        - Retrieves media file information
%   ffmpegtranscode   - Transcode media file (supports croping & scaling)
%   ffmpegcombine     - Combine multiple media files via a filtergraph
%
% FFmpeg filtergraph generator functions
%   ffmpegfiltersvideotform - To apply a series of spatial transformations
%   ffmpegfilterspalette    - To generate and apply 256-color palette
%
% FFmpeg filters (ffmpegfilter package)
%   ffmpegfilter.crop         - Crop video
%   ffmpegfilter.hflip        - Flip video horizontally
%   ffmpegfilter.histeq       - Apply global color histogram equalization
%   ffmpegfilter.null         - Pass through
%   ffmpegfilter.overlay      - Overlay a video on top of another
%   ffmpegfilter.pad          - Pad video
%   ffmpegfilter.palettegen   - Generate a 256-color palette for a video
%   ffmpegfilter.paletteuse   - Use a palette to reduce colors in video
%   ffmpegfilter.rotate       - Rotate video
%   ffmpegfilter.scale        - Scale or resize video
%   ffmpegfilter.setdar       - Change display-aspect-ratio (DAR) setting
%   ffmpegfilter.setsar       - Change sample-aspect-ratio (SAR) setting
%   ffmpegfilter.split        - Split into several identical outputs
%   ffmpegfilter.transpose    - Transpose rows of video with columns
%   ffmpegfilter.vflip        - Flip video vertically
%
%   ffmpegfilter.head         - Start of filtergraph (one per filtergraph)
%   ffmpegfilter.tail         - End of filtergraph (one per filtergraph)
%   ffmpegfilter.base         - Base class for all ffmpegfilter classes
%
% Low-level FFmpeg wrapper functions
%   ffmpegexecargs    - Run FFmpeg with custom option structs
%   ffmpegexec        - Run FFmpeg with custom argument string

%   Copyright 2013-2015 Takeshi Ikuma. All rights reserved.

% changelog
% Version 22-Jul-2015 (2.2)
% - Added ffmpegfilter.setdar & ffmpegfilter.setsar classes
% - Fixed an issue with incorrect interaction between OutputFrameRate and
%   Range options
% - Other misc. small bug fixes
% Version 06-Jul-2015 (2.1)
% - Added ffmpegcombine function (to merge multiple files)
% Version 23-Jun-2015 (2.0.2)
% - Fixed bug in handling the PixelFormat option
% Version 30-Apr-2015
% - Fixed Range option behavior (slower but more reliable)
% - Fixed Default progress display function
% Version 06-Apr-2015 (major release)
% - added animated GIF support
% - added ffmpegimage2video function to convert images to video
% - added ffmpegfiltergraph function and +ffmpegfilter class package to 
%   construct FFmpeg filter command with a linked ffmpeg filter objects.
% - added ffmpegfilter classes: crop, pad, rotate, scale, transpose, hflip, 
%   vflip, split, overlay, palettegen, paletteuse, histeq, null, head, tail
% - added 2 filtergraph generators: ffmpegfiltersvideotform and
%   ffmpegfilterspalette
% - added ffmpegexecargs low-level function
% - added ffmpegcolors
% Version 24-Oct-2013
% - added ffmpegexec function
% Version 23-Oct-2013
% - added VideoFlip options in FFMPEGTRANSCODE
% Version 19-Jun-2013
% - original release
