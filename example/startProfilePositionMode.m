function [ ] = startProfilePositionMode(obj, profileVelocity )
% Switch to Profile Position Mode and set the profile velocity

%% Build write object frame (set profile velocity) EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6081
%subindex and nodeID: 0x0100
%value: profilevelocity

profileVelocity_hex = dec2hex(profileVelocity, 4);

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('81') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec(profileVelocity_hex(3:4)) myhex2dec(profileVelocity_hex(1:2)) myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([129 96 0 1 myhex2dec(profileVelocity_hex(3:4)) myhex2dec(profileVelocity_hex(1:2)) 0  0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6081') myhex2dec('0100') myhex2dec(profileVelocity_hex) myhex2dec('0000')  myhex2dec('0000')]);
DATAforCRC = uint16([4355 24705 256 myhex2dec(profileVelocity_hex) 0 0]);
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
[~] = fread(obj, 10); %read input buffer. Its ReadyAck + EndAck + 8 Bytes 
fwrite(obj,char('O')); %confirm CRC

%% Build write object frame (set profile velocity) EPOS Node 2
%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6081
%subindex and nodeID: 0x0200
%value: profilevelocity

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('81') myhex2dec('60') myhex2dec('00') myhex2dec('02') myhex2dec(profileVelocity_hex(3:4)) myhex2dec(profileVelocity_hex(1:2)) myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([129 96 0 2 myhex2dec(profileVelocity_hex(3:4)) myhex2dec(profileVelocity_hex(1:2)) 0 0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6081') myhex2dec('0200') myhex2dec(profileVelocity_hex) myhex2dec('0000')  myhex2dec('0000')]);
DATAforCRC = uint16([4355 24705 512 myhex2dec(profileVelocity_hex) 0 0]);
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
[~] = fread(obj, 10); %read input buffer. Its ReadyAck + EndAck + 8 Bytes 
fwrite(obj,char('O')); %confirm 

%% Build write object frame EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(mode of operation): 0x6060
%subindex and nodeID: 0x0100
%value: 0x01

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('60') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('01') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([96,96,0,1,1,0,0,0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6060') myhex2dec('0100') myhex2dec('0001') myhex2dec('0000')  myhex2dec('0000')]);
%numberofWordsCRC = 6;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([165,154]);

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
[~] = fread(obj, 10); %read input buffer. Its ReadyAck + EndAck + 8 Bytes 
fwrite(obj,char('O')); %confirm CRC

%% Build write object request frame EPOS Node 2
%opCode(write): 0x11
%Len-1: 3
%object index(mode of operation): 0x6060
%subindex and nodeID: 0x0200
%value: 0x01

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('60') myhex2dec('60') myhex2dec('00') myhex2dec('02') myhex2dec('01') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([96,96,0,2,1,0,0,0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6060') myhex2dec('0200') myhex2dec('0001') myhex2dec('0000')  myhex2dec('0000')]);
%numberofWordsCRC = 6;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([69,84]);

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
[~] = fread(obj, 10); %read input buffer. Its ReadyAck + EndAck + 8 Bytes 
fwrite(obj,char('O')); %confirm CRC

end