function [  ] = startCurrentMode( obj )
%Switches to Current Mode

%% Build write object request frame: EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(operation mode): 0x6060
%subindex and nodeID: 0x0100
%value: 0xFD

%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('60') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('FD') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATA = uint16([96,96,0,1,253,0,0,0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6060') myhex2dec('0100') myhex2dec('00FD') myhex2dec('0000')  myhex2dec('0000')]);
%numberofWordsCRC = 6;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([150,12]);

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