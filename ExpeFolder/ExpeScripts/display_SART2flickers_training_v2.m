%% Randomise order of trials
all_seq=randperm(9);
for nseq=1:50
    rand_seq=randperm(9);
    while rand_seq(1)==3 || rand_seq(end)==3 || rand_seq(1)==all_seq(end)% not target on edge
        rand_seq=randperm(9);
    end
    all_seq=[all_seq rand_seq];
end

imge_indexes=pertask_imge_indexes{thiset};

%% start block
if flag_PPort
    io64(useioObj,pcode,trig_startBlock);
end
if flag_Tobii
    talk2tobii('EVENT','', 0.001, 'Tbloc', nblock);
end
         if flag_EEG % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
        Screen('Flip',w);
        WaitSecs(0.3);
        Screen('Flip',w);
    end
%% play SART
if this_blockcond==1 % faces
    %%% Init
    starttra=GetSecs;
    ntrial=1;
    block_starttime(nblock)=GetSecs;
    % Start with 3s of fixation cross
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    while GetSecs<starttra+1
    end
    if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'Tbloc', nblock, 'trial',ntrial);
    end
    start_blocktraining=GetSecs;
    
    this_seq_trial=all_seq(ntrial);
    this_image_L=imge_indexes(this_seq_trial,1);
    this_image_R=imge_indexes(this_seq_trial,2);
    
    Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
    Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
    Screen('Flip',w);
    stimonset=GetSecs;
    previousflip=stimonset;
    count=1;
    thisresp=NaN;
    
    while GetSecs<=start_blocktraining+30
        
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        resprec=0;
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
            [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if keyIsDown && resprec==0
                thisresp=find(keyCode); thisresp=thisresp(1);
                thisresptime=keySecs;
                resprec=1;
            end
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
        if GetSecs>stimonset+dur_face_presentation % update face identity
            thisresptime=NaN;
            this_nogo=NaN;
            this_go=NaN;
            if this_seq_trial==TargetID && isnan(thisresp)
                this_nogo=1;
            elseif  this_seq_trial==TargetID && ~isnan(thisresp) && strcmp(KbName(thisresp(1)),'space')
                this_nogo=0;
            end
            if this_seq_trial~=TargetID && isnan(thisresp)
                this_go=0;
            elseif  this_seq_trial~=TargetID && ~isnan(thisresp) && strcmp(KbName(thisresp(1)),'space')
                this_go=1;
            end
            trai_res=[trai_res; [nblock this_blockcond thiset ntrial this_seq_trial TargetID thisresp stimonset thisresptime  this_nogo this_go]];
            thisresp=NaN;
            
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            this_image_L=imge_indexes(this_seq_trial,1);
            this_image_R=imge_indexes(this_seq_trial,2);
            stimonset=GetSecs;
            if flag_Tobii
                talk2tobii('EVENT','', 0.001, 'Tbloc', nblock, 'trial',ntrial);
            end
        end
        
        
    end
    
    %%
elseif this_blockcond==2
    %%% Init
    starttra=GetSecs;
    ntrial=1;
    block_starttime(nblock)=GetSecs;
    % Start with 3s of fixation cross
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    while GetSecs<starttra+1
    end
    if flag_Tobii
        talk2tobii('EVENT','', 0.001, 'Tbloc', nblock, 'trial',ntrial);
    end
    start_blocktraining=GetSecs;
    this_seq_trial=all_seq(ntrial);
    this_image_L=imge_indexes(1);
    this_image_R=imge_indexes(2);
    
    Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
    Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
    Screen('TextSize',w, letterSize);
    DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
    Screen('Flip',w);
    stimonset=GetSecs;
    previousflip=stimonset; count=1;
    thisresp=NaN;
    
    while GetSecs<=start_blocktraining+30
        
        
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
            if flag_EEG
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        resprec=0;
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
            [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if keyIsDown && resprec==0
                thisresp=find(keyCode); thisresp=thisresp(1);
                thisresptime=keySecs;
                resprec=1;
            end
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
        if GetSecs>stimonset+dur_face_presentation % update face identity
            this_nogo=NaN;
            this_go=NaN;
            thisresptime=NaN;
            if this_seq_trial==TargetID && isnan(thisresp)
                this_nogo=1;
            elseif  this_seq_trial==TargetID && ~isnan(thisresp) && strcmp(KbName(thisresp(1)),'space')
                this_nogo=0;
            end
            if this_seq_trial~=TargetID && isnan(thisresp)
                this_go=0;
            elseif  this_seq_trial~=TargetID && ~isnan(thisresp) && strcmp(KbName(thisresp(1)),'space')
                this_go=1;
            end
            trai_res=[trai_res; [nblock this_blockcond thiset ntrial this_seq_trial TargetID thisresp stimonset thisresptime  this_nogo this_go]];
            
            thisresp=NaN;
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            stimonset=GetSecs;
            if flag_Tobii
                talk2tobii('EVENT','', 0.001, 'Tbloc', nblock, 'trial',ntrial);
            end
        end
        
    end
end


%% end block
Screen('Flip',w);
WaitSecs(3);
if flag_PPort
    io64(useioObj,pcode,trig_endBlock);
end
if flag_Tobii
    talk2tobii('EVENT','', 0.001, 'Tbloc', 0);
end
