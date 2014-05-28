%RS232 Control Script
%This script assumes that both EPOS are in their default position, homed and enabled. The Serial port handle should be obj.
%The mode will be set automatically.

%Check homing
if readPosition(obj) ~= 0
    error('Not homed')
end

%% Initialization
motorParam;
sysParam;

%creating variables for logging
i = 1;
time_log = zeros(10000, 1);
curr_log = zeros(10000, 2);
pos_log = zeros(10000, 2);
vel_log = zeros(10000, 2);
events_log = zeros(10000, 1); %a one is stored when changing to a new stage

%Set specific properties.
genericSend(obj, '6410', '0102', I_max*1000, 'uint16') %output current limit Node 1
genericSend(obj, '6410', '0202', I_max*1000, 'uint16') %output current limit Node 2

genericSend(obj, '6065', '0100', 110450/4, 'uint32') %max following error Node 1
genericSend(obj, '6065', '0200', 110450/4, 'uint32') %max following error Node 2

t0 = tic;
%% Stage 1: Driving up

time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);

startProfilePositionMode(obj, 400)
upPosition = (17/18)*pi; %desired position [rad] to be held when up
upPositionMotor = round(upPosition*110450/(2*pi));

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);
events_log(i) = 1;

sendTargetPosition(obj, [-upPositionMotor, upPositionMotor]);

while norm(pos_log(i,:) - [-upPositionMotor, upPositionMotor], Inf) > 1
    i = i+1;
    time_log(i) = toc(t0);
    curr_log(i,:) = readCurrent(obj);
    pos_log(i,:) = readPosition(obj);
    vel_log(i,:) = readVelocity(obj);
end

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);

pause(1)

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);

%% Stage 2: Pushing down
startCurrentMode(obj)

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);
events_log(i) = 1;

while pos_log(i,1) < 0 && pos_log(i,2) > 0
    desired_torque = g*mP*RP*sin(2*pi/(110450)*pos_log(i,1))-((IP+mP*RP^2)*csc(2*pi/(110450)*pos_log(i,1))*(2*g*mP+g*mW-N_Security_ground+2*mP*RP*cos(2*pi/(110450)*pos_log(i,1))*(2*pi/(60*27.6)*vel_log(i,1))^2))/(2*mP*RP);
    if desired_torque < 0 %in case the calculation goes wrong, we do not want negative torques (cable tangling)
        desired_torque = 0;
    end
    
    desired_current = min(I_nominal*1000, round(int16(desired_torque/k_TI*1000))); %[mA], int16 makes sure we dont get any overflow
    
    sendCurrent(obj, double([desired_current -desired_current])) %for unknow reasons, sendCurrent requires double values
    
    i = i+1;
    time_log(i) = toc(t0);
    curr_log(i,:) = readCurrent(obj);
    pos_log(i,:) = readPosition(obj);
    vel_log(i,:) = readVelocity(obj);
end



%% Stage 3: Full power

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);
events_log(i) = 1;

sendCurrent(obj, round([1000*I_nominal 1000*I_nominal]))

N = 100;
while N > N_Security_liftup
        
    i = i+1;
    time_log(i) = toc(t0);
    curr_log(i,:) = readCurrent(obj);
    pos_log(i,:) = readPosition(obj);
    vel_log(i,:) = readVelocity(obj);

