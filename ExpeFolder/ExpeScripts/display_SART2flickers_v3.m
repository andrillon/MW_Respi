%% Randomise order of trials
all_seq=randperm(9);
while all_seq(1)==3
    all_seq=randperm(9);
end
for nseq=1:200
    rand_seq=randperm(9);
    while rand_seq(1)==3 || rand_seq(end)==3 || rand_seq(1)==all_seq(end)% not target on edge
        rand_seq=randperm(9);
    end
    all_seq=[all_seq rand_seq];
end
%DrawFormattedText(w, 'Get ready to resume the task', 'center', 'center', [255, 255, 255]);
DrawFormattedText(w, 'Préparez-vous à reprendre la tâche', 'center', 'center', [255, 255, 255]);
Screen('Flip',w);
WaitSecs(2);

imge_indexes=pertask_imge_indexes{thiset};
if flag_PPort
    SendTrigger(trig_startBlock);
end
if flag_EyeLink
    Eyelink('Message', sprintf('B%g',nblock));
end
%% play SART
resprec=0;
lastpress=0;
if this_blockcond==1 % faces
    %%% Init
    starttra=GetSecs;
    ntrial=1;
    block_starttime(nblock)=GetSecs;
    this_seq_trial=all_seq(ntrial);
    this_image_L=imge_indexes(this_seq_trial,1);
    this_image_R=imge_indexes(this_seq_trial,2);
    dur_face_presentation_rand=dur_face_presentation + dur_face_presentation_jitter*rand;
    
    % Start with 3s of fixation cross
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    while GetSecs<starttra+2
    end
    if flag_PPort
        SendTrigger(trig_startTrial+this_seq_trial);
    end
    if flag_EyeLink
        Eyelink('Message', sprintf('B%g_T%g_S%g',nblock,ntrial,this_seq_trial));
    end
    if flag_1diodes % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
    end
    
    
    Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
    Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
    Screen('Flip',w);
    stimonset=GetSecs;
    previousflip=stimonset;
    count=1;
    thisresptime=NaN;
    thisresp=NaN;
    
    while this_probe_count<=number_probes && flag_escp==0
        
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            if flag_2diodes
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        if textstream(count+1,2)==1
            Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],LeftRect,[],[]);
            if flag_2diodes
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
            [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if keyIsDown && (resprec==0) && (lastpress==0)
                thisresp=find(keyCode); thisresp=thisresp(1);
                thisresptime=keySecs;
                resprec=1;
                lastpress=1;
                if flag_PPort
                    SendTrigger(trig_response);
                end
            end
            if (keyIsDown==0) && (resprec==0) % if no press but response already given then revert laspress
                lastpress=0;
            end
            if GetSecs>this_probetime
                probe_SART_v3;
                this_probe_count=this_probe_count+1;
                this_probe=this_probe+1;
                this_probetime=GetSecs+probe_intervals(this_probe_count);
            end
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
        if GetSecs>stimonset+dur_face_presentation_rand % update face identity
            resprec=0;
            this_nogo=NaN;
            this_go=NaN;
            if this_seq_trial==TargetID && isnan(thisresp)
                this_nogo=1;
            elseif  this_seq_trial==TargetID && ~isnan(thisresp) %&& strcmp(KbName(thisresp(1)),'space')
                this_nogo=0;
            end
            if this_seq_trial~=TargetID && isnan(thisresp)
                this_go=0;
            elseif  this_seq_trial~=TargetID && ~isnan(thisresp) %&& strcmp(KbName(thisresp(1)),'space')
                this_go=1;
            end
            if thisresp==AbortKeyIndex
                flag_escp=1;
            end
            fprintf('NOGO: %g | GO: %g | RT %g\n',this_nogo,this_go,thisresptime-stimonset)
            test_res=[test_res; [nblock this_blockcond thiset ntrial this_seq_trial TargetID thisresp stimonset dur_face_presentation_rand thisresptime  this_nogo this_go]];
            dur_face_presentation_rand=dur_face_presentation + dur_face_presentation_jitter*rand;
            
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            this_image_L=imge_indexes(this_seq_trial,1);
            this_image_R=imge_indexes(this_seq_trial,2);
            stimonset=GetSecs;
            thisresptime=NaN;
            thisresp=NaN;
            if flag_PPort
                SendTrigger(trig_startTrial+this_seq_trial);
            end
            if flag_EyeLink
                Eyelink('Message', sprintf('B%g_T%g_S%g',nblock,ntrial,this_seq_trial));
            end
            if flag_1diodes % at the begining of each probe, turn the din1 to white
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
                        [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if (keyIsDown==0)
                lastpress=0;
            end
        end
        
        
    end
    
    %%
elseif this_blockcond==2
    %%% Init
    starttra=GetSecs;
    ntrial=1;
    block_starttime(nblock)=GetSecs;
    
    dur_face_presentation_rand=dur_face_presentation + dur_face_presentation_jitter*rand;
    
    this_seq_trial=all_seq(ntrial);
    this_image_L=imge_indexes(1);
    this_image_R=imge_indexes(2);
    
    % Start with 3s of fixation cross
    Screen('DrawLines', w, [cross_xCoords; cross_yCoords], cross_lineWidthPix, cross_colour, [wx, wy]./2, 2);
    Screen('Flip',w);
    while GetSecs<starttra+2
    end
    if flag_PPort
        SendTrigger(trig_startTrial+this_seq_trial);
    end
    if flag_EyeLink
        Eyelink('Message', sprintf('B%g_T%g_S%g',nblock,ntrial,this_seq_trial));
    end
    if flag_1diodes % at the begining of each probe, turn the din1 to white
        Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
    end
    
    
    Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
    Screen('DrawTexture', w, this_image_L,[],LeftRect,[],[]);
    Screen('TextSize',w, letterSize);
    DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
    Screen('Flip',w);
    stimonset=GetSecs;
    previousflip=stimonset; count=1;
    thisresptime=NaN;
    thisresp=NaN;
    while this_probe_count<=number_probes && flag_escp==0
        
        
        if textstream(count+1,1)==1
            Screen('DrawTexture', w, this_image_R,[],RightRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
        else
            Screen('DrawTexture', w, mask_index,[],RightRect,[],[]);
            Screen('TextSize',w, letterSize);
            DrawFormattedText(w,num2str(this_seq_trial),'center','center',cross_colour,[],[],[],[],[]);
            if flag_2diodes
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
            if flag_2diodes
                Screen('FillPoly', w ,[1 1 1]*255, din1_pos);
            end
        end
        
        while GetSecs<previousflip+diffflickertimes(count)-ifi/2
            [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if keyIsDown && (resprec==0) && (lastpress==0)
                thisresp=find(keyCode); thisresp=thisresp(1);
                thisresptime=keySecs;
                resprec=1;
                lastpress=1;
                if flag_PPort
                    SendTrigger(trig_response);
                end
            end
            if (keyIsDown==0) && (resprec==0) % if no press but response already given then revert laspress
                lastpress=0;
            end
            if GetSecs>this_probetime
                probe_SART_v3;
                this_probe_count=this_probe_count+1;
                this_probe=this_probe+1;
                this_probetime=GetSecs+probe_intervals(this_probe_count);
            end
        end
        FlipSec=Screen('Flip',w);
        previousflip=FlipSec;
        count=count+1;
        
        if GetSecs>stimonset+dur_face_presentation_rand % update face identity
            resprec=0;
            this_nogo=NaN;
            this_go=NaN;
            if this_seq_trial==TargetID && isnan(thisresp)
                this_nogo=1;
            elseif  this_seq_trial==TargetID && ~isnan(thisresp) %&& strcmp(KbName(thisresp(1)),'space')
                this_nogo=0;
            end
            if this_seq_trial~=TargetID && isnan(thisresp)
                this_go=0;
            elseif  this_seq_trial~=TargetID && ~isnan(thisresp) %&& strcmp(KbName(thisresp(1)),'space')
                this_go=1;
            end
            if thisresp==AbortKeyIndex
                flag_escp=1;
            end
            fprintf('NOGO: %g | GO: %g | RT %g\n',this_nogo,this_go,thisresptime-stimonset)
            test_res=[test_res; [nblock this_blockcond thiset ntrial this_seq_trial TargetID thisresp stimonset dur_face_presentation_rand thisresptime  this_nogo this_go]];
            dur_face_presentation_rand=dur_face_presentation + dur_face_presentation_jitter*rand;
            
            ntrial=ntrial+1;
            this_seq_trial=all_seq(ntrial);
            stimonset=GetSecs;
            thisresptime=NaN;
            thisresp=NaN;
            if flag_PPort
                SendTrigger(trig_startTrial+this_seq_trial);
            end
            if flag_EyeLink
                Eyelink('Message', sprintf('B%g_T%g_S%g',nblock,ntrial,this_seq_trial));
            end
            if flag_1diodes % at the begining of each probe, turn the din1 to white
                Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
            end
                        [keyIsDown,keySecs, keyCode,deltaSecs] = KbCheck(-1);
            if (keyIsDown==0)
                lastpress=0;
            end
        end
        
    end
end


%% end block
Screen('Flip',w);
if flag_PPort
    SendTrigger(trig_endBlock);
end
if flag_EyeLink
    Eyelink('Message', sprintf('EB%g',nblock));
end
WaitSecs(3);
