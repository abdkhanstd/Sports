function [expr,iscomplex] = ffmpegfiltergraph(filters)
%FFMPEGFILTERGRAPH   Filter graph expression builder
%   FFMPEGFILTERGRAPH(FILTERS) returns the FFMPEG filtergraph expression
%   with the FFMPEGFILTER object array FILTERS.
%
%   FILTERS must have one each of FFMPEGFILTER.HEAD and FFMPEGFILTER.TAIL
%   objects, and FILTERS components must be fully connected using LINK()
%   function, including proper labeling of all multi-link ports.
%
%   For a simple filter chain (i.e., single input, single output, and no
%   splitting/marging of filter path), however, FFMPEGFILTER.HEAD,
%   FFMPEGFILTER.TAIL, and the linking may be omitted if FILTERS include
%   neither FFMPEGFILTER.HEAD nor FFMPEGFILTER.TAIL and no links are
%   defined.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

narginchk(1,1);
validateattributes(filters,{'ffmpegfilter.base'},{});
Nfilters = numel(filters);

simplechain =  issimplechain(filters);

if simplechain
   % connect the filters sequentially
   for n = 1:numel(filters)-1
      link(filters(n),filters(n+1));
   end
   
   filters(end+2) = ffmpegfilter.tail;
   filters(end-1) = ffmpegfilter.head;
   link(filters(end-1),filters(1));
   link(filters(end-2),filters(end));
   chain_heads = numel(filters)-1;
   iscomplex = false;
else % full filtergraph given
   % scan filters and initialize their port counters
   terms = false(Nfilters,2); % true if terminal filter
   ports = zeros(Nfilters,2); % number of ports

   Ihead = arrayfun(@(f)isa(f,'ffmpegfilter.head'),filters);
   if sum(Ihead)~=1
      error('Filter graph must have one and only one FFMPEGFILTER.HEAD');
   end
   Itail = arrayfun(@(f)isa(f,'ffmpegfilter.tail'),filters);
   if sum(Itail)~=1
      error('Filter graph must have one and only one FFMPEGFILTER.TAIL');
   end
   
   iscomplex = numel(filters(Ihead).outports)>1 || numel(filters(Itail).inports)>1;
   
   for n = 1:Nfilters
      
      filters(n).out_cnt = 0;
      
      Nports = numel(filters(n).outports);
      if Nports < filters(n).nout(1) || Nports>filters(n).nout(2)
         error('Unsupported number of input links specified');
      end
      terms(n,1) = isa(filters(n),'ffmpegfilter.head') || Nports>1;
      ports(n,1) = Nports;
      
      Nports = numel(filters(n).inports);
      if Nports < filters(n).nin(1)|| Nports>filters(n).nin(2)
         error('Unsupported number of output links specified.');
      end
      terms(n,2) = isa(filters(n),'ffmpegfilter.tail') || Nports>1;
      ports(n,2) = Nports;
   end
   Nchains = sum(ports);
   
   if sum(ports(:,1)==0)>1
      error('More than 1 ffmpegfilter.head is found');
   end
   if sum(ports(:,2)==0)>1
      error('More than 1 ffmpegfilter.tail is found');
   end
   if diff(Nchains)~=0
      error('Missing filters to complete the chains.');
   end
   
   % identify the head filter for each chain
   heads = terms(:,1)|any(ports>1,2);
   Nchains = sum(ports(terms(:,1))) + sum(any(ports(:,2)>1,2));
   chain_heads = zeros(Nchains,1);
   idx = 0;
   for n = find(heads)'
      idx = idx(end)+1:idx(end)+ports(n,1);
      chain_heads(idx) = n;
   end
end

try
   % create filter chain expressions
   chain_exprs = cell(size(chain_heads));
   for n = 1:Nchains
      
      % get the head filter
      f = filters(chain_heads(n));
      
      % if first filter takes multiple input and single output include in this
      % chain
      if numel(f.inports)>1 && numel(f.outports)==1
         expr_chain = f.print();
         ch = ',';
      else
         expr_chain = '';
         ch = '';
      end
      
      % go to the second filter
      idx = f.out_cnt + 1;
      f.out_cnt = idx;
      f = f.outports(idx);
      
      while ~isa(f,'ffmpegfilter.tail') && numel(f.inports)<2 && numel(f.outports)<2
         expr_chain = sprintf('%s%c%s',expr_chain,ch,f.print());
         ch = ',';
         idx = f.out_cnt + 1;
         f.out_cnt = idx;
         f = f.outports(idx);
      end
      
      % if last filter takes single input and multiple output include in this
      % chain
      if numel(f.inports)==1 && numel(f.outports)>1
         expr_chain = sprintf('%s%c%s',expr_chain,ch,f.print());
      end
      
      chain_exprs{n} = expr_chain;
   end
   
   % combine chains to create filtergraph
   chain_exprs(cellfun(@isempty,chain_exprs)) = [];
   expr = chain_exprs{1};
   for n = 2:numel(chain_exprs)
      expr = sprintf('%s;%s',expr,chain_exprs{n});
   end
catch ME
   
   if simplechain % undo the filter links
      for n = 1:numel(filters)
         filters(n).removelinks();
      end
      delete(filters(end-1:end));
   end
   
   ME.rethrow();
end

if simplechain % undo the filter links
   for n = 1:numel(filters)
      filters(n).removelinks();
   end
   delete(filters(end-1:end));
end