%     TM1 = curr_log(i,1)*k_TI/1000;
%     TM2 = curr_log(i,2)*k_TI/1000;
%     
%    N = (1/2).*(IP+mP.*RP.^2).^(-1).*((IP+mP.*RP.^2).*(IW+(2.*mP+mW).* ...
%       RW.^2)+(-1).*mP.^2.*RP.^2.*RW.^2.*cos((2*pi/110450*pos_log(i,1))).^2+(-1).*mP.^2.* ...
%       RP.^2.*RW.^2.*cos((2*pi/110450*pos_log(i,2))).^2).^(-1).*(4.*g.*IP.^2.*IW.*mP+2.* ...
%       g.*IP.^2.*IW.*mW+6.*g.*IP.*IW.*mP.^2.*RP.^2+4.*g.*IP.*IW.*mP.*mW.* ...
%       RP.^2+2.*g.*IW.*mP.^3.*RP.^4+2.*g.*IW.*mP.^2.*mW.*RP.^4+8.*g.* ...
%       IP.^2.*mP.^2.*RW.^2+8.*g.*IP.^2.*mP.*mW.*RW.^2+2.*g.*IP.^2.* ...
%       mW.^2.*RW.^2+8.*g.*IP.*mP.^3.*RP.^2.*RW.^2+12.*g.*IP.*mP.^2.*mW.* ...
%       RP.^2.*RW.^2+4.*g.*IP.*mP.*mW.^2.*RP.^2.*RW.^2+g.*mP.^4.*RP.^4.* ...
%       RW.^2+4.*g.*mP.^3.*mW.*RP.^4.*RW.^2+2.*g.*mP.^2.*mW.^2.*RP.^4.* ...
%       RW.^2+g.*IP.*IW.*mP.^2.*RP.^2.*cos(2.*(2*pi/110450*pos_log(i,1)))+g.*IW.*mP.^3.* ...
%       RP.^4.*cos(2.*(2*pi/110450*pos_log(i,1)))+(-1).*g.*mP.^4.*RP.^4.*RW.^2.*cos(2.*( ...
%       (2*pi/110450*pos_log(i,1))+(-1).*(2*pi/110450*pos_log(i,2))))+g.*IP.*IW.*mP.^2.*RP.^2.*cos(2.* ...
%       (2*pi/110450*pos_log(i,2)))+g.*IW.*mP.^3.*RP.^4.*cos(2.*(2*pi/110450*pos_log(i,2)))+2.*IP.*IW.*mP.* ...
%       RP.*TM1.*sin((2*pi/110450*pos_log(i,1)))+2.*IW.*mP.^2.*RP.^3.*TM1.*sin((2*pi/110450*pos_log(i,1)))+ ...
%       4.*IP.*mP.^2.*RP.*RW.^2.*TM1.*sin((2*pi/110450*pos_log(i,1)))+2.*IP.*mP.*mW.*RP.* ...
%       RW.^2.*TM1.*sin((2*pi/110450*pos_log(i,1)))+3.*mP.^3.*RP.^3.*RW.^2.*TM1.*sin( ...
%       (2*pi/110450*pos_log(i,1)))+2.*mP.^2.*mW.*RP.^3.*RW.^2.*TM1.*sin((2*pi/110450*pos_log(i,1)))+(-1).* ...
%       IP.*mP.^2.*RP.^2.*RW.*TM1.*sin(2.*(2*pi/110450*pos_log(i,1)))+(-1).*mP.^3.*RP.^4.* ...
%       RW.*TM1.*sin(2.*(2*pi/110450*pos_log(i,1)))+(-1).*IP.*mP.^2.*RP.^2.*RW.*TM2.*sin( ...
%       2.*(2*pi/110450*pos_log(i,1)))+(-1).*mP.^3.*RP.^4.*RW.*TM2.*sin(2.*(2*pi/110450*pos_log(i,1)))+(-1) ...
%       .*mP.^3.*RP.^3.*RW.^2.*TM1.*sin((2*pi/110450*pos_log(i,1))+(-2).*(2*pi/110450*pos_log(i,2)))+mP.^3.* ...
%       RP.^3.*RW.^2.*TM2.*sin(2.*(2*pi/110450*pos_log(i,1))+(-1).*(2*pi/110450*pos_log(i,2)))+2.*IP.*IW.* ...
%       mP.*RP.*TM2.*sin((2*pi/110450*pos_log(i,2)))+2.*IW.*mP.^2.*RP.^3.*TM2.*sin((2*pi/110450*pos_log(i,2)))+4.*IP.*mP.^2.*RP.*RW.^2.*TM2.*sin((2*pi/110450*pos_log(i,2)))+2.*IP.*mP.*mW.* ...
%       RP.*RW.^2.*TM2.*sin((2*pi/110450*pos_log(i,2)))+3.*mP.^3.*RP.^3.*RW.^2.*TM2.*sin( ...
%       (2*pi/110450*pos_log(i,2)))+2.*mP.^2.*mW.*RP.^3.*RW.^2.*TM2.*sin((2*pi/110450*pos_log(i,2)))+(-1).* ...
%       IP.*mP.^2.*RP.^2.*RW.*TM1.*sin(2.*(2*pi/110450*pos_log(i,2)))+(-1).*mP.^3.*RP.^4.* ...
%       RW.*TM1.*sin(2.*(2*pi/110450*pos_log(i,2)))+(-1).*IP.*mP.^2.*RP.^2.*RW.*TM2.*sin( ...
%       2.*(2*pi/110450*pos_log(i,2)))+(-1).*mP.^3.*RP.^4.*RW.*TM2.*sin(2.*(2*pi/110450*pos_log(i,2)))+mP.* ...
%       RP.*(IP+mP.*RP.^2).*((2.*IP.*(IW+(2.*mP+mW).*RW.^2)+mP.*RP.^2.*( ...
%       2.*IW+(mP+2.*mW).*RW.^2)).*cos((2*pi/110450*pos_log(i,1)))+(-1).*mP.^2.*RP.^2.* ...
%       RW.^2.*cos((2*pi/110450*pos_log(i,1))+(-2).*(2*pi/110450*pos_log(i,2)))).*(2*pi/(60*27.6)*vel_log(i,1)) ...
%       .^2+mP.*RP.*(IP+mP.*RP.^2).*((-1).*mP.^2.*RP.^2.*RW.^2.*cos(2.* ...
%       (2*pi/110450*pos_log(i,1))+(-1).*(2*pi/110450*pos_log(i,2)))+(2.*IP.*(IW+(2.*mP+mW).*RW.^2)+mP.* ...
%       RP.^2.*(2.*IW+(mP+2.*mW).*RW.^2)).*cos((2*pi/110450*pos_log(i,2)))).*(2*pi/(60*27.6)*vel_log(i,2)).^2);
    
    disp('loop run')
    
    if pos_log(i,1)*2*pi/110450 > pi*3/4 || pos_log(i,2)*2*pi/110450 < -pi*3/4 %security if N calculation goes wrong
        warning('Stage 3 while loop: Position went out of bounds. Breaking loop')
        break
    end
    
