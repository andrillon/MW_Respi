%% Init
clear all
close all
flag_smallw=2;
flag_EEG=0;
root_path='/Users/Thomas/Work/PostDoc/Monash/WanderIM/ExpeFolder';
stim_path=[root_path filesep 'ExpeStim'];
script_path=[root_path filesep 'ExpeScripts'];
% add PTB in the path
PTB_path='/home/thomas/Work_old/tools/Psychtoolbox-3-master/Psychtoolbox/';
addpath(genpath(PTB_path))

%% init PTB
screenNumbers = Screen('Screens');
numscreen = max(screenNumbers);
% set up screen display
if flag_smallw==1
    thisscreen=numscreen;
    Prop=12;
    w = Screen('OpenWindow', numscreen, 0, [0, 0, 1920*(Prop-1)/Prop, 1080*(Prop-1)/Prop]+[1920 1080 1920 1080]*1/Prop/2);
    InstrFont=36;
elseif flag_smallw==0
    thisscreen=0;
    w = Screen('OpenWindow', 0, 0, []);
    InstrFont=58;
    HideCursor;
else
    thisscreen=numscreen;
    Prop=12;
    w = Screen('OpenWindow', numscreen, 0, [0, 0, 800, 600]);
    InstrFont=36;
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


image_name={'Face_R.jpg','Face_L.jpg','Square_R.jpg','Square_L.jpg','Mask.jpg'};
for j=1:length(image_name)-1 % double the number of textures by adding a gray or black box for the second flicker
    filename = [stim_path filesep image_name{j}];
    thispic=imread(filename);
    thispic=rgb2gray(thispic);
    imgetex=Screen('MakeTexture', w, thispic);
    imge_indexes(j)=imgetex;
end
filename = [stim_path filesep image_name{length(image_name)}];
thispic=imread(filename);
imgetex=Screen('MakeTexture', w, thispic);
mask_indexes=imgetex;

centerx = (wx/2);
centery = wy/2;
RightRect=[centerx-0.2*wx, centery-0.2*wx, centerx, centery+0.2*wx];
LeftRect=[centerx, centery-0.2*wx, centerx+0.2*wx, centery+0.2*wx];

if flag_EEG
    squarewidth=80; %wy/50*2; % screen is rougly 50cm and we want a 2cm-width square
    startpos=[0 0];
    din1_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
    startpos=[0 wy-squarewidth];
    din2_pos=repmat(startpos,5,1)+[0 0 ; squarewidth 0; squarewidth squarewidth; 0 squarewidth; 0 0];
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



%%
flicker_freq1=15;
flicker_freq2=12;

flicker1=1/flicker_freq1:1/flicker_freq1:5*60; % prepare for 30 minutes of flickers
flickerID1=ones(1,length(flicker1));
flicker2=1/flicker_freq2:1/flicker_freq2:5*60;
flickerID2=2*ones(1,length(flicker2));

temp=[flicker1 flicker2];
temp2=[flickerID1 flickerID2];
%     [allflick, uniqueflick]=unique(temp);
allflick=temp;
allID=temp2; %(uniqueflick);
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

%%
DrawFormattedText(w, 'We''re ready to start!!\n\nPress any key to continue', 'center', 'center', [255 255 255]);
Screen('Flip',w);
KbWait(-1);
for n=1:6
    %% Display flickering faces
    % prepare drawing
    if flag_EEG
        io64(useioObj,pcode,trig_startBlock);
    end
    Screen('DrawTexture', w, imge_indexes(1),[],RightRect,[],[]);
    Screen('DrawTexture', w, imge_indexes(2),[],LeftRect,[],[]);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    flip(count,:)=[start start start];
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, imge_indexes(1),[],RightRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],RightRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, imge_indexes(2),[],LeftRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
            flip(count,1)=FlipSec;
            diffflip(count)=flip(count,1)-flip(count-1,1);
            diffflip2(count)=diffflickertimes(count-1);
%             if textstream(count-1,1)==2 && textstream(count,1)==1
%                 flip(count,2)=FlipSec;
%             end
%             if textstream(count-1,2)==2 && textstream(count,2)==1
%                 flip(count,3)=FlipSec;
%             end
    end
    Screen('Flip',w);
    WaitSecs(3);
    if flag_EEG
        io64(useioObj,pcode,trig_endBlock);
    end
    
    %% Display flickering faces with GAP
    % prepare drawing
    if flag_EEG
        io64(useioObj,pcode,trig_startBlock);
    end
    Screen('DrawTexture', w, imge_indexes(1),[],RightRect+[-0.03*wx 0 -0.03*wx 0],[],[]);
    Screen('DrawTexture', w, imge_indexes(2),[],LeftRect+[0.03*wx 0 0.03*wx 0],[],[]);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, imge_indexes(1),[],RightRect+[-0.03*wx 0 -0.03*wx 0],[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],RightRect+[-0.03*wx 0 -0.03*wx 0],[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, imge_indexes(2),[],LeftRect+[0.03*wx 0 0.03*wx 0],[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],LeftRect+[0.03*wx 0 0.03*wx 0],[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    WaitSecs(3);
    if flag_EEG
        io64(useioObj,pcode,trig_endBlock);
    end
    
    %% Display flickering squares
    % prepare drawing
    if flag_EEG
        io64(useioObj,pcode,trig_startBlock);
    end
    Screen('DrawTexture', w, imge_indexes(3),[],RightRect,[],[]);
    Screen('DrawTexture', w, imge_indexes(4),[],LeftRect,[],[]);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, imge_indexes(3),[],RightRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],RightRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, imge_indexes(4),[],LeftRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    WaitSecs(3);
    if flag_EEG
        io64(useioObj,pcode,trig_endBlock);
    end
    
    %% Display flickering squares
    % prepare drawing
    if flag_EEG
        io64(useioObj,pcode,trig_startBlock);
    end
    Screen('DrawTexture', w, imge_indexes(4),[],RightRect,[],[]);
    Screen('DrawTexture', w, imge_indexes(3),[],LeftRect,[],[]);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, imge_indexes(4),[],RightRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],RightRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, imge_indexes(3),[],LeftRect,[],[]);
        else
            Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    WaitSecs(3);
    if flag_EEG
        io64(useioObj,pcode,trig_endBlock);
    end
    
    DrawFormattedText(w, sprintf('%g block out of 6\n\nPress any key to continue',n), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
end

if flag_EEG
    io64(useioObj,pcode,trig_end);
end