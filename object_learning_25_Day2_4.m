 Screen('Preference', 'SkipSyncTests', 1);
% Day2-4  20190712 For short-reactivation group
% note1: fixed threshold      itemDur_sec = XX
% note2: 5x5 n_staircasePerBlock= 5 ;% for this condition
% caculation for individual thresholds
% here we will use 4 reversals
% Output: subjID_object_25_Day2_25.mat
% This is a speedy test
%% uncomment these parameters and comment 'function'-line if you want to run it like a script
clear all


subjID=65;
itemDur_sec = 0.06; % fixed threshold applied to itemDur2 
This_day =3;% Day 2,3,4
 condition=2; % determine stimulus folder
 
% 
% subjID=103;
% itemDur_sec = 0.03; % fixed threshold applied to itemDur2 
% This_day = 4;% Day 2,3,4
% 
%  condition=1; % determine stimulus folder

warning off;

% set general parameters of experiment
Dir.s = 'C:\code_learning_stimulus_presentation\code_CYC\6sets_20190710\';
Dir.m = 'C:\code_learning_stimulus_presentation\code_CYC\';

n_mask = 20; % number of mask; assumption that there are also that many masks
n_stimuli = 5;
n_staircasePerBlock= 5 ;% for this condition
% programming
n_t_stimuli = n_stimuli; 
num_block = 5;

fmt = 'tif';
% pixRect = [0 0 450 450];  %% this is going to be the desired rectangle -- images will be scaled appropriately
%background_color=[144 144 144]; %% not > 110 to avoid colored background
background_color=[203 203 203]; %% not > 110 to avoid colored background

maskDur_sec =  0.25;
feedbackDur_sec = 1.00;
test_sec          = 0.01;
% put the complete startup-sequence in a try-catch block to prevent
% freezing of the computer while the Screen function is on
 try

% This script calls Psychtoolbox commands available only in OpenGL-based 
% versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL 
% will issue an error message if someone tries to execute this script on a 
% computer without an OpenGL Psychtoolbox
AssertOpenGL;   

%determine stimulus folder
if condition==1
   thedir = char([Dir.s 'stimuli_5s_cond2'], ...
						[Dir.m 'ruisstimuli_corrected']); 
elseif condition==2
   thedir = char([Dir.s 'stimuli_5s_cond5'], ...
						[Dir.m 'ruisstimuli_corrected']); 
end
                     
[numConds junk] = size(thedir);

%% make sure that the output file does not exist yet
fid = fopen([num2str(subjID) '_object_25_Day'  num2str(This_day) '.mat']);
if fid~=-1
	  disp('!!!!! OUTPUT FILE EXISTS ALREADY !!!!!')
			disp('				Program stopped to avoid deletion of these previous data')
   return;
end;	 
% Decide which screen is used to display the stimuli  
screens=Screen('Screens');
screenNumber=max(screens);
% open screen
   window=Screen('OpenWindow', screenNumber,background_color(1));
%   window=Screen('OpenWindow', 1,background_color(1));

% properties of window
[screenWidth screenHeight]=WindowSize(window);
frameRate=Screen('NominalFrameRate',window);
screenCenter= [screenWidth/2 screenHeight/2];
black=BlackIndex(window);
% 
% % dit gaat niet mogelijk zijn bij het programmeren, wel opnieuw uit
% % commentaar zetten bij eigenlijke testen
% if frameRate ~= 100
% 	  disp('!!!!! FRAMERATE SHOULD BE 100 !!!!!')
% 	 disp('				Program stopped ')
%      Screen('CloseAll')
%    return;
% end;	 

% perform extra calibration pass to estimate monitor refresh interval
[ifi , ~, stddev] = Screen('GetFlipInterval', window, 100, 0.005, 20); 

% define textsize for onScreen messages 
Screen(window,'TextSize',25);

% Use realtime priority for better timing precision
priorityLevel=MaxPriority(window);
Priority(priorityLevel);

% load the images 
% con1=stimuli 5
% con2= mask 20
    % name of object from 11 to 13
