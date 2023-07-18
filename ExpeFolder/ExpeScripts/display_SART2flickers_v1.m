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

%% play SART
if this_blockcond==1 % faces
    %%% Init
    starttra=GetSecs;
    ntrial=1;
    block_starttime(nblock)=GetSecs;
    % Start with 3s of fixation cross
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    while GetSecs<starttra+3
    end
    
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
    
    while this_probe_count<=number_probes
        
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
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
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
            if GetSecs>this_probetime
                probe_SART_v1;
                this_probe_count=this_probe_count+1;
                this_probe=this_probe+1;
                this_probetime=GetSecs+probe_intervals(this_probe_count);
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
            test_res=[test_res; [nblock this_blockcond ntrial this_seq_trial TargetID thisresp stimonset thisresptime  this_nogo this_go]];
            thisresp=NaN;
            
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            this_image_L=imge_indexes(this_seq_trial,1);
            this_image_R=imge_indexes(this_seq_trial,2);
            stimonset=GetSecs;
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
    while GetSecs<starttra+3
    end
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
    
    while this_probe_count<=number_probes
        
        
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
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
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
            if GetSecs>this_probetime
                probe_SART_v1;
                this_probe_count=this_probe_count+1;
                this_probe=this_probe+1;
                this_probetime=GetSecs+probe_intervals(this_probe_count);
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
            test_res=[test_res; [nblock this_blockcond ntrial this_seq_trial TargetID thisresp stimonset thisresptime  this_nogo this_go]];
            
            thisresp=NaN;
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            stimonset=GetSecs;
        end
        
    end
end


%% end block
Screen('Flip',w);
WaitSecs(3);
if flag_EEG
    io64(useioObj,pcode,trig_endBlock);
end

