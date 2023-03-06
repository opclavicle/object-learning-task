 Screen('Preference', 'SkipSyncTests', 0);
% Day 1 20190712
% a preview first
 %  Press "Esc" can stop experiment
% Output: subjID_object_Day1_acq.mat
% change with location, around 1.56 degrees
% change with image size
% fix masks repetition problem
% 5 stimuli in a stimulus set, 6 s
% from Learning phase in 12 hours gap	Baeck et al., 2014 
% frameRate detection: line 88 should be comment in real experiment
% werkgeheugen wordt gewist, niet nodig indien programma als functie loopt
% function maskingexperiment(subjID, acq, condition)
% In one full practice session, participants would be trained by eight blocks of 100 trials (two staircases of 50 trials each).
% try to remove the try and catch 20171221
% maskDur each 250ms
% screenNumber=0 % if you want to display stimuli on the main screen
% each staircase had 50 trials with each object in the set presented twice
% caculation for individual thresholds
% The individual thresholds were calculated per block based on the average of the last four turning points of every staircase.
%% Day 1
% 5 stimuli in control; 5 stimuli in ex peach conditon 4 times; total 800

%% uncomment these parameters and comment 'function'-line if you want to run it like a script

subjID=110;%
 acq=1;  % 1, 2 , 3, 4 

 if acq==1
  condition = [1 2];
 else
 end
warning off;

% set general parameters of experiment
Dir.s = 'C:\code_learning_stimulus_presentation\code_CYC\6sets_20190710\';
Dir.m = 'C:\code_learning_stimulus_presentation\code_CYC\';

n_mask = 20; % number of mask; assumption that there are also that many masks
n_stimuli=5;
n_staircasePerBlock= 100;

fmt = 'tif';
%background_color=[144 144 144]; %% not > 110 to avoid colored background
background_color=[203 203 203]; %% not > 110 to avoid colored background

itemDur_sec          = 0.12; 
maskDur_sec         = 0.25;
feedbackDur_sec   = 1.00;
test_sec                   = 0.01;
% for caculation Day 1 
n_t_stimuli = n_stimuli*2; 
numBlocks = 2 ; %number of stimuli set

% set number and codition here
num_block=2;
Day = 1;
% day1

% % put the complete startup-sequence in a try-catch block to prevent
% % freezing of the computer while the Screen function is on
 try

% This script calls Psychtoolbox commands available only in OpenGL-based 
% versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL 
% will issue an error message if someone tries to execute this script on a 
% computer without an OpenGL Psychtoolbox
AssertOpenGL;   

%determine stimulus folder
                    thedir = char([Dir.s 'stimuli_5s_cond2'], ...
                                         [Dir.s 'stimuli_5s_cond5'], ...
                              	         [Dir.m 'ruisstimuli_corrected']);          
[numConds junk] = size(thedir);

%% make sure that the output file does not exist yet
fid = fopen([num2str(subjID) '_object_Day1_' num2str(acq) '.mat']);
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

% % dit gaat niet mogelijk zijn bij het programmeren, wel opnieuw uit
% % commentaar zetten bij eigenlijke testen
if frameRate ~= 100
	  disp('!!!!! FRAMERATE SHOULD BE 100 !!!!!')
	 disp('				Program stopped ')
     Screen('CloseAll')
   return;
end;	  

% perform extra calibration pass to estimate monitor refresh interval
[ifi , ~, stddev] = Screen('GetFlipInterval', window, 100, 0.005, 20); 

% define textsize for onScreen messages 
Screen(window,'TextSize',25);

% Use realtime priority for better timing precision
priorityLevel=MaxPriority(window);
Priority(priorityLevel);

% load the images 
% con1=stimuli 5
% con2= stimuli 5
% con3= 20 masks
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
        if  cond==numBlocks+1
         filename{n_t_stimuli+theitem} = itemlist{2+theitem}; % 2+ to get rid of . and ..
         imgArray = imread(filename{n_t_stimuli+theitem}, fmt);
         imgArray = double(imgArray); 
         tex(n_t_stimuli+theitem)=Screen('MakeTexture', window, imgArray(:,:,1));
        end
                %for the objects we will read in their filename, and use that to
                %determine the correct response
         if cond ==numBlocks+1
         else
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

opeenvolgend_juist_1=0;
opeenvolgend_juist_2=0;

%% duration turn to 1,2,3,25

% itemDur1     = round(itemDur_sec * frameRate);
% itemDur2     = round(itemDur_sec * frameRate);
maskDur      = round(maskDur_sec * frameRate);
% maskDur=round(maskDur_sec * frameRate)/3 ;%because three masks shown

