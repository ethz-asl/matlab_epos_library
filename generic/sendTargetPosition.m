function [] = sendTargetPosition( obj, pos )
%Sets the TargetPosition for Profile Position mode
%pos must be an integer.
pos_hex = '';

if pos >= 0
    pos_hex = dec2hex(pos, 8);
else
    pos_hex = dec2hex(2^32+pos, 8);
end

%% Build write object request frame EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(Target Position): 0x607A
%subindex and nodeID: 0x0100
%BYTE Data[4]: pos_hex(1:4), pos_hex(5:8)


%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('7A') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec(pos_hex(7:8)) myhex2dec(pos_hex(5:6)) myhex2dec(pos_hex(3:4)) myhex2dec(pos_hex(1:2)) ]);
DATA = uint16([122 96 0 1 myhex2dec(pos_hex(7:8)) myhex2dec(pos_hex(5:6)) myhex2dec(pos_hex(3:4)) myhex2dec(pos_hex(1:2)) ]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('607A') myhex2dec('0100') myhex2dec(pos_hex(5:8)) myhex2dec(pos_hex(1:4)) myhex2dec('0000')]);
DATAforCRC = uint16([4355 24698 256 myhex2dec(pos_hex(5:8)) myhex2dec(pos_hex(1:4)) 0]);
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
    
%% Controlword: Absolute Pos, start immediately EPOS Node 1
%Build write object request frame
%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6040
%subindex and nodeID: 0x0100
%device control command 0x003F

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('40') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('3F') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([64,96,0,1,63,0,0,0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6040') myhex2dec('0100') myhex2dec('003F') myhex2dec('0000')  myhex2dec('0000')]);
%numberofWordsCRC = 6;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([247,42]);

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