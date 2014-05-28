function [ ] = disableOperation( obj )

%% send shutdown command Node 1
%Build request frame

%Build write object request frame
%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6040
%subindex and nodeID: 0x0100
%device control command 0x0006

opCode = uint16(hex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([hex2dec('40') hex2dec('60') hex2dec('00') hex2dec('01') hex2dec('06') hex2dec('00') hex2dec('00')  hex2dec('00')]);
DATAforCRC = uint16([hex2dec('1103') hex2dec('6040') hex2dec('0100') hex2dec('0006') hex2dec('0000')  hex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([hex2dec(crc_hex(3:4)) hex2dec(crc_hex(1:2))]);

fwrite(obj,opCode); %Send the opCode

ReadyAck = fread(obj, 1); %See if EPOS is ready
if ReadyAck == 'O'
    %Now send the data
    fwrite(obj,[Len_1 DATA CRC]); 
   
    EndAck = fread(obj, 1); %See if EPOS is ready
    if EndAck ~= 'O'
        warning('EPOS did not send correct EndAck');
    end
end

%we are always ready: tell epos to send his response (error code)
fwrite(obj,char('O'));

while obj.BytesAvailable < 8 %wait until we received all data
end

BA = obj.BytesAvailable;
out = fread(obj, BA); %read from input buffer

if CRCcheck(out)
    fwrite(obj,char('O'));
else
    warning('Bad Checksum')
end

end