function [ErrorCode, quality, errors] = TobiiInit_TA( hostName, portName, win, res, ifi, Exp)
% This is a matlab function that initialises Tobii Connection
% Calibrate Eye Tracker and subscribe gaze data
%
% hostName is the IP address of the PC running the TET server
% win is the handle of the window that has been initialised with the
% psychtoolbox
% res is a vector with the width and the height of the win in pixels
%
% ErrorCode returns 1 if there is an error or 0 if no error
% has occured

%try max_wait times
%each time wait for tim_interv secs before try again
max_wait = 60;
tim_interv = 1;

%calibration points in X,Y coordinates
pos = [0.3 0.2;...
    0.5 0.2;
    0.7 0.2;
    0.3 0.5;
    0.5 0.5;
    0.7 0.5;
    0.3 0.8;
    0.5 0.8;
    0.7 0.8];
numpoints = length(pos);

%this call is important because it loads the 'GetSecs' mex file!
%without this call the talk2tobii mex file will crash
GetSecs();

%find indexes for correspond keys
SPACEkey=KbName('Space');

try
    %     ifi = Screen('GetFlipInterval',win,100);
    
    %% try to connect to the eyeTracker
    talk2tobii('CONNECT',hostName, portName);
    
    %check status of TETAPI
    cond_res = check_status(2, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end
    
    
    %% monitor/find eyes
    talk2tobii('START_TRACKING');
    %check status of TETAPI
    cond_res = check_status(7, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end
    
    flagNotBreak = 0;
    disp('Press SPACE to start calibration');
    while ~flagNotBreak
        eyeTrack = talk2tobii('GET_SAMPLE');
        DrawEyes(win, eyeTrack(9), eyeTrack(10), eyeTrack(11), eyeTrack(12), eyeTrack(8), eyeTrack(7));
        
        if(IsKey(SPACEkey))
            flagNotBreak = 1;
            if(flagNotBreak)
                break;
            end
        end
    end
    
    talk2tobii('STOP_TRACKING');
    
    %% START CALIBRATION
    
    do_calibration = 1;
    if do_calibration
                KbReleaseWait(-1);
                WaitSecs(0.2);
        DrawFormattedText(win, 'We will now calibrate the eye-tracker\n\nTargets will appear on the screen\n\nDirect your eyes to the target\n\nwhen it appears on screen\n\nthen press any key to display the next target\n\nKEEP your EYES on the SCREEN!\n\nPress any key to start', 'center', 'center', [255 255 255]);
        Screen('Flip',win);
        KbWait(-1);
        KbReleaseWait(-1);
        Screen('FillRect',  win, 0);
        Screen('Flip',win);
        
        %display stimulus in the four corners of the screen
        totTime = 4;        % swirl total display time during calibration
        calib_not_suc = 1;
        
        while calib_not_suc
            
            talk2tobii('START_CALIBRATION',pos, 1, 12) %,'./calibrFileTest.txt');
            
            % It is wrong to try to check the status here because the
            % eyetracker waits for an 'ADD_CALIBRATION_POINT' and 'DREW_POINT'.
            
            for m=1:numpoints
                position = pos(m,:);
                %            disp(position);
                when0 = GetSecs()+ifi;
                %                 swirl(win,totTime,ifi,when0,position,1);
                
                if m == 1
                    WaitSecs(2)
                end
                
                Screen('FillRect',  win, 0);
                Screen('DrawDots', win, [position(1)*res(1); position(2)*res(2)], 20, 255, [], 2)
                Screen('DrawDots', win, [position(1)*res(1); position(2)*res(2)], 5, 0, [], 2)
                Screen('Flip', win , [], 1);
                KbWait(-1);
                
                WaitSecs(0.2)
                talk2tobii('ADD_CALIBRATION_POINT');
                WaitSecs(0.5)
                %                 swirl(win,totTime, ifi, when0, position, 1);
                talk2tobii('DREW_POINT');
            end
            
            cond_res = check_status(11, 90, 1, 1);
            %         cond_res = check_status([4 5 6], 60, 1, [1 0 0])
            tmp = find(cond_res==0); %#ok
            if( ~isempty(tmp) )
                error('check_status has failed- CALIBRATION');
            end
            
            %check quality of calibration
            quality = talk2tobii('CALIBRATION_ANALYSIS');
            % TargetX, TargetY, RightEyeSampleX, RightEyeSampleY, RightEyeSampleValidity, LeftEyeSampleX, LeftEyeSampleY, LefyEyeSampleValidity
            
            
            % Round to 3 decimals
            quality(:,1:2) =  double(int16( quality(:,1:2) * 1000 )) / 1000;
            
            for pnt = 1 : numpoints
                
                data = quality(quality(:,1) == pos(pnt, 1) & quality(:,2) == pos(pnt, 2), :);
                meanEyeSampleX = nanmean( nanmean([ data(:,3) data(:,6) ], 2));
                meanEyeSampleY = nanmean( nanmean([ data(:,4) data(:,7) ], 2));
                dist_x = (meanEyeSampleX - pos(pnt, 1)) * res(1); % in pixels
                dist_y = (meanEyeSampleY - pos(pnt, 2)) * res(2); % in pixels
                
                errors(pnt) = sqrt( dist_x^2 + dist_y^2) * Exp.Cfg.degPerPixel; % in degrees
                
            end
            
            %++code should be added here to display and check the quality of the
            % calibration
            
            Screen('FillRect',  win, 0);
            
            for m=1:numpoints
                position = pos(m,:);
                msg = sprintf( '%1.2f',  errors(m));
                Screen('DrawText', win, msg, position(1)*res(1), position(2)*res(2), [255 255 255]);
            end
            
            
            msg2 = sprintf('Mean Calibration error: %1.2f', mean(errors));
            Screen('DrawText', win, msg2, res(1)/4, res(2)/3, [255 255 255]);
            
            Screen('DrawText', win, 'press "C" and "ENTER" to resume calibration or any other key to continue\n',res(1)/4,res(2) * 0.65,[255 255 255]);
            Screen('Flip', win );
            
            
            %choose if you want to redo the calibration
            %disp('Press space to resume calibration or q to exit calibration and continue tracking');
            tt= input('press "C" followed by "ENTER" to resume calibration or any other key to continue\n','s');
            
            if ismember('c',tt)
                calib_not_suc = 1;
            else
                calib_not_suc = 0;
            end
            
        end
        disp('EndOfCalibration');
        
    end
    
    %     Screen('TextSize', win,50);
    % Screen('DrawText', win, 'Great, calibration is done!',res(1)/2,res(2)/2,[255 0 0]);
    Screen('Flip', win );
    
    %     talk2tobii('RECORD');
    talk2tobii('START_TRACKING');
    WaitSecs(0.2)
    
    % TET_API_AUTOSYNCED
    talk2tobii('START_AUTO_SYNC')
    WaitSecs(2)
    
    %check status of TETAPI
    cond_res = check_status(7, max_wait, tim_interv,1);
    tmp = find(cond_res==0);
    if( ~isempty(tmp) )
        error('check_status has failed');
    end
    
    ErrorCode = 0;
    
    
    
    
catch
    ErrorCode = 1;
    rethrow(lasterror);
    talk2tobii('STOP_TRACKING');
    talk2tobii('DISCONNECT');
end

return;



function ctrl=IsKey(key)

global KEYBOARD;
[keyIsDown,secs,keyCode]=PsychHID('KbCheck', KEYBOARD);
if ~isnumeric(key)
    kc = KbName(key);
else
    kc = key;
end;
ctrl=keyCode(kc);
return
