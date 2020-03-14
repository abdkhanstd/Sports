% Add the speech2text folder to MATLAB search path and save it for future
% MATLAB sessions. Also, if the current MATLAB release is R2019b or newer,
% install SpeechToText automation algorithm for Audio Labeler app.

%   Copyright 2019 The MathWorks, Inc.

% Add speech2text folder to MATLAB path.
setupFilePath = fileparts(mfilename('fullpath'));
speech2textFilePath = fileparts(setupFilePath);
addpath(speech2textFilePath);
savepath

% Install SpeechToText automation algorithm in Audio Labeler app. If Audio
% Labeler is already open, it needs to be restarted for the algorithm to
% show up.
if ~isempty(ver('audio')) && ~verLessThan('audio','2.1')
    registry = audio.labeler.automation.AutomationAlgorithmRegistry.getInstance;
    registry.addAlgorithm('SpeechToTextAutomation');
end