testDur           = round(test_sec * frameRate);
feedbackDur = round(feedbackDur_sec * frameRate);
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
    Day1_con = condition(theBlock);
    timing.block(theBlock).start = GetSecs;   
    itemDur1 =  round(itemDur_sec * frameRate);
    itemDur2 =  round(itemDur_sec * frameRate);
    
    for i = 1: n_staircasePerBlock % n_mask
        while KbCheck, end
        responded = 0; 
        responseChar=zeros(1,2); % 		responseChar=zeros(1,3);
        if Day1_con ==1
        thepic = theorder(i, theBlock);
        else % +5
        tempic = theorder(i, theBlock);
        thepic=tempic+(Day1_con-1)*n_stimuli;
        end
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

                % Show the image
                  Screen('DrawTexture', window, tex(thepic), [], [screenCenter(1)-(pixRect(3)/2) screenCenter(2)-(pixRect(4)/2) screenCenter(1)+(pixRect(3)/2) screenCenter(2)+(pixRect(4)/2)]+[raposx raposy raposx raposy]);
%                    [vbl timing.block(theBlock).stimulus(i).stimulus]=Screen('Flip', window, [vbl+(testDur-0.5)*ifi]);    
%                    this time is for fixation
                     [vbl timing.block(theBlock).stimulus(i).fix]=Screen('Flip', window, [vbl+(maskDur-0.5)*ifi]);    
                    if mod(i,2) 
                             [vbl timing.block(theBlock).stimulus(i).stimulus]=Screen('Flip', window, [vbl+(itemDur1-0.5)*ifi]);
                             trialItemDur(theBlock, i) = itemDur1;
                    else
                             [vbl timing.block(theBlock).stimulus(i).stimulus]=Screen('Flip', window, [vbl+(itemDur2-0.5)*ifi]);
                             trialItemDur(theBlock, i) = itemDur2;
                    end
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
      %  check correctness of response 
     if responseChar(1)==correctResponse{thepic}(1) && responseChar(2)==correctResponse{thepic}(2)
                key(theBlock, i) = 1; % correct trial
                Screen('DrawText', window, 'CORRECT!', [screenCenter(1)-170], [screenCenter(2)], black);                           
                if mod(i,2) %first staircase
                    opeenvolgend_juist_1= opeenvolgend_juist_1 + 1;
                    if opeenvolgend_juist_1 == 2 %wanneer 2 opeenvolgende trials juist beantwoord worden, wordt de aanbiedingsduur bij volgende trial verminderd  
                        itemDur1= itemDur1-1; 
                        if itemDur1<1
                           itemDur1 = 1;                        
                        end
                        opeenvolgend_juist_1 = 0;
                    end   
                    
                else %second staircase
                     opeenvolgend_juist_2= opeenvolgend_juist_2 + 1;
                    if opeenvolgend_juist_2 == 2 %wanneer 2 opeenvolgende trials juist beantwoord worden, wordt de aanbiedingsduur bij volgende trial verminderd  
                        itemDur2= itemDur2-1;
                        if itemDur2<1
                           itemDur2 = 1;                        
                        end
                        opeenvolgend_juist_2 = 0;
                    end   
                end           
     else     % incorrect trials % reverse, keep recording it            
                key(theBlock, i) = 0; % incorrect trial naam{thepic}
                stimulusname=correctResponse{thepic};
                Screen('DrawText', window, 'FOUT! Het was ', [screenCenter(1)-270], [screenCenter(2)], black);
                Screen('DrawText', window,  stimulusname, [screenCenter(1)+80], [screenCenter(2)], black);             
                if mod(i,2)
                    opeenvolgend_juist_1=0;
                    itemDur1= itemDur1+1;
                else
                    opeenvolgend_juist_2=0;
                    itemDur2= itemDur2+1;
                end
     end % checking correction of typing 
             [vbl timing.block(theBlock).stimulus(i).feedback]=Screen('Flip', window,[vbl+(feedbackDur-0.5)*ifi]); %blank screen);       
    end
end
    timing.itIsOver = GetSecs;        
    ShowCursor;
    Screen('CloseAll');

     save([num2str(subjID) '_object_Day1_' num2str(acq) '.mat'], 'key', 'theorder', 'theorderMasks', 'subjID', 'acq', 'frameRate', ...
    'Ima_Size','Ima_Loc', 'trialItemDur', 'responseCharPerTrial','timing', 'screenWidth', 'screenHeight', 'condition', 'Day');
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