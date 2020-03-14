function [leadf,followf,fg,newf] = filterprep(fg,append,reqsiso)
%[LEADER,FOLLOWER,FILTERS] = FILTERPREP(FILTERS, APPEND) analyzes the
%FILTERS filtergraph array and break up the filtergraph to prepare for
%adding more filters at the beginning (APPEND=false) or at the end
%(APPEND=true). If FILTERS is empty, it creates a new filtergraph with a
%head and tail object. FILTERPREP returns handle array to the leading
%filter in LEADER and handle array to the following filter in FOLLOWER.
%
%If FILTERS must be properly linked before calling this function unless it
%is a simple chain, in which case FILTERS does not contain any head or tail
%object and none of its elements are linked. If FILTERS is a simple chain,
%FILTERPREP explicitly links them, and the FILTERS in the output argument
%has the head and tail objects to appended to the end.
%
%[LEADER,FOLLOWER,FILTERS] = FILTERPREP(FILTERS, APPEND, REQSISO) checks to
%make sure the link between LEADER & FOLLOWER filters is a single link.
%
%[...,NEWFILTERS] = FILTERPREP(...) returns an array of handles to the
%ffmpegfilter objects that are created by FILTERPREP.

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release

if isempty(fg) % no filter is given
   leadf = ffmpegfilter.head;
   followf = ffmpegfilter.tail;
   fg = [leadf;followf];
   newf = fg;
else
   simplechain = issimplechain(fg);
   if ~simplechain
      Ihead = arrayfun(@(el)isa(el,'ffmpegfilter.head'),fg);
      if sum(Ihead)~=1
         error('Filtergraph must have one and only one head.');
      end
      Itail = arrayfun(@(el)isa(el,'ffmpegfilter.tail'),fg);
      if sum(Itail)~=1
         error('Filtergraph must have one and only one tail.');
      end
   end
   
   if simplechain
      % connect the filters sequentially
      for n = 1:numel(fg)-1
         link(fg(n),fg(n+1));
      end
      
      % connect the head
      head = ffmpegfilter.head;
      tail = ffmpegfilter.tail;
      newf = [head;tail];

      % only link head or tail and return unlinked end
      if append
         link(head,fg(1));
         leadf = fg(end);
         followf = tail;
      else
         leadf = head;
         followf = fg(1);
         link(fg(end),tail);
      end
      
      % append head & tail to (columnized) filtergraph array
      fg = cat(1,fg(:),head,tail);
      
   else % full filtergraph is given (at least the tail of the graph is defined)

      if append
         followf = fg(Itail);
         leadf = followf.inports; % get the last filter
         if nargin>2 && reqsiso && numel(leadf)>1 % make sure the connection is single-link
            error('The existing filtergraph must output only one file.');
         end
         followf.removelinks(); % remove the link from the last filter to the tail
      else
         leadf= fg(Ihead);
         followf = leadf.outports; % get the last filter
         if nargin>2 && reqsiso && numel(followf)>1 % make sure the connection is single-link
            error('The existing filtergraph must take only one file.');
         end
         leadf.removelinks(); % remove the link from the head to the first filter
      end
      newf = ffmpegfilter.null.empty;
   end
end
