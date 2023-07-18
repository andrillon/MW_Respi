%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Project WANDERLUST - INTERMODULATION
%%%%%
%%%%%
%%%%%
%%%%% Written by Thomas Andrillon
%%%%% Email: thomas.andrillon@gmail.com
%%%%%
%%%%% v2:
%%%%%   - calibration and training added
%%%%%   - sound added to probe
%%%%%   - modifications of kanisza squares
%%%%%   - modified version
%%%%% v3:
%%%%%   - correction of bug from v2 (num of probes, RT saving)
%%%%%   - adaptation of the script to the Psych Building EEG set-up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% init matlab
% clear all variables and close all figures
clear all;
close all;
% set rand function on the clock
rand('seed',sum(100*clock));
trai_res=[];
test_res=[];
probe_res=[];

% add the folder in the path
% if ismac
%     root_path='/Users/Thomas/Work/PostDoc/Monash/WanderIM/ExpeFolder/ExpeScripts';
% else
root_path='C:\manips\MW_RESPI\ExpeFolder\ExpeScripts';
% end
cd(root_path)
addpath(pwd)
% add PTB in the path
% PTB_path='/Applications/Psychtoolbox/';
% if exist('Screen')~=3
%     addpath(genpath(PTB_path));
%     fprintf('... adding PTB to the path\n')
% end
all_GrandStart=GetSecs;

stim_path=[root_path filesep '..' filesep 'ExpeStim'];

% Select debug mode (1 or 0), EEG (1 or 0), Tobii (1 or 0)
flag_smallw     = 0;
answerdebug=input('Type 0 (no) or 1 (yes, debug)');
flag_debug      = answerdebug;
flag_EEG        = 1; % EEG segments to be added in the future
flag_PPort      = 1; % Set to 1 if there is a parallel port to send triggers
flag_EyeLink      = 1; % Tobii segments to be added in the future
flag_skiptraining = 0;
flag_skipbaseline = 0;
flag_2diodes     = 0;
flag_1diodes     = 0;
flag_bip         = 0;
flag_escp        = 0;

supervised_questions = {...
    'Were you looking\nat the screen?\n\n - Yes : Press 1\n - No : Press 2  ',...
    'Where was your attention focus?\n\n - On-Task : Press 1\n\n - Off-Task : Press 2\n\n - Blank : Press 3\n\n - Don''t Remember : Press 4',...
    'What distracted your attention from the task?\n\nSomething:\n\n - in the room : Press 1\n\n - personal : Press 2\n\n - about the task : Press 3',...
    'How aware were you\nof your focus?\n\nFrom 1 : I was fully aware\n\nto  4 : I was not aware at all',...
    'Was your state of mind\nintentional?\n\nFrom 1 : Entirely intentional\n\nto 4 : Entirely unintentional',...
    ...
    'How engaging\nwere your thoughts?\n\nFrom 1 : Not engaging\n\nto 4 : Very engaging',...
    'How well do you think\nyou have been performing?\n\nFrom 1 : not good\n\nto 4 : very good',...
    'How alert have you been:\n\n - Extremely alert : Press 1\n\n - Alert : Press 2\n\n - Sleepy : Press 3\n\n - Extremely sleepy : Press 4'};

supervised_questions_headers={'Just before the interruption',...
    'Just before the interruption',...
    'Just before the interruption',...
    'Just before the interruption',...
    'Just before the interruption',...
    'Over the past few trials',...
    'Over the past few trials',...
    'Over the past few trials'};

supervised_questions_acceptedanswers={[1 2],[1 2 3 4],[1 2 3],[1:4],[1:4],[1:4],[1:4],[1:4]};

%% Enter subject info
if flag_debug
    subject         = 'debug';  % get subjects name
    subjectID       = '000';    % get subjects seed for random number generator
    sessionID       = 1;      % get session number
    expstart        = datestr(now,'ddmmmyyyy-HHMM');   % string with current date
    subjectGender   = NaN;
    subjectAge      = 'X';
    flicker_freqL        = 12;  % in Hertz of backgroud
    flicker_freqR       = 15;  % of box (try 16 or 22.4)
