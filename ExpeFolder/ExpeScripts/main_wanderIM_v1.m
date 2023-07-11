%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Project WANDERLUST - INTERMODULATION
%%%%%
%%%%% 
%%%%%
%%%%% Written by Thomas Andrillon
%%%%% Email: thomas.andrillon@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% init matlab
% clear all variables and close all figures
clear all;
close all;
% set rand function on the clock
rand('seed',sum(100*clock));

% add the folder in the path
root_path='/Users/Thomas/Work/PostDoc/Monash/WanderIM/ExpeFolder/ExpeScripts';
cd(root_path)
addpath(pwd)
% add PTB in the path
PTB_path='/Applications/Psychtoolbox/';
addpath(genpath(PTB_path))
stim_path=[root_path filesep '..' filesep 'ExpeStim'];

% Select debug mode (1 or 0), EEG (1 or 0), Tobii (1 or 0)
flag_smallw     = 1;
answerdebug=input('Type 0 (no) or 1 (yes, debug)');
flag_debug      = answerdebug;
flag_EEG        = 0; % EEG segments to be added in the future
flag_Tobii      = 0; % Tobii segments to be added in the future
flag_skiptraining = 0;
flag_skipbaseline = 0;
flag_2diodes     = 0;


if flag_debug
    maxprobes_perblock     = 1; % number of iteration of a sequence in a block
else
    maxprobes_perblock     = 6; % number of iteration of a sequence in a block
end

supervised_questions = {...
    'Were you looking\nat the screen?\n\n - Yes : Press 1\n - No : Press 2  ',...
    'Where was your attention focus?\n\n - On-Task : Press 1\n\n - Off-Task : Press 2\n\n - Blank : Press 3\n\n - Don''t Remember : Press 4',...
    'Were you aware\nof your focus?\n\nFrom 1 : I was fully aware\n\nto  4 : I was not aware at all',...
    'Was your state of attention\nwillingly initiated or spontaneous?\n\nFrom 1 : Completely willful\n\nto 4 : Completely spontaneous',...
    ...
    'How engaged\nhave you been?\n\nFrom 1 : Not engaged\n\nto 4 : Very engaged',...
    'How well do you think\nyou have been performing?\n\nFrom 1 : not good\n\nto 4 : very good',...
    'Rate how tired / awake your have been:\n\nFrom 1 : Very tired\n\nto 4 : Fully awake'};

supervised_questions_headers={'Just before the interruption',...
    'Just before the interruption',...
    'Just before the interruption',...
    'Just before the interruption',...
    'Over the past few trials',...
    'Over the past few trials',...
    'Over the past few trials'};

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
end
SubjectInfo.sub=subject;
SubjectInfo.subID=subjectID;
SubjectInfo.sessID=sessionID;
SubjectInfo.Age=NaN;
SubjectInfo.Gender=NaN;
SubjectInfo.Date=expstart;
SubjectInfo.FlagW=flag_smallw;
SubjectInfo.FlagEEG=flag_EEG;
SubjectInfo.FlagTobii=flag_Tobii;
SubjectInfo.FlickerL=flicker_freqL;
SubjectInfo.FlickerR=flicker_freqR;


%% init PTB
screenNumbers = Screen('Screens');
numscreen = max(screenNumbers);
% set up screen display
if flag_smallw
    Prop=12;
    w = Screen('OpenWindow', numscreen, 0, [0, 0, 1000, 800]);
    InstrFont=36;
else
    w = Screen('OpenWindow', 0, 0, []);
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

if flag_EEG
    squarewidth=80; %wy/50*2; % screen is rougly 50cm and we want a 2cm-width square
    startpos=[0 0];
    din1_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
    startpos=[0 wy-squarewidth];
    din2_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
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
% Mask
filename = [stim_path filesep 'Mask.jpg'];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
mask_index=imgetex;
% Rect
centerx = (wx/2);
centery = wy/2;
RightRect=[centerx-0.2*wx, centery-0.2*wx, centerx, centery+0.2*wx];
LeftRect=[centerx, centery-0.2*wx, centerx+0.2*wx, centery+0.2*wx];

