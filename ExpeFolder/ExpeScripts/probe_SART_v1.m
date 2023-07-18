%% Supervised questions
[wx, wy] = Screen('WindowSize', w);

Screen('TextSize',w, InstrFont);
Screen('FillRect', w, [0, 0, 0]);
if flag_EEG % at the begining of each probe, turn the din1 to white
    Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
end
if flag_Tobii
    talk2tobii('EVENT','newP', 0.001);
end
startProbe=Screen('Flip',w);
if flag_EEG
    io64(useioObj,pcode,trig_probestart);
end

InitializePsychSound;
freq = 44100;
% Play a bip
pahandle = PsychPortAudio('Open', [], [], 0, freq, 1);
[beep,samplingRate] = MakeBeep(440,0.5,freq);
PsychPortAudio('FillBuffer', pahandle, beep);
PsychPortAudio('Start', pahandle, 1, 0, 1);
WaitSecs(0.5);
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);
KbReleaseWait(-1);
WaitSecs(0.5);


for nQ=1:length(supervised_questions)
    Screen('FillRect', w, [0, 0, 0]);
    if flag_EEG
    Screen('FillPoly', w ,[1 1 1]*255, din2_pos);
    end
        DrawFormattedText(w, supervised_questions_headers{nQ}, 'center', 0.1*wy, [255, 0, 0]);
    
    DrawFormattedText(w, supervised_questions{nQ}, 'center', 'center', [255, 255, 255]);
    qflip=Screen('Flip',w);
    if flag_Tobii
        talk2tobii('EVENT','newP', 0.001, 'newQ', nQ);
    end
    % Wait for response
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    while keyIsDown==0 || isempty(find(ismember(find(keyCode),myKeyMap)))
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    end
    KbReleaseWait(-1);
    keyPressed=find(keyCode);
    keyPressed=keyPressed(1);
    probe_responses(nQ,1)=keyPressed;
    probe_responses(nQ,2)=secs;
    probe_responses(nQ,3)=qflip;
    %%%% YOU SHOULD ADD MISSING PART HERE
        thiskeyCode=find(myKeyMap==keyPressed);
        if ~isempty(thiskeyCode)
            probe_responses(nQ,4)=thiskeyCode;
        else
            probe_responses(nQ,4)=NaN;
        end

    WaitSecs(0.5);
end
probe_res=[probe_res ; [this_probe startProbe nblock this_blockcond ntrial probe_responses(:,1)' probe_responses(:,2)' probe_responses(:,3)' probe_responses(:,4)']];

if flag_EEG
    io64(useioObj,pcode,trig_probeend);
end