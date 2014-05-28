function [  ] = enableOperation( obj )
%Sets the state to switched on and enabled. Releases any Quickstop

%% Switch on and enable: EPOS Node 1
%Build request frame

%Build write object request frame
%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6040
%subindex and nodeID: 0x0100
%device control command 0x000F

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('40') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('0F') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6040') myhex2dec('0100') myhex2dec('000F') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

fwrite(obj,opCode); %Send the opCode

ReadyAck = fread(obj, 1); %See if EPOS is ready
if ReadyAck == 'O'
    disp('O')
    %Now send the data
    fwrite(obj,[Len_1 DATA CRC]); 
   
    EndAck = fread(obj, 1); %See if EPOS is ready
    if EndAck ~= 'O'
        warning('EPOS did not send correct EndAck');
    end
else
    warning('No or incorrect ReadyAck')
end

%we are always ready: tell epos to send his response (error code)
fwrite(obj,char('O'));

while obj.BytesAvailable < 8 %wait until we received all data
    pause(0.005)
end

BA = obj.BytesAvailable;
out = fread(obj, BA); %read from input buffer

if CRCcheck(out)
    fwrite(obj,char('O'));
else
    warning('Bad Checksum')
end

end