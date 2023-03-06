% only day1 and day5
%function preview(condition)
% dit programma toont alle stimuli van een bepaalde conditie
% met de stimulus wordt ook de naam gepresenteerd

%clear; %werkgeheugen wordt gewist, niet nodig indien programma als functie
sca
clear all

warning off;

%% parameters experiment
Dir.s = 'C:\code_learning_stimulus_presentation\code_CYC\6sets_20190710\';

% itemsPerBlock = 20; % number of stimuli
n_stimuli=5;
pixRect = [0 0 450 450];  %% this is going to be the desired rectangle -- images will be scaled appropriately
%background_color=[144 144 144]; %% not > 110 to avoid colored background
background_color=[203 203 203]; %% not > 110 to avoid colored background
previewDur= 2; % preview duration in 2 sec
fmt='tif';

% put the complete startup-sequence in a try-catch block to prevent
% freezing of the computer while the Screen function is on
try

% This script calls Psychtoolbox commands available only in OpenGL-based 
% versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL 
% will issue an error message if someone tries to execute this script on a 
% computer without an OpenGL Psychtoolbox
AssertOpenGL;    
    
timing.startup=GetSecs;    
   thedir = char([Dir.s 'stimuli_5s_cond2'], ...
                 [Dir.s 'stimuli_5s_cond5']);
[numConds junk] = size(thedir);

                                          	 
% Decide which screen is used to display the stimuli  
screens=Screen('Screens');
screenNumber=max(screens);

% open screen
 window=Screen('OpenWindow', screenNumber,background_color(1));
%  window=Screen('OpenWindow', 1,background_color(1));
 Screen('Flip', window);

% properties of window
[screenWidth screenHeight]=WindowSize(window);
frameRate=Screen('NominalFrameRate',window);
screenCenter= [screenWidth/2 screenHeight/2];
black=BlackIndex(window);

% define textsize for onScreen messages 
Screen(window,'TextSize',25); % main is 25
% 
% % load the images 
    for cond = 1:numConds
            cd(deblank(thedir(cond,:)));
            d = dir;
            [numItems junk] = size(d);
            [itemlist{1:numItems}] = deal(d.name);
    % filename 13 charactors
        for theitem = 1:n_stimuli
              filename{((cond-1)*n_stimuli)+theitem} = itemlist{2+theitem} ;% 2+ to get rid of . and ..
              imgArray = imread(filename{((cond-1)*n_stimuli)+theitem}, fmt);
              imgArray = double(imgArray); 
            % load the images into textures
              tex(((cond-1)*n_stimuli)+theitem)=Screen('MakeTexture', window, imgArray(:,:,1));
              stimulusname{(((cond-1)*n_stimuli)+theitem)} = itemlist{theitem+2}(1:13);
%                     end
        end
    end

ListenChar(2);
HideCursor;

% Show task instructions until t is pressed
Screen('DrawText', window, 'De stimuli worden met hun naam getoond', [screenCenter(1)-300], [screenCenter(2)], black);
Screen('Flip', window);
    
KbWait;

timing.readyToGo = GetSecs; 

% tonen stimuli met naam 
  for i = 1:n_stimuli*2	
      Screen('DrawTexture', window, tex(i), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]);
      naam=stimulusname{i};
      Screen('DrawText', window, naam, [screenCenter(1)-(pixRect(3)/2)+60], [screenCenter(2)-(pixRect(4)/2)], black);  
      Screen('Flip', window);   
      WaitSecs(previewDur);
    		
  end

timing.end = GetSecs; 
ListenChar(0);
Screen('CloseAll');

cd ../;

%the "catch" section executes in case of an error in the "try" section
%most importantly, it will close the onscreen window
catch
    % Close display windows
    Screen('CloseAll');
    ShowCursor;       
   ListenChar(0);
    %restore priority
    Priority(0);
    % tell user what caused the crash
    rethrow(lasterror);     
end