else
    subject         = input('Subject Initials:','s');      % get subjects name
    subjectID       = input('Subject ID (ex 301):','s');       % get subjects seed for random number generator
    subjectGender   =input('Male or Female (ex F):','s');
    subjectAge   =input('Age (ex 23):','s');
    sessionID       = 1; %str2num(answerdlg{3});      % get session number
    expstart        = datestr(now,'ddmmmyyyy-HHMM');   % string with current date
    
    numSub=str2num(subjectID);
    if rem(numSub,2)==1
        flicker_freqL        = 12;  % in Hertz of backgroud
        flicker_freqR       = 15;  % of box (try 16 or 22.4)
    else
        flicker_freqL        = 15;  % in Hertz of backgroud
        flicker_freqR       = 12;  % of box (try 16 or 22.4)
    end
%     ListenChar(2);
end
SubjectInfo.sub=subject;
SubjectInfo.subID=subjectID;
SubjectInfo.sessID=sessionID;
SubjectInfo.Age=subjectAge;
SubjectInfo.Gender=subjectGender;
SubjectInfo.Date=expstart;
SubjectInfo.FlagW=flag_smallw;
SubjectInfo.FlagEEG=flag_EEG;
SubjectInfo.FlagTobii=flag_EyeLink;
SubjectInfo.FlickerL=flicker_freqL;
SubjectInfo.FlickerR=flicker_freqR;

%% EEG
if flag_EEG
    % Check that the MEX file io64 is in the path
   OpenParPort( 64 );
    answerdebug2=input('Press 1 if EEG is recording (0 to abort):');
    if answerdebug2==0
        flag_escp=1;
    else
        WaitSecs(3);
%         SendTrigger( marqueurMessage );

        if flag_PPort
            % Code for triggers (must be between 0 and 255)
            %start/end recording
            trig_start          = 1; %S
            trig_end            = 11; %E
            trig_startBlock     = 2; %B
            trig_endBlock       = 22; %K
            trig_startTrial     = 64; %T
            trig_startQuestion  = 128; %Q
            trig_probestart     = 3; %P
            trig_probeend       = 33; %C
            trig_response       = 5; %C
            
            % Send a first trigger
            SendTrigger(trig_start);
            fprintf('>>>>>> CHECK START TRIGGER HAS BEEN SENT\n');
            WaitSecs(1);
        end
    end
else
    fprintf('>>>>>> EEG system won''t be used\n');
end
WaitSecs(1);

%% Audio
if flag_bip && flag_escp==0
    audiocheck=0;
    InitializePsychSound;
    freq = 44100;
    while audiocheck==0
        pahandle = PsychPortAudio('Open', [], [], 0, freq, 1);
        [beep,samplingRate] = MakeBeep(440,0.5,freq);
        PsychPortAudio('FillBuffer', pahandle, beep);
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        answerdebug2=input('Press 1 if sound is playing (2, to retry, 0 to abort):');
        if answerdebug2==0
            flag_escp=1;
            audiocheck=1;
        elseif answerdebug2==1
            audiocheck=1;
        elseif answerdebug2==2
            audiocheck=0;
        end
        PsychPortAudio('Stop', pahandle);
        PsychPortAudio('Close', pahandle);
    end
end

%% init PTB
screenNumbers = Screen('Screens');
numscreen = max(screenNumbers);
% set up screen display
if flag_smallw
    Prop=12;
    %     w = Screen('OpenWindow', numscreen, 0, [0, 0, 1920*(Prop-1)/Prop, 1080*(Prop-1)/Prop]+[1920 1080 1920 1080]*1/Prop/2);
    w = Screen('OpenWindow', numscreen, 0, [0, 0, 1200, 700]);
    InstrFont=36;
else
    w = Screen('OpenWindow', 2, 0, []);
    InstrFont=58;
    HideCursor;
end
Screen('TextSize',w, InstrFont);
ifi = Screen('GetFlipInterval',w,100);
[wx, wy] = Screen('WindowSize', w);
vbl = Screen('Flip', w);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('FillRect',  w, 0);
Screen('Flip',w);

% Parameters drawing
cross_fixCrossDimPix = 16; % Arm width
% set parameters for fixation cross
cross_lineWidthPix = 5;
cross_xCoords = [-cross_fixCrossDimPix cross_fixCrossDimPix 0 0];
cross_yCoords = [0 0 -cross_fixCrossDimPix cross_fixCrossDimPix];
cross_colour = [255 0 0]; %red

if flag_2diodes || flag_1diodes
    squarewidth=80; %wy/50*2; % screen is rougly 50cm and we want a 2cm-width square
    startpos=[wx-squarewidth 0];
    din2_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
    startpos=[wx-squarewidth wy-squarewidth];
    din1_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
