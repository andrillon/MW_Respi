%% Init
clear all
close all
flag_smallw=2;
root_path='/Users/Thomas/Work/PostDoc/Monash/WanderIM/ExpeFolder';
stim_path=[root_path filesep 'ExpeStim'];

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
    InstrFont=24;
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

%%
flicker_freq1=7.14*2;
flicker_freq2=5.88*2;

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

%% Display flickering faces
% prepare drawing
Screen('DrawTexture', w, imge_indexes(1),[],RightRect,[],[]);
Screen('DrawTexture', w, imge_indexes(2),[],LeftRect,[],[]);
Screen('Flip',w);
start=GetSecs;
previousflip=start; count=1;

while GetSecs<start+30
    if textstream(count+1,1)==1
        Screen('DrawTexture', w, imge_indexes(1),[],RightRect,[],[]);
    else
        Screen('DrawTexture', w, mask_indexes,[],RightRect,[],[]);
    end
    if textstream(count+1,2)==1
        Screen('DrawTexture', w, imge_indexes(2),[],LeftRect,[],[]);
    else
        Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
    end
    while GetSecs<previousflip+diffflickertimes(count)-ifi/2
    end
    FlipSec=Screen('Flip',w);
    previousflip=FlipSec;
    count=count+1;
    
end
Screen('Flip',w);
WaitSecs(5);

%% Display flickering squares
% prepare drawing
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
    end
    if textstream(count+1,2)==1
        Screen('DrawTexture', w, imge_indexes(4),[],LeftRect,[],[]);
    else
        Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
    end
    while GetSecs<previousflip+diffflickertimes(count)-ifi/2
    end
    FlipSec=Screen('Flip',w);
    previousflip=FlipSec;
    count=count+1;
    
end
Screen('Flip',w);
WaitSecs(5);

%% Display flickering squares
% prepare drawing
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
    end
    if textstream(count+1,2)==1
        Screen('DrawTexture', w, imge_indexes(3),[],LeftRect,[],[]);
    else
        Screen('DrawTexture', w, mask_indexes,[],LeftRect,[],[]);
    end
    while GetSecs<previousflip+diffflickertimes(count)-ifi/2
    end
    FlipSec=Screen('Flip',w);
    previousflip=FlipSec;
    count=count+1;
    
end
Screen('Flip',w);
