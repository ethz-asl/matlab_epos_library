function [ position ] = readPosition(obj)
%Reads the actual position from EPOS2
%Input argument is the stream object (Serial Port)

position = zeros(1,2);

%% Build request frame: Position from EPOS Node 1

%opCode = uint16(myhex2dec('10'));
opCode = uint16(16);
Len_1 = uint16(1);
%DATA = uint16([myhex2dec('64') myhex2dec('60') myhex2dec('00') myhex2dec('01')]);
DATA = uint16([100,96,0,1]);
%DATAforCRC = uint16([myhex2dec('1001') myhex2dec('6064') myhex2dec('0100') myhex2dec('0000')]);
%numberofWordsCRC = 4;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([157,157]);

% fwrite(obj,opCode); %Send the opCode
% ReadyAck = fread(obj, 1); %See if EPOS is ready
% if ReadyAck == 'O'
%     %Now send the data
%     fwrite(obj,[Len_1 DATA CRC]); 
%    
%     EndAck = fread(obj, 1); %See if EPOS is ready
%     if EndAck ~= 'O'
%         error('EPOS did not send correct EndAck');
%     end
%     
%     %we are always ready: tell epos to send
%     fwrite(obj,char('O'));
%     out = fread(obj, 12);
    
    fwrite(obj,[opCode Len_1 DATA CRC char('O')]); %send all at once
    out = fread(obj, 14); %read from input buffer
    out = out(3:end); %discard ready and endack
    
%     if CRCcheck(out)
%         %disp('Checksum good')
%         fwrite(obj,char('O'));
%     else
%         warning('Bad Checksum')
%     end
    fwrite(obj,char('O'));
    
    position(1) = myhex2dec([dec2hex(out(10),2) dec2hex(out(9),2) dec2hex(out(8),2) dec2hex(out(7),2)]);
    %check if negative
    if position(1) > (2^31-1)
        position(1) = position(1) - 2^32;
    end

% elseif ReadyAck == 'F'
%     disp('EPOS ReadyAck = F')
% else
%     error('Error at reading ReadyAck')
% end

%% Build request frame: Position from EPOS Node 2
%opCode = uint16(myhex2dec('10'));
opCode = uint16(16);
Len_1 = uint16(1);
%DATA = uint16([myhex2dec('64') myhex2dec('60') myhex2dec('00') myhex2dec('02')]);
DATA = uint16([100,96,0,2]);
%DATAforCRC = uint16([myhex2dec('1001') myhex2dec('6064') myhex2dec('0200') myhex2dec('0000')]);
%numberofWordsCRC = 4;
%crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
%CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);
CRC = uint16([206,200]);

% fwrite(obj,opCode); %Send the opCode
% ReadyAck = fread(obj, 1); %See if EPOS is ready
% if ReadyAck == 'O'
%     %Now send the data
%     fwrite(obj,[Len_1 DATA CRC]); 
%    
%     EndAck = fread(obj, 1); %See if EPOS is ready
%     if EndAck ~= 'O'
%         error('EPOS did not send correct EndAck');
%     end
%     
%     %we are always ready: tell epos to send
%     fwrite(obj,char('O'));
%     out = fread(obj, 12);
    
    fwrite(obj,[opCode Len_1 DATA CRC char('O')]); %send all at once
    out = fread(obj, 14); %read from input buffer
    out = out(3:end); %discard ready and endack
    
%     if CRCcheck(out)
%         %disp('Checksum good')
%         fwrite(obj,char('O'));
%     else
%         warning('Bad Checksum')
%     end
    fwrite(obj,char('O'));
    
    position(2) = myhex2dec([dec2hex(out(10),2) dec2hex(out(9),2) dec2hex(out(8),2) dec2hex(out(7),2)]);
    %check if negative
    if position(2) > (2^31-1)
        position(2) = position(2) - 2^32;
    end

% elseif ReadyAck == 'F'
%     disp('EPOS ReadyAck = F')
% else
%     error('Error at reading ReadyAck')
% end

end