for cond = 1:numConds
    cd(deblank(thedir(cond,:)));
    d = dir;
    [numItems junk] = size(d);
    [itemlist{1:numItems}] = deal(d.name);
    % filename 
    for theitem = 1:(numItems-2)
         filename{((cond-1)*(numItems-2))+theitem} = itemlist{2+theitem}; % 2+ to get rid of . and ..
         imgArray = imread(filename{((cond-1)*(numItems-2))+theitem}, fmt);
         imgArray = double(imgArray); 
        % load the images into textures
         tex(((cond-1)*(numItems-2))+theitem)=Screen('MakeTexture', window, imgArray(:,:,1));
               % masks
                if  cond==1
                else
                 filename{n_t_stimuli+theitem} = itemlist{2+theitem}; % 2+ to get rid of . and ..
                 imgArray = imread(filename{n_t_stimuli+theitem}, fmt);
                 imgArray = double(imgArray); 
                 tex(n_t_stimuli+theitem)=Screen('MakeTexture', window, imgArray(:,:,1));
                end
                %for the objects we will read in their filename, and use that to
                %determine the correct response
                 if cond ==1
                 correctResponse{(cond-1)*(numItems-2)+theitem} = filename{((cond-1)*(numItems-2))+theitem}(1:13);
                 end
    end
end
cd(Dir.s);

%% decide the order in which stimuli will appear in each block
theorder = zeros(n_staircasePerBlock, num_block);

for block = 1:num_block
                X=[];
                for ii=1:n_staircasePerBlock/n_stimuli
                r=randperm(5);
                X=[X,r];
                end
                theorder(:, block) = X';
end
theorderMasks = zeros(n_staircasePerBlock, num_block,3);
for i = 1:num_block
        	thelist1 = randi(n_mask,1,n_staircasePerBlock)';
  	        theorderMasks(:,i, 1) =  n_t_stimuli+thelist1;
    	    thelist2 = randi(n_mask,1,n_staircasePerBlock)';
            theorderMasks(:,i, 2) =  n_t_stimuli+thelist2;
        	thelist3 = randi(n_mask,1,n_staircasePerBlock)';
  	 		theorderMasks(:,i, 3) =  n_t_stimuli +thelist3;
end

key = zeros(num_block, n_staircasePerBlock); % to store performance

itemDur2 =  round(itemDur_sec * frameRate);
maskDur =  round(maskDur_sec * frameRate);
feedbackDur   = round(feedbackDur_sec * frameRate);
testDur           = round(test_sec * frameRate);
% hide mouse and lock keyboard to ruin 
HideCursor;
ListenChar(2);

% Show task instructions until key is pressed
Screen('DrawText', window, 'Benoem de figuur', [screenCenter(1)-170], [screenCenter(2)], black);
Screen('Flip', window);
KbWait;

vbl=Screen('Flip', window); % initial sync is needed to sync us to the VBL

%start experiment
timing.experimentStart = GetSecs;

