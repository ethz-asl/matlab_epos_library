function [] = sendVelocity(obj, vel )
%Sets the Velocity mode = setting value
%   vel an integer.

vel_hex = '';

if vel >= 0
    vel_hex = dec2hex(vel, 8);
else
    vel_hex = dec2hex(2^32+vel, 8);
end


%% Build write object request frame EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(velocity mode setting value): 0x206B
%subindex and nodeID: 0x0100
%BYTE Data[4]: vel_hex(1:4), vel_hex(5:8)


%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('6B') myhex2dec('20') myhex2dec('00') myhex2dec('01') myhex2dec(vel_hex(7:8)) myhex2dec(vel_hex(5:6)) myhex2dec(vel_hex(3:4)) myhex2dec(vel_hex(1:2)) ]);
DATA = uint16([107 32 0 1 myhex2dec(vel_hex(7:8)) myhex2dec(vel_hex(5:6)) myhex2dec(vel_hex(3:4)) myhex2dec(vel_hex(1:2)) ]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('206B') myhex2dec('0100') myhex2dec(vel_hex(5:8)) myhex2dec(vel_hex(1:4)) myhex2dec('0000')]);
DATAforCRC = uint16([4355 8299 256 myhex2dec(vel_hex(5:8)) myhex2dec(vel_hex(1:4)) 0]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

% fwrite(obj,opCode); %Send the opCode
% ReadyAck = fread(obj, 1); %See if EPOS is ready
% if ReadyAck == 'O'
%     %Now send the data
%     fwrite(obj,[Len_1 DATA CRC]); 
%    
%     EndAck = fread(obj, 1); %See if EPOS is ready
%     if EndAck ~= 'O'
%        warning('EPOS did not send correct EndAck');
%     end
% 
%     fwrite(obj,char('O'));%tell epos to send his response (error code)
%     
%     
%     
%     out = fread(obj, 8); %read from input buffer
%     
%     if CRCcheck(out)
%         fwrite(obj,char('O'));
%         disp('Checksum good')
%     else
%         warning('Bad Checksum')
%     end
%     
% elseif ReadyAck == 'F'
%     disp('EPOS ReadyAck = F')
% else
%     error('Error at reading ReadyAck')
% end

fwrite(obj, [opCode Len_1 DATA CRC char('O')]) %send all at once
while obj.BytesAvailable < 10
end
flushinput(obj) %Clear 10 Bytes out of input buffer: ReadyAck + EndAck + 8 Bytes
fwrite(obj,char('O')); %confirm CRC

end