end
% add images to buffer
% 1st set (faces)
for nF=1:9
    filename = [stim_path filesep 'FaceID' num2str(nF) '_L_1.png'];
    thispic=imread(filename);
    thispic=rgb2gray(thispic);
    imgetex=Screen('MakeTexture', w, thispic);
    pertask_imge_indexes{1}(nF,1)=imgetex;
    
    filename = [stim_path filesep 'FaceID' num2str(nF) '_R_1.png'];
    thispic=imread(filename);
    thispic=rgb2gray(thispic);
    imgetex=Screen('MakeTexture', w, thispic);
    pertask_imge_indexes{1}(nF,2)=imgetex;
end
% 2nd set (faces)
for nF=1:9
    filename = [stim_path filesep 'FaceID' num2str(nF) '_L_2.png'];
    thispic=imread(filename);
    thispic=rgb2gray(thispic);
    imgetex=Screen('MakeTexture', w, thispic);
    pertask_imge_indexes{2}(nF,1)=imgetex;
    
    filename = [stim_path filesep 'FaceID' num2str(nF) '_R_2.png'];
    thispic=imread(filename);
    thispic=rgb2gray(thispic);
    imgetex=Screen('MakeTexture', w, thispic);
    pertask_imge_indexes{2}(nF,2)=imgetex;
end
% 3rd set (squares)
filename = [stim_path filesep 'Square_L.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
pertask_imge_indexes{3}(1)=imgetex;

filename = [stim_path filesep 'Square_R.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
pertask_imge_indexes{3}(2)=imgetex;

% 4th set (outward squares)
filename = [stim_path filesep 'OutSquare_L.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
pertask_imge_indexes{4}(1)=imgetex;

filename = [stim_path filesep 'OutSquare_R.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
pertask_imge_indexes{4}(2)=imgetex;

% Mask
filename = [stim_path filesep 'Mask.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
mask_index=imgetex;
% Rect
centerx = (wx/2);
centery = wy/2;
LeftRect=[centerx-0.2*wx, centery-0.2*wx, centerx, centery+0.2*wx];
RightRect=[centerx, centery-0.2*wx, centerx+0.2*wx, centery+0.2*wx];

dur_face_presentation=0.75;
dur_face_presentation_jitter=0.5;
TargetID=3;
letterSize=100;

KbIndexes=GetKeyboardIndices;
KbIndex=max(KbIndexes);
% % % % WaitSecs(1); [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1); while ~keyIsDown; [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1); end; find(keyCode)
if length(KbIndexes)==1
    if ismac
        myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
        AbortKey='Escape';
    elseif IsWindows
        myKeyMap=[49 50 51 52]; % for 1, 2, 3, 4
        AbortKey='esc';
        AbortKeyIndex=27;
    else
        %     myKeyMap=[100 101 102 107]; % for 1, 2, 3, 4
        myKeyMap=[84 85 86 87]; % for 1, 2, 3, 4
        %     myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
        fprintf('!!!!! WARNING: only main keyboard recognized!!!!\nIn such case, unplug/plug USB cable and THEN quit and relaunch matlab\n')
    end
else
    %     myKeyMap=[100 101 102 107];
    if ismac
        myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
        AbortKey='Escape';
    elseif IsWindows
        myKeyMap=[49 50 51 52]; % for 1, 2, 3, 4
        AbortKey='esc';
          AbortKeyIndex=27;
  else
        %     myKeyMap=[100 101 102 107]; % for 1, 2, 3, 4
        myKeyMap=[84 85 86 87]; % for 1, 2, 3, 4
        %     myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
        fprintf('!!!!! WARNING: only main keyboard recognized!!!!\nIn such case, unplug/plug USB cable and THEN quit and relaunch matlab\n')
    end
%     myKeyMap=[84 85 86 87]; % for 1, 2, 3, 4
end

%% EEG
WaitSecs(0.2);
if flag_EEG && flag_1diodes && flag_escp==0
    dinok=0;
    while dinok==0
        DrawFormattedText(w, 'checking sync...', 'center', 'center', [255 0 0]);
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        tempst=Screen('Flip',w);
        while GetSecs<tempst+0.2
            if dinok==0
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
                if keyIsDown==1
                    dinok=1;
                end
            end
        end
        DrawFormattedText(w, 'checking sync...', 'center', 'center', [255 0 0]);
        tempst=Screen('Flip',w);
        while GetSecs<tempst+0.2
            if dinok==0
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
                if keyIsDown==1
                    dinok=1;
                end
            end
        end
    end
end
       DrawFormattedText(w, 'done!', 'center', 'center', [255 0 0]);
        tempst=Screen('Flip',w);
        
%% Tobii
if flag_EyeLink && flag_escp==0
    if (Eyelink('initialize') ~= 0) %% to debug Eyelink('initializedummy')
        return;
    end
    
    %%%%%%%% EYELINK SETUP AND CALIBRATION
    window=w;
    el=EyelinkInitDefaults(window);%,par);
    el.backgroundcolour=255;
    
    if ~EyelinkInit(0, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    % open file to record data to
    % Eyelink('Openfile', par.edfFile);
    saveEyeLink_eyet=sprintf('WIMs%s.edf',subjectID);
    Eyelink('OpenFile',saveEyeLink_eyet);
    % calibrate:
    EyelinkDoTrackerSetup(el); % Instructions come up on the screen. It seems Esc has to be pressed on the stim computer to exit at the end
    
    disp('FINISHED CALIBRATING')
    
    Eyelink('StartRecording');
    WaitSecs(0.1);
    % mark zero-plot time in data file
    Eyelink('Message', 'SYNCTIME');
    % figure out which eye is being tracked:
    eye_used = Eyelink('EyeAvailable');
    EyeLink_StartTime=GetSecs;
    SubjectInfo.EyeLink_StartTime=EyeLink_StartTime;
    
    nCalib=1;
    Eyelink('Message', sprintf('C_%g',nCalib));
    
    fprintf('>>>>>> EyeLink is up and running\n');
    Screen('FillRect',  w, 0);
    
else
    fprintf('>>>>>> EyeLink won''t be used\n');
end
Screen('Flip',w);
WaitSecs(1);
Screen('Flip',w);

%% BASELINE
if flag_skipbaseline==0 && flag_escp==0
    Screen('TextSize',w, InstrFont);
    DrawFormattedText(w, 'We will now record how your brain responds\n\nto flickering stimuli\n\nPress any key when ready', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    KbReleaseWait(-1);
    
    display_BaselineIM_v3;
end
Screen('Flip',w);
WaitSecs(3);

%% TRAINING
if flag_escp==1
    Screen('TextSize',w, InstrFont);
    DrawFormattedText(w, 'Aborting session...', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
else
    ListenChar(2);
    trai_res=[];
    if flag_skiptraining==0
        if flag_PPort
            SendTrigger(trig_start);
        end
        
        % Prepare double flickering for this block
        flicker_freq1=flicker_freqL;
        flicker_freq2=flicker_freqR;
        
        flicker1=1/flicker_freq1:1/flicker_freq1:5*60; % prepare for 30 minutes of flickers
        flickerID1=ones(1,length(flicker1));
        flicker2=1/flicker_freq2:1/flicker_freq2:5*60;
        flickerID2=2*ones(1,length(flicker2));
        
        temp=[flicker1 flicker2];
        temp2=[flickerID1 flickerID2];
        allflick=temp;
        allID=temp2;
        [flickertimes,idxordered]=sort(allflick);
        for n=2:length(flickertimes)
            if flickertimes(n)-flickertimes(n-1)<0.001
                flicker1(ismember(flicker1,flickertimes(n)))=flickertimes(n-1);
                flicker2(ismember(flicker2,flickertimes(n)))=flickertimes(n-1);
                flickertimes(n)=flickertimes(n-1);
            end
        end
        flickertimes=unique(flickertimes);
        flickertimes=[0 flickertimes];
        diffflickertimes=[diff(flickertimes)];
        textstream=[1 1]; %start
        for n=2:length(flickertimes)
            textstream(n,:)=textstream(n-1,:);
            if sum(ismember(flicker1,flickertimes(n)))~=0
                textstream(n,1)=setdiff(1:2,textstream(n-1,1));
            end
            if sum(ismember(flicker2,flickertimes(n)))~=0
                textstream(n,2)=setdiff(1:2,textstream(n-1,2));
            end
        end
        
        Screen('TextSize',w, InstrFont);
        DrawFormattedText(w, 'You will now train on the attention task\n\nFirst with FACES\n\nRemember to respond to all stimuli\n\nEXCEPT the smiling face\n\nPress any key when ready', 'center', 'center', [255 255 255]);
        Screen('Flip',w);
        KbWait(-1);
        KbReleaseWait(-1);
        Screen('Flip',w);
        
        this_blockcond=1;
        nblock=1;
        thiset=2;
        display_SART2flickers_training_v3;
        
        perfGO=100*(nanmean(trai_res(trai_res(:,1)==1,12)));
        perfNOGO=100*(nanmean(trai_res(trai_res(:,1)==1,11)));
        meanRT=(nanmean(trai_res(trai_res(:,1)==1,10)-(trai_res(trai_res(:,1)==1,8))));
                Screen('TextSize',w, InstrFont);
DrawFormattedText(w,sprintf('You performance was\n%2.1f %% (press)\n%2.1f %% (no-press)\n%1.2fs (response-time)\n\nPress any key to continue',perfGO,perfNOGO,meanRT), 'center', 'center', [255 255 255]);%
        Screen('Flip',w);
        KbWait(-1);
        KbReleaseWait(-1);
        Screen('Flip',w);
        
        KbReleaseWait
        Screen('TextSize',w, InstrFont);
        DrawFormattedText(w, 'You will now train on the attention task\n\nwith DIGITS\n\nRemember to respond to all digits\n\nEXCEPT the digit 3\n\nPress any key when ready', 'center', 'center', [255 255 255]);
        Screen('Flip',w);
        KbWait(-1);
        KbReleaseWait(-1);
        Screen('Flip',w);
        this_blockcond=2;
        nblock=2;
        thiset=3;
        display_SART2flickers_training_v3;
        
        perfGO=100*(nanmean(trai_res(trai_res(:,1)==2,12)));
        perfNOGO=100*(nanmean(trai_res(trai_res(:,1)==2,11)));
        meanRT=(nanmean(trai_res(trai_res(:,1)==2,10)-(trai_res(trai_res(:,1)==2,8))));
                Screen('TextSize',w, InstrFont);
DrawFormattedText(w,sprintf('You performance was\n%2.1f %%(press)\n%2.1f %%(no-press)\n%1.2fs (response-time)\n\nPress any key to continue',perfGO,perfNOGO,meanRT), 'center', 'center', [255 255 255]);%
        Screen('Flip',w);
        KbWait(-1);
        KbReleaseWait(-1);
        Screen('Flip',w);
        
        if flag_PPort
            SendTrigger(trig_end);
        end
    end
    Screen('Flip',w);
end
%% Randomize blocks and sequences
block_type      = [1 1 1 2 2 2]; %[1 1 1 1 2 2 2 2]; MODIFIED FROM 8 TO 6 BLOCKS
set_images      = [1 1 1 3 3 3];
expe_sampling   = 1;
max_probe_jitter= 30;
min_probe_jitter= 40;
block_perm      = randperm(length(block_type));
while ~isempty(find(diff(diff(block_type(block_perm)))==0)) % avoid more than 2 blocks of the same type in a row
    block_perm      = randperm(length(block_type));
end
if flag_debug==0
    number_probes   = 10;
    num_missprobes  = 2;
else
    number_probes   = 2;
    num_missprobes  = 2;
end
if flag_escp==1
    Screen('TextSize',w, InstrFont);
    DrawFormattedText(w, 'Aborting session...', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
else
    Screen('TextSize',w, InstrFont);
    DrawFormattedText(w, 'Ready to START?\n\nPress any key when ready', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    KbReleaseWait(-1);
    Screen('Flip',w);

% prepare double flickering for this block
flicker_freq1=flicker_freqL;
flicker_freq2=flicker_freqR;

flicker1=1/flicker_freq1:1/flicker_freq1:30*60; % prepare for 30 minutes of flickers
flickerID1=ones(1,length(flicker1));
flicker2=1/flicker_freq2:1/flicker_freq2:30*60;
flickerID2=2*ones(1,length(flicker2));

temp=[flicker1 flicker2];
temp2=[flickerID1 flickerID2];
allflick=temp;
allID=temp2;
[flickertimes,idxordered]=sort(allflick);
for n=2:length(flickertimes)
    if flickertimes(n)-flickertimes(n-1)<0.001
        flicker1(ismember(flicker1,flickertimes(n)))=flickertimes(n-1);
        flicker2(ismember(flicker2,flickertimes(n)))=flickertimes(n-1);
        flickertimes(n)=flickertimes(n-1);
    end
end
flickertimes=unique(flickertimes);
flickertimes=[0 flickertimes];
diffflickertimes=[diff(flickertimes)];
textstream=[1 1]; %start
for n=2:length(flickertimes)
    textstream(n,:)=textstream(n-1,:);
    if sum(ismember(flicker1,flickertimes(n)))~=0
        textstream(n,1)=setdiff(1:2,textstream(n-1,1));
    end
    if sum(ismember(flicker2,flickertimes(n)))~=0
        textstream(n,2)=setdiff(1:2,textstream(n-1,2));
    end
end
end


%% Init Results variables
test_res=[];
probe_res=[];
nblock=0;
maxblock=length(block_perm);

%% HERE STARTS THE LOOP ACROSS BLOCKS. RERUN THIS SECTION IF CRASHES DURING TEST
while nblock < maxblock && flag_escp==0
    nblock=nblock+1;
    
    % start block
    Screen('Flip',w);
    this_block      = block_perm(nblock);
    this_blockcond  = block_type(block_perm(nblock));
    thiset          = set_images(block_perm(nblock));
    Screen('TextSize',w, InstrFont);
    DrawFormattedText(w, sprintf('Part %g over %g\n\nPress any key when ready',nblock,length(block_perm)), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    KbReleaseWait(-1);
    Screen('Flip',w);
    all_tstartblock(nblock)=GetSecs;
    if flag_PPort
        %         io64(useioObj,pcode,trig_startBlock);
        SendTrigger(trig_startBlock);
    end
    if flag_1diodes % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
    if expe_sampling==1
        probe_intervals = rand(1,number_probes+num_missprobes+2)*max_probe_jitter+min_probe_jitter;
        %         missingprobes=[ones(1,num_missprobes) zeros(1,number_probes+2)];
        %         missingprobes=missingprobes(randperm(length(missingprobes)));
        %         while flag_debug==0 && (missingprobes(1)==1 || missingprobes(end)==1 || diff(find(missingprobes))==1)
        %             missingprobes=missingprobes(randperm(length(missingprobes)));
        %         end
        probe_times = cumsum(probe_intervals);
        %         probe_times(missingprobes==1)=[];
        %         probe_intervals=diff([0 probe_times]); %(missingprobes==1)=[];
        this_probe=1; this_probetime=all_tstartblock(nblock)+probe_intervals(this_probe);
        this_probe_count=1;
    end
    
    %%%%%% call function for SART
    display_SART2flickers_v3;
    ListenChar(0);
    
    %     %%%%% Redo calibration every two blocks
    %     if ismember(nblock,2:2:length(block_perm)-1) && flag_EyeLink
    %         nCalib=nCalib+1;
    %         WaitSecs(1);
    %         DrawFormattedText(w, 'Press any key\n\nTo start the recalibration', 'center', 'center', [255 255 255]);
    %         Screen('Flip',w);
    %         KbWait(-1);
    %         KbReleaseWait(-1);
    %         Screen('Flip',w);
    %
    %         Eyelink('trackersetup');
    %         % do a final check of calibration using driftcorrection
    %         Eyelink('dodriftcorrect');
    %
    %         Eyelink('Message', sprintf('calib_%g',nCalib));
    %     end
end
all_tendexpe=GetSecs;
ListenChar(0);
Screen('Flip',w);
Screen('TextSize',w, InstrFont);
if  flag_escp==0
DrawFormattedText(w, 'Congratulations!\n\nYou''re done!\n\nThank you for your participation', 'center', 'center', [255 255 255]);
Screen('Flip',w);
WaitSecs(5);
end

%%
% Save results and close Tobii/EEG
all_GrandEnd=GetSecs;

save_path=[pwd filesep '../ExpeResults/'];
if flag_escp==0
    save(sprintf('%s/wanderIM_behavres_s%s_%s',save_path,subjectID,expstart),'trai_res','test_res','probe_res','SubjectInfo','all_*');
else
    save(sprintf('%s/wanderIM_behavres_s%s_%s_ABORTED',save_path,subjectID,expstart),'trai_res','test_res','probe_res','SubjectInfo','all_*');
end
if flag_EyeLink==1
    Eyelink('stoprecording');
    Screen(w,'close');
    Eyelink('closefile');
    if flag_escp==0
        newsaveEyeLink_eyet=sprintf('%s/wanderIM_eyelink_s%s_%s.edf',save_path,subjectID,expstart);
    else
        newsaveEyeLink_eyet=sprintf('%s/wanderIM_eyelink_s%s_%s_ABORTED.edf',save_path,subjectID,expstart);
    end
    Eyelink('ReceiveFile',saveEyeLink_eyet,newsaveEyeLink_eyet);
    
    Eyelink('shutdown');
else
    Screen('CloseAll')
end
ShowCursor;