for theBlock = 1:num_block
       timing.block(theBlock).start = GetSecs;   
    for i = 1:n_staircasePerBlock
        
        while KbCheck, end        
        responded = 0; 
        responseChar=zeros(1,2);
        thepic = theorder(i, theBlock);
 		themask1 = theorderMasks(i, theBlock,1);
		themask2 = theorderMasks(i, theBlock,2);
		themask3 = theorderMasks(i, theBlock,3);
		%% determine the screen position of the next stimulus + mask
        raposy = round(50 - 100*rand);
        raposx = round(50 - 100*rand);
        %         pixRect need to be random
        Ima_Loc(theBlock).x(i).pixel =raposx ;
        Ima_Loc(theBlock).y(i).pixel =raposy ;
        imagesize = round(450 - 200*rand);
        Ima_Size(theBlock).imagesize(i).pixel =imagesize;
        pixRect = [0 0 imagesize imagesize];
        
       %pre-stimulus period ; i-1 and i is for feedback
        [vbl timing.block(theBlock).stimulus(i).blank]=Screen('Flip', window, [vbl+(feedbackDur-0.5)*ifi]); %blank screen
        % enlarge a circle
        % Screen('FillOval', window, black, [screenCenter(1)-4 screenCenter(2)-4 screenCenter(1)+4 screenCenter(2)+4]);
        Screen('FillOval', window, black, [screenCenter(1)-8 screenCenter(2)-8 screenCenter(1)+8 screenCenter(2)+8]);
        %  this time is for blank
        [vbl timing.block(theBlock).stimulus(i).base]=Screen('Flip', window, [vbl+(testDur-0.5)*ifi]);

        %% Show the image
        Screen('DrawTexture', window, tex(thepic), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]+[raposx raposy raposx raposy]);
 %    this time is for fixation
        [vbl timing.block(theBlock).stimulus(i).fix]=Screen('Flip', window, [vbl+(maskDur-0.5)*ifi]);    
        % threshold
                             [vbl timing.block(theBlock).stimulus(i).stimulus]=Screen('Flip', window, [vbl+(itemDur2-0.5)*ifi]);
                             trialItemDur(theBlock, i) = itemDur2;
        
       % show mask
        Screen('DrawTexture', window, tex(themask1), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]+[raposx raposy raposx raposy]);   
        % buffer
        [vbl timing.block(theBlock).stimulus(i).answer1]=Screen('Flip', window, [vbl+(testDur -0.5)*ifi]);
        Screen('DrawTexture', window, tex(themask2), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]+[raposx raposy raposx raposy]);
        % mask1
        [vbl timing.block(theBlock).stimulus(i).answer2]=Screen('Flip', window, [vbl+(maskDur-0.5)*ifi]);
        Screen('DrawTexture', window, tex(themask3), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]+[raposx raposy raposx raposy]);
        % mask2
        [vbl timing.block(theBlock).stimulus(i).answer3]=Screen('Flip', window, [vbl+(maskDur-0.5)*ifi]);
        %  mask3       
        [vbl timing.block(theBlock).stimulus(i).endstim]=Screen('Flip', window, [vbl+(maskDur-0.5)*ifi]);
        
        %% collect a key response
        FlushEvents;
        while responded < 2
            responded = responded + 1;
            [responseChar(responded) junk] = GetChar;
            if  responseChar(responded)==27 % 'esc'
                             ListenChar(0);
                             Screen('CloseAll')
                             return;
            end
            while KbCheck, end %% to avoid problems if subjects press too long
        end
         responseCharPerTrial{(theBlock-1)*n_staircasePerBlock + i} = responseChar; %save response
          
     if responseChar(1)==correctResponse{thepic}(1) && responseChar(2)==correctResponse{thepic}(2)
                key(theBlock, i) = 1; % correct trial
                Screen('DrawText', window, 'CORRECT!', [screenCenter(1)-170], [screenCenter(2)], black);                
     else               
                key(theBlock, i) = 0; % incorrect trial naam{thepic}
                stimulusname=correctResponse{thepic};
                Screen('DrawText', window, 'FOUT! Het was ', [screenCenter(1)-270], [screenCenter(2)], black);
                Screen('DrawText', window,  stimulusname, [screenCenter(1)+80], [screenCenter(2)], black);
     end% checking correction of typing 
     [vbl timing.block(theBlock).stimulus(i).feedback]=Screen('Flip', window,[vbl+(feedbackDur-0.5)*ifi]); %blank screen);       
    end
end
    timing.itIsOver = GetSecs;        
    ShowCursor;
    Screen('CloseAll');

     save([num2str(subjID) '_object_25_Day'  num2str(This_day) '.mat'], 'key', 'theorder', 'theorderMasks', 'subjID', 'frameRate', ...
    'Ima_Size','Ima_Loc', 'trialItemDur', 'responseCharPerTrial','timing', 'screenWidth', 'screenHeight', 'condition');
    warning on;

%the "catch" section executes in case of an error in the "try" section
%most importantly, it will close the onscreen window
 catch
        ListenChar(0);
    % Close display windows
    Screen('CloseAll');
    ShowCursor;           
    %restore priority
    Priority(0);   
    % tell user what caused the crash
    rethrow(lasterror);     
end