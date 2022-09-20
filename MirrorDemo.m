% Clear the workspace and the screen
sca;
close all;
clearvars;

% Setup with some default values
PsychDefaultSetup(2);

% Reseed the random-number generator for each expt.
rand('state',sum(100*clock));
%rng(seed);

%comment out when not connected to BioSemi
sp = BioSemiSerialPort();

%Set higher DebugLevel, so that you don't get all kinds of messages flashed
%at you each time you start the experiment:
olddebuglevel=Screen('Preference', 'VisualDebuglevel', 3);

%----------------------------------------------------------------------
%                             Screen setup
%----------------------------------------------------------------------

screens=Screen('Screens');
screenNumber=max(screens);

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

data.subjectID = input('Please enter your subject ID number: ','s');
% Prepare imaging pipeline:
%PsychImaging('PrepareConfiguration');

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey); %lab machine is 1024 768
% ^^ don't use until code is finished this function can take over the computer and is a pain
%[window, windowRect] = Screen('OpenWindow', screenNumber, [.5,.5, .5]*255, [10, 10, 1240, 700]);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Keyboard setup
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey escapeKey]);

%----------------------------------------------------------------------
%                      Experimental Image List
%----------------------------------------------------------------------

% Get the image files for the experiment
%humanFolder = [cd '/Documents/MATLAB/human/'];
humanFolder = [cd '\human\'];

%humanFolder = [cd '/human/']; % mac path
humanImgList = {'human1.png', 'human2.png', 'human3.png','human4.png','human5.png','human6.png', 'human7.png', 'human8.png', ...
    'human9.png','human10.png', 'human11.png', 'human12.png', 'human13.png', 'human14.png', 'human15.png', 'human16.png', ....
    'human17.png', 'human18.png'};

%robotFolder = [cd '/Documents/MATLAB/robot/'];
robotFolder = [cd '\robot\'];

%robotFolder = [cd '/robot/']; %mac path
robotImgList = {'robot1.png', 'robot2.png','robot3.png','robot4.png','robot5.png', 'robot6.png', 'robot7.png', ...
    'robot8.png', 'robot9.png', 'robot10.png', 'robot11.png', 'robot12.png', 'robot13.png', 'robot14.png', ...
    'robot15.png','robot16.png', 'robot17.png', 'robot18.png', 'robot19.png', 'robot20.png', 'robot21.png', 'robot22.png', ...
    'robot23.png', 'robot24.png', 'robot25.png', 'robot26.png', 'robot27.png', 'robot28.png', 'robot29.png', 'robot30.png',};

%----------------------------------------------------------------------
%                        Fixation Cross
%----------------------------------------------------------------------
% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

%----------------------------------------------------------------------
%                      Experimental Loop
%----------------------------------------------------------------------
% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems (not absolutely necessary, but good practice):
KbName('UnifyKeyNames');

%get rid of the mouse cursor, we don't have anything to click at anyway
%HideCursor;

% Preparing and displaying the welcome screen
Screen('TextSize', window, 60);

% Start screen
DrawFormattedText(window, 'Press Space To Begin', 'center', 'center', black);
% Show the drawn text at next display refresh cycle:
HideCursor();

Screen('Flip', window);

% Wait for key stroke
KbWait;

varNames = {'Block' 'Condition' 'imgName'};
varTypes = {'string' 'string' 'string'};
resultsTable = table('Size', [192 3], 'VariableTypes', varTypes, 'VariableNames', varNames);
%resultsTable.Properties.Description = 'This table tracks the order human/robot images';

% human block
%generate random order of images and write to results file
data.human_Iteration1 = randperm(18,18); % 18 rand numbers 1-18
data.human_Iteration2 = randperm(18,18);
data.human_Iteration3 = randperm(18,18);

n = 1;

for humanLoop = 1:3
    for trial = 1:18
        %KbWait;
        % Define the file names
        if(humanLoop == 1)
            humanImage = ['human' num2str(data.human_Iteration1(trial)) '.png'];
        elseif(humanLoop == 2)
            humanImage = ['human' num2str(data.human_Iteration2(trial)) '.png'];
        elseif(humanLoop == 3)
            humanImage = ['human' num2str(data.human_Iteration3(trial)) '.png'];
        end
        
        trialTypeLabel = "Human";
        hBlock = "Human";
        resultsTable(n, :) = {hBlock, trialTypeLabel, humanImage};
        
        % Now load the images
        bg = [.5 .5 .5];
        theHumanImage = imread([humanFolder humanImage], 'BackgroundColor',bg);
        %humanResize = imresize(theHumanImage, .4, 'nearest');
        
        % Make the images into textures
        texHuman = Screen('MakeTexture', window, theHumanImage);
        
        % Draw the textures and blank frame
        Screen('DrawTexture', window, texHuman);
        
        % Draw the fixation cross in white, set it to the center of our screen and
        % set good quality antialiasing
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        
        % Flip to the screen
        Screen('Flip', window);
        
        %%%%%%%%%%%%comment out when not connected to BioSemi
        sp.sendTrigger(1);
        WaitSecs(1);
        
        % grey filler
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        
        Screen('Flip', window);
        WaitSecs(1); %show cross for 1 sec
        
        
        % Poll the keyboard for the space key
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyCode(spaceKey) == 1
            respMade = 1;
        elseif keyCode(escapeKey) == 1
            sca;
            disp('*** Experiment terminated ***');
            return
        end
        
        Screen('Close', texHuman);
        n = n +1;
    end
end

Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

Screen('Flip', window);
WaitSecs(2);

%generate random order of images and write to results file
data.robot_Iteration1 = randperm(30,30); % 30 rand numbers 1-30
data.robot_Iteration2 = randperm(30,30);
data.robot_Iteration3 = randperm(30,30);

for robotLoop = 1:3
    for trial = 1:30
        %KbWait;
        % Define the file names
        if(robotLoop == 1)
            robotImage = ['robot' num2str(data.robot_Iteration1(trial)) '.png'];
        elseif(robotLoop == 2)
            robotImage = ['robot' num2str(data.robot_Iteration2(trial)) '.png'];
        elseif(robotLoop == 3)
            robotImage = ['robot' num2str(data.robot_Iteration3(trial)) '.png'];
        end
        
        rBlock = "Robot";
        trialTypeLabel = "Robot";
        resultsTable(n, :) =  {rBlock, trialTypeLabel, robotImage};
        
        % Now load the images
        bg = [.5 .5 .5];
        theRobotImage = imread([robotFolder robotImage], 'BackgroundColor',bg);
        %robotResize = imresize(theRobotImage, .4, 'nearest');
        
        % Make the images into textures
        texRobot = Screen('MakeTexture', window, theRobotImage);
        
        % Draw the textures and blank frame
        Screen('DrawTexture', window, texHuman);
        
        % Draw the fixation cross in white, set it to the center of our screen and
        % set good quality antialiasing
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        
        % Flip to the screen
        Screen('Flip', window);
        
        %%%%%%%%%%%%%comment out when not connected to BioSemi
        sp.sendTrigger(2);
        WaitSecs(1); %show for image for 1 sec   
        
        % grey filler
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2);
        
        
        Screen('Flip', window);
        WaitSecs(1); %show for 1 sec
        
        % Poll the keyboard for the space key
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyCode(spaceKey) == 1
            respMade = 1;
        elseif keyCode(escapeKey) == 1
            sca;
            disp('*** Experiment terminated ***');
            return
        end
        
        Screen('Close', texRobot);
        n = n + 1;
    end
end

Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

Screen('Flip', window);
WaitSecs(2);

% alternating block
%we should figure out which images we want to put in this loop and how
%many right now I have it grabbing the first 15 of both conditions
alternatingHumanOrder = randperm(18,15); %random 15 numbers 1-18
alternatingRobotOrder = randperm(30,15);
altHumanTrial = 1;
altRobotTrial = 1;

% Poll the keyboard for the space key
[keyIsDown, secs, keyCode] = KbCheck(-1);
if keyCode(spaceKey) == 1
    respMade = 1;
elseif keyCode(escapeKey) == 1
    sca;
    disp('*** Experiment terminated ***');
    return
end

% For this block we have a (1) "human" condition and (2) "robot"
% We will call this our "trialType"
trialType = [1 2];

% Each condition has 15 examples
numExamples = 15;

% Make a condition matrix
trialLine = repmat(trialType, 1, numExamples);
%exampleLine = sort(repmat(1:numExamples, 1, 2));
condMat = trialLine;

% Shuffle the conditions
shuffler = Shuffle(1:30);
condMatShuff = condMat(:, shuffler);

% Make a directory for the results
resultsDir = [cd '/Results/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end

for trial = 1:30
    %KbWait;
    % Poll the keyboard for the space key
    [keyIsDown, secs, keyCode] = KbCheck(-1);
    if keyCode(spaceKey) == 1
        respMade = 1;
    elseif keyCode(escapeKey) == 1
        sca;
        disp('*** Experiment terminated ***');
        return
    end
    
    % Now load the images
    bg = [.5 .5 .5];
    % Get this trials information
    thisTrialType = condMatShuff(1, trial);
    
    % Define the trial type label
    if thisTrialType == 1
        trialTypeLabel = 'human';
        
        thisExample = alternatingHumanOrder(altHumanTrial);
        altImg = [trialTypeLabel num2str(thisExample) '.png'];
        theAltImg = imread([humanFolder altImg], 'BackgroundColor',bg);
        %imgResize = imresize(theAltImg, .4, 'nearest');
        
        altHumanTrial = altHumanTrial + 1;
    elseif thisTrialType == 2
        trialTypeLabel = 'robot';
        thisExample = alternatingRobotOrder(altRobotTrial);
        altImg = [trialTypeLabel num2str(thisExample) '.png'];
        theAltImg = imread([robotFolder altImg], 'BackgroundColor',bg);
        %imgResize = imresize(theAltImg, .4, 'nearest');
        
        altRobotTrial = altRobotTrial + 1;
    end
    
    altBlock = "Alternating";
    resultsTable(n, :) = {altBlock, trialTypeLabel, altImg};
    n = n+1;
    
    % Make the images into textures
    texAlt = Screen('MakeTexture', window, theAltImg);
    
    % Draw the textures and blank frame
    Screen('DrawTexture', window, texAlt);
    
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    
    % Flip to the screen
    Screen('Flip', window);
    
    %%%%%%comment out when not connected to BioSemi
    sp.sendTrigger(thisTrialType);
    WaitSecs(1); %show for image for 1 sec
    
    
    % grey filler
    Screen('FillRect', window, grey);
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    
    Screen('Flip', window);
    WaitSecs(1); %show cross for 1 sec
    
    % Make a  matrix which which will hold the order of images
    %data.resultsMatrix = table('VariableNames', {'thisTrialType' 'thisExample'});
    %data.resultsMatrix(:, 1:2) = condMatShuff';
    
    Screen('Close', texAlt);
    
end

%save data
resultsFolder = [cd '/MATLAB/Results/'];
filename = [data.subjectID '_data.csv'];
writetable(resultsTable, filename, 'QuoteStrings', true);

ListenChar(0); %makes it so characters typed do show up in the command window
ShowCursor(); %shows the cursor
Screen('CloseAll'); %Closes Screen

%to load data fields in matlab:
% >> load test_data#.mat
% >> human_order
% >> robot_order

return;