dur_face_presentation=1;
TargetID=3;
letterSize=64;

KbIndexes=GetKeyboardIndices;
KbIndex=max(KbIndexes);
if length(KbIndexes)==1
    if ismac
            myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
    else
%     myKeyMap=[100 101 102 107]; % for 1, 2, 3, 4
    myKeyMap=[84 85 86 87]; % for 1, 2, 3, 4
%     myKeyMap=[30 31 32 33]; % for 1, 2, 3, 4
    fprintf('!!!!! WARNING: only main keyboard recognized!!!!\nIn such case, unplug/plug USB cable and THEN quit and relaunch matlab\n')
    end
else
%     myKeyMap=[100 101 102 107]; 
    myKeyMap=[84 85 86 87]; % for 1, 2, 3, 4
end

%% EEG
if flag_EEG
    % Check that the MEX file io64 is in the path
    addpath([script_path filesep 'eeg'])
    if exist('io64', 'file') ~=3
        error('Place io64.mx64 within Matlabs search path')
    end
    DrawFormattedText(w, 'Check the EEG is on and recording\n\nPress any key to continue', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    WaitSecs(3);
    
    % Open the parallel port to the EEG device
    useioObj = io64; % initialise the mex command
    status = io64(useioObj); % Status of the driver
    pcode = hex2dec('0378'); % Portcode to send to EEG machine,
    
    % Code for triggers (must be between 0 and 255)
    %start/end recording
    trig_start=254;
    trig_end=255;
    trig_startBlock=100;
    trig_endBlock=200;
    trig_probestart=111;
    trig_probeend=222;
    
    % Send a first trigger
    io64(useioObj,pcode,trig_start);
    DrawFormattedText(w, 'Check the start trigger (254)\n\nPress any key to continue', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
else
    fprintf('>>>>>> EEG system won''t be used\n');
end
WaitSecs(1);
Screen('Flip',w);

%% Tobii
if flag_Tobii
    addpath(genpath([pwd filesep 'no-ppc']));
    DrawFormattedText(w, 'Prepare for the eye-tracker calibration', 'center', 'center', [255 255 255]);
    
    Screen('Flip',w);
    addpath([pwd filesep 'tobii'])
    addpath(genpath('/home/thomas/Work_old/tools/t2t'))
    
    Exp.Gral.SubjectName = subjectID;
    Exp.Gral.BlockName = '';
    
    screenwidthcm = 40;
    screendistcm = 45;
    Exp.Cfg.degPerPixel = atan2(screenwidthcm/(wx),screendistcm)/pi*180;
    Exp.addParams.hostName = '169.254.10.77';
    Exp.addParams.portName = '4455';
    nCalib=1;
    talk2tobii('EVENT','', 0.001, 'block', 0, 'trial',0,'calib',nCalib);
    [ErrorCode, quality{           nCalib}, errors{nCalib}] = TobiiInit_TA(Exp.addParams.hostName, Exp.addParams.portName, w, [wx, wy], ifi, Exp);
    talk2tobii('EVENT','', 0.001, 'block', 0, 'trial',0,'calib',0);
    
    talk2tobii ('RECORD');
    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data
    WaitSecs(0.5);
    fprintf('>>>>>> TOBII is up and running\n');
else
    fprintf('>>>>>> TOBII won''t be used\n');
end
Screen('Flip',w);
WaitSecs(1);
Screen('Flip',w);

%% BASELINE
ListenChar(2);
if flag_skiptraining==0
    %%%%% ADD BASELINE 
    %%%%% 8 blocks 30s each 2x(faces, faces apart, illusory square, no illusory
    %%%%% square)
end

%% TRAINING
ListenChar(2);
if flag_skiptraining==0
    %%%%% ADD SART TRAINING
end

%% Randomize blocks and sequences
block_type      = [1 1 1 2 2 2]; %[1 1 1 1 2 2 2 2]; MODIFIED FROM 8 TO 6 BLOCKS
set_images      = [1 1 1 3 3 3];
expe_sampling   = 1;
max_probe_jitter= 30;
min_probe_jitter= 40;
block_perm      = randperm(length(block_type));
if flag_debug==0
    number_probes   = 12;
    num_missprobes  = 2;
else
    number_probes   = 2;
    num_missprobes  = 1;
end
Screen('TextSize',w, InstrFont);
DrawFormattedText(w, 'Ready to START?\n\nPress any key when ready', 'center', 'center', [255 255 255]);
Screen('Flip',w);
KbWait(-1);
KbReleaseWait(-1);


%% Init Results variables
test_res=[];
probe_res=[];
nblock=0;
maxblock=length(block_perm);

%%
while nblock < maxblock
    nblock=nblock+1;
    % prepare double flickering for this block
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
    all_tstartblock(nblock)=GetSecs;
    if flag_EEG
        io64(useioObj,pcode,trig_startBlock);
    end
    if expe_sampling==1
        probe_intervals = rand(1,number_probes+num_missprobes)*max_probe_jitter+min_probe_jitter;
        missingprobes=[ones(1,num_missprobes) zeros(1,number_probes)];
        missingprobes=missingprobes(randperm(length(missingprobes)));
        while missingprobes(1)==1 || missingprobes(end)==1 || diff(find(missingprobes))==1
            missingprobes=missingprobes(randperm(length(missingprobes)));
        end
        probe_times = cumsum(probe_intervals);
        probe_times(missingprobes==1)=[];
        this_probe=1; this_probetime=all_tstartblock(nblock)+probe_intervals(this_probe);
        this_probe_count=0;
    end
    
    %%%%%% call function for SART
    display_SART2flickers_v1;
    ListenChar(0);
    
    %%%%% Redo calibration every two blocks
    if ismember(nblock,2:2:length(block_perm)-1) && flag_Tobii
        nCalib=nCalib+1;
        WaitSecs(1);
        talk2tobii('EVENT','', 0.001, 'block', nblock, 'trial',ntrial,'calib',nCalib);
        talk2tobii('STOP_TRACKING');
        
        [ErrorCode, quality{nCalib}, errors{nCalib}] = Tobii_recalibration(w, [wx, wy], ifi, Exp);
        
        talk2tobii('EVENT','', 0.001, 'block', nblock, 'trial',ntrial,'calib',0);
    end                
end
all_tendexpe=GetSecs;
ListenChar(0);
Screen('Flip',w);
Screen('TextSize',w, InstrFont);
DrawFormattedText(w, 'Congratulations!\n\nYou''re done!\n\nThank you for your participation', 'center', 'center', [255 255 255]);
Screen('Flip',w);
WaitSecs(5);
Screen('CloseAll')
ShowCursor;

%%
% Save results and close Tobii/EEG
save_path=[pwd filesep '../ExpeResults/'];
save(sprintf('%s/wanderIM_behavres_s%s_%s',save_path,subjectID,expstart),'all_*','SubjectInfo');

if flag_Tobii==1
    savetobbi_eyet=sprintf('%s/wanderIM_tobii_eyet_s%s_%s',save_path,subjectID,expstart);
    savetobbi_event=sprintf('%s/wanderIM_tobii_evnt_s%s_%s',save_path,subjectID,expstart);
    savetobbi_calib=sprintf('%s/wanderIM_tobii_calib_s%s_%s',save_path,subjectID,expstart);
    
    save(savetobbi_calib,'quality','errors')
    
    WaitSecs(1);
    
    talk2tobii('STOP_AUTO_SYNC');
    talk2tobii('STOP_TRACKING');
    
    talk2tobii('SAVE_DATA', savetobbi_eyet, savetobbi_event, 'TRUNK');
    
    talk2tobii ('CLEAR_DATA');
    talk2tobii('DISCONNECT');
    
end
