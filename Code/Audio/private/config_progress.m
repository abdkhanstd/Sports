function [glopts,cleanupfcn] = config_progress(progressopt,infile,range,fs,mfilename,glopts)
%   Sets up progress function

% Copyright 2015 Takeshi Ikuma
% History:
% rev. - : (04-06-2015) original release
% rev. 1 : (04-30-2015)
%    - combined config_progress and startup functions
%    - added mfilename to the input argument to display the calling
%      mfilename name in the default progress display window

cleanupfcn = @()[];
if ~strcmpi(progressopt,'none')

   infile = cellstr(infile);
   
   % get number of frames
   N = [];
   for k = 1:numel(infile)
      try
         [fs0,T] = get_framerate(infile{k});
         if isempty(fs)
            fs = fs0;
         end
         if isempty(range)
            N = floor(fs*T);
         else
            N = floor(fs*diff(range));
         end
         break;
      catch
      end
   end
   
   if isempty(N)
      warning('Could not configure progress display function: Unresolved video frame rate and duration.');
      return;
   end
   
   % get progress file location
   progfile = '';
   if ~(isempty(progressopt) || strcmpi(progressopt,'none'))
      %       progfile = fullfile(tempdir,'ffmpegprogress.txt');
      progfile = fullfile(pwd,'ffmpeg_progress.txt');
      if exist(progfile,'file')
         delete(progfile);
      end
      glopts.progress = ['"' progfile '"'];
   end
   
   % create a timer object to keep track of the progress
   tobj = timer('ExecutionMode','fixedRate','Period',1,'TasksToExecute',inf);
   if strcmpi(progressopt,'default')
      set(tobj,'TimerFcn',@(~,~)progfcn_default(progfile,N,mfilename));
      progfcn_default('setup',[],mfilename);
      progressopt = @progfcn_default;
   elseif isa(progressopt,'function_handle')
      set(tobj,'TimerFcn',{progressopt,progfile,N});
   else
      error('ProgressFcn must be given as a function handle object.');
   end
   
   % create the clean up function
   cleanupfcn = @()cleanup(tobj,progfile,progressopt);
   
   % start the timer
   start(tobj);
end

end

function progfcn_default(progfile,N,mfilename)
persistent pos
persistent h

switch progfile
   case 'setup'
      pos = 0;
      h = waitbar(0,'Searching for the starting frame...','WindowStyle','modal',...
         'Name',mfilename,'CloseRequestFcn',{});
      drawnow;
   case 'delete'
      delete(h);
      h = [];
   otherwise
      
      fid = fopen(progfile,'r');
      if fid<0, return; end % file not ready
      
      fseek(fid,pos,-1); % go to the last position
      txt = fscanf(fid,'%c',inf); % read all the text to the end
      pos = ftell(fid); % save the last position
      fclose(fid);
      
      toks = regexp(txt,{'frame=(\d+)','progress=(\S+)'},'tokens');
      if ~isempty(toks{1})
         val = str2double(toks{1}{end}{1});
         if val>0
            waitbar(val/N,h,'Video transcoding in progress...');
            drawnow;
         end
      end
end
end

function cleanup(tobj,progfile,progfcn)

if ~isempty(tobj)
   stop(tobj);
   delete(tobj);
end
progfcn('delete'); % just in case
if exist(progfile,'file')
   delete(progfile);
end

end
