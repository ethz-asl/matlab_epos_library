function [ ] = sendCurrent( obj, curr )
%Sets the Current Mode Setting Value. Curr is in mA

curr_hex = [''; ''];

if curr(1) >= 0
    curr_hex(1,:) = dec2hex(curr(1), 4);
else
    curr_hex(1,:) = dec2hex(2^16+curr(1), 4);
end

if curr(2) >= 0
    curr_hex(2,:) = dec2hex(curr(2), 4);
else
    curr_hex(2,:) = dec2hex(2^16+curr(2), 4);
end


%% Build write object request frame EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(current mode setting value): 0x2030
%subindex and nodeID: 0x0100
%BYTE Data[4]: curr_hex


%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('30') myhex2dec('20') myhex2dec('00') myhex2dec('01') myhex2dec(curr_hex(1,3:4)) myhex2dec(curr_hex(1,1:2)) myhex2dec('00') myhex2dec('00') ]);
DATA = uint16([48 32 0 1 myhex2dec(curr_hex(1,3:4)) myhex2dec(curr_hex(1,1:2)) 0 0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('2030') myhex2dec('0100') myhex2dec(curr_hex(1,:)) myhex2dec('0000') myhex2dec('0000')]);
DATAforCRC = uint16([4355 8240 256 myhex2dec(curr_hex(1,:)) 0 0]);
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

%% Build write object request frame EPOS Node 2
%opCode(write): 0x11
%Len-1: 3
%object index(current mode setting value): 0x2030
%subindex and nodeID: 0x0200
%BYTE Data[4]: curr_hex


%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
%DATA = uint16([myhex2dec('30') myhex2dec('20') myhex2dec('00') myhex2dec('02') myhex2dec(curr_hex(2,3:4)) myhex2dec(curr_hex(2,1:2)) myhex2dec('00') myhex2dec('00') ]);
DATA = uint16([48 32 0 2 myhex2dec(curr_hex(2,3:4)) myhex2dec(curr_hex(2,1:2)) 0 0]);
%DATAforCRC = uint16([myhex2dec('1103') myhex2dec('2030') myhex2dec('0200') myhex2dec(curr_hex(2,:)) myhex2dec('0000') myhex2dec('0000')]);
DATAforCRC = uint16([4355 8240 512 myhex2dec(curr_hex(2,:)) 0 0]);
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