end

%% Stage 4: Bring pendulum down
startProfilePositionMode(obj, 3500) %Velocity needs to be determined experimentally to be fast enough
sendTargetPosition(obj, [0 0]);

i = i+1;
time_log(i) = toc(t0);
curr_log(i,:) = readCurrent(obj);
pos_log(i,:) = readPosition(obj);
vel_log(i,:) = readVelocity(obj);
events_log(i) = 1;

for k=1:100
    i = i+1;
    time_log(i) = toc(t0);
    curr_log(i,:) = readCurrent(obj);
    pos_log(i,:) = readPosition(obj);
    vel_log(i,:) = readVelocity(obj);
end

disableOperation(obj);


%% Data manipulation

%Cut off the trailing 0 elements
time_log = time_log(1:i);
curr_log = curr_log(1:i,:);
pos_log = pos_log(1:i,:);
vel_log = vel_log(1:i,:);
events_log = events_log(1:i);

%create data for eventlines
eventlines_indexes = find(events_log>0);
eventlines_t = zeros(2,length(eventlines_indexes));
for k=1:length(eventlines_indexes)
    eventlines_t(:,k) = ones(2,1)*time_log(eventlines_indexes(k));
end

%Plot the data
figure
ax(1) = subplot(3,1,1, 'ygrid', 'on');
hold on
plot(time_log, curr_log(:,1), 'r-o')
plot(time_log, curr_log(:,2), 'b-o')
eventlines_y = [ones(1,length(eventlines_t))*max(max(curr_log)); ones(1,length(eventlines_t))*min(min(curr_log))];
line(eventlines_t, eventlines_y, 'Color', 'k','LineWidth',2)
hold off
ylabel('Current [mA]')
legend('Current 1 actual', 'Current 2 actual')


ax(2) = subplot(3,1,2, 'ygrid', 'on');
hold on
plot(time_log, pos_log(:,1)*360/110450, 'r-o')
plot(time_log, pos_log(:,2)*360/110450, 'b-o')
eventlines_y = [ones(1,length(eventlines_t))*max(max(pos_log*360/110450)); ones(1,length(eventlines_t))*min(min(pos_log*360/110450))];
line(eventlines_t, eventlines_y, 'Color', 'k','LineWidth',2)
hold off
ylabel('Position [deg]')
legend('Position 1 actual', 'Position 2 actual')

ax(3) = subplot(3,1,3, 'ygrid', 'on');
hold on
plot(time_log, vel_log(:,1)*2*pi/(60*27.6), 'r-o')
plot(time_log, vel_log(:,2)*2*pi/(60*27.6), 'b-o')
eventlines_y = [ones(1,length(eventlines_t))*max(max(vel_log*2*pi/(60*27.6))); ones(1,length(eventlines_t))*min(min(vel_log*2*pi/(60*27.6)))];
line(eventlines_t, eventlines_y, 'Color', 'k','LineWidth',2)
hold off
ylabel('Velocity after Gear [rad/s]')
legend('Velocity 1 actual', 'Velocity 2 actual')

linkaxes([ax(3) ax(2) ax(1)],'x');