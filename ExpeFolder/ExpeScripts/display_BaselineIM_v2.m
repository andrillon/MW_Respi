%% Prepare double flickering for this block
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

%% Instructions
DrawFormattedText(w, 'You will first have to look at flickering stimuli\n\nKeep your eyes at the center of the screen during stimulation\n\nAvoid blinking or moving\n\nPress any key to continue', 'center', 'center', [255 255 255]);
Screen('Flip',w);
KbWait(-1);

if flag_PPort
    io64(useioObj,pcode,trig_start);
end
for nloop=1:2
    %% Display flickering faces
    % prepare drawing
    DrawFormattedText(w, sprintf('The sequence %g (out of 8) will start shortly',(nloop-1)*4+1), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
    
    if flag_PPort
        io64(useioObj,pcode,trig_startBlock);
    end
    if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',1);
    end
         if flag_EEG % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
    thisFaceL=pertask_imge_indexes{2}(3+nloop,1);
    thisFaceR=pertask_imge_indexes{2}(3+nloop,2);
    Screen('DrawTexture', w, thisFaceR,[],RightRect,[],[]);
    Screen('DrawTexture', w, thisFaceL,[],LeftRect,[],[]);
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, thisFaceR,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, thisFaceL,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
    end
    Screen('Flip',w);
    if flag_PPort
        io64(useioObj,pcode,trig_endBlock);
    end
            if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',0);
     end
    DrawFormattedText(w, 'Sequence over\n\nPress the space bar to continue\n\n', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    Screen('Flip',w);
    
    %% Display flickering faces with GAP
    % prepare drawing
    DrawFormattedText(w, sprintf('The sequence %g (out of 8) will start shortly',(nloop-1)*4+2), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
    
    if flag_PPort
        io64(useioObj,pcode,trig_startBlock);
    end
        if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',2);
        end
         if flag_EEG % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
    RightRectGap=RightRect+[0 0.01*wy 0 0.01*wx];
    LeftRectGap=LeftRect+[0 -0.01*wy 0 -0.01*wy];
    Screen('DrawTexture', w, thisFaceR,[],RightRectGap,[],[]);
    Screen('DrawTexture', w, thisFaceL,[],LeftRectGap,[],[]);
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, thisFaceR,[],RightRectGap,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            Screen('DrawTexture', w, mask_index,[],RightRectGap,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, thisFaceL,[],LeftRectGap,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRectGap,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    if flag_PPort
        io64(useioObj,pcode,trig_endBlock);
    end
            if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',0);
     end
    DrawFormattedText(w, 'Sequence over\n\nPress the space bar to continue\n\n', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    Screen('Flip',w);
    
    %% Display flickering squares
    DrawFormattedText(w, sprintf('The sequence %g (out of 8) will start shortly',(nloop-1)*4+3), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
    if flag_PPort
        io64(useioObj,pcode,trig_startBlock);
    end
        if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',3);
        end
         if flag_EEG % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
    thisSquareL=pertask_imge_indexes{3}(1);
    thisSquareR=pertask_imge_indexes{3}(2);
    Screen('DrawTexture', w, thisSquareR,[],RightRect,[],[]);
    Screen('DrawTexture', w, thisSquareL,[],LeftRect,[],[]);
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, thisSquareR,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, thisSquareL,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    if flag_PPort
        io64(useioObj,pcode,trig_endBlock);
    end
            if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',0);
     end
    DrawFormattedText(w, 'Sequence over\n\nPress the space bar to continue\n\n', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    Screen('Flip',w);
    
    %% Display flickering squares
    DrawFormattedText(w, sprintf('The sequence %g (out of 8) will start shortly',(nloop-1)*4+4), 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    WaitSecs(1);
    Screen('Flip',w);
    % prepare drawing
    if flag_PPort
        io64(useioObj,pcode,trig_startBlock);
    end
        if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',4);
        end
         if flag_EEG % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
    thisSquareL=pertask_imge_indexes{4}(1);
    thisSquareR=pertask_imge_indexes{4}(2);
    Screen('DrawTexture', w, thisSquareL,[],LeftRect,[],[]);
    Screen('DrawTexture', w, thisSquareR,[],RightRect,[],[]);
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    start=GetSecs;
    previousflip=start; count=1;
    
    while GetSecs<start+30
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, thisSquareR,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, thisSquareL,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
    end
    Screen('Flip',w);
    if flag_PPort
        io64(useioObj,pcode,trig_endBlock);
    end
        if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'loop', nloop, 'sequ',0);
     end
    DrawFormattedText(w, 'Sequence over\n\nPress the space bar to continue\n\n', 'center', 'center', [255 255 255]);
    Screen('Flip',w);
    KbWait(-1);
    Screen('Flip',w);
    
end

if flag_PPort
    io64(useioObj,pcode,trig_end);
end