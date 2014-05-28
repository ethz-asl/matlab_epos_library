function [ ] = startHoming( obj )
%Starts the homing mode, sets the homing method to 35 (= actual postion)
%and then executes the homing

[pos] = readPosition(obj);
if (pos(1) == 0 && pos(2) == 0)
    disp('Curren position already [0 0]')
    return
end


%% Build write object request frame: EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index(operation mode): 0x6060
%subindex and nodeID: 0x0100
%value: 0x06

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('60') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('06') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6060') myhex2dec('0100') myhex2dec('0006') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

%% Build write object request frame: EPOS Node 2
%opCode(write): 0x11
%Len-1: 3
%object index(operation mode): 0x6060
%subindex and nodeID: 0x0200
%value: 0x06

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('60') myhex2dec('60') myhex2dec('00') myhex2dec('02') myhex2dec('06') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6060') myhex2dec('0200') myhex2dec('0006') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

%% Set Homing Method number, EPOS Node 1
%opCode(write): 0x11
%Len-1: 3
%object index: 0x6098
%subindex and nodeID: 0x0100
%value: 35 = 0x0023

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('98') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('23') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6098') myhex2dec('0100') myhex2dec('0023') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

%% Set Homing Method number, EPOS Node 2
%opCode(write): 0x11
%Len-1: 3
%object index: 0x6098
%subindex and nodeID: 0x0200
%value: 35 = 0x0023

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('98') myhex2dec('60') myhex2dec('00') myhex2dec('02') myhex2dec('23') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6098') myhex2dec('0200') myhex2dec('0023') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

%% Start Homing, EPOS Node 1

%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6040
%subindex and nodeID: 0x0100
%device control command 0x001F

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('40') myhex2dec('60') myhex2dec('00') myhex2dec('01') myhex2dec('1F') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6040') myhex2dec('0100') myhex2dec('001F') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

out = fread(obj, 8); %read from input buffer

if CRCcheck(out)
    fwrite(obj,char('O'));
else
    warning('Bad Checksum')
end

%% Start Homing, EPOS Node 2

%opCode(write): 0x11
%Len-1: 3
%object index(controlword): 0x6040
%subindex and nodeID: 0x0200
%device control command 0x001F

opCode = uint16(myhex2dec('11'));
Len_1 = uint16(3);
DATA = uint16([myhex2dec('40') myhex2dec('60') myhex2dec('00') myhex2dec('02') myhex2dec('1F') myhex2dec('00') myhex2dec('00')  myhex2dec('00')]);
DATAforCRC = uint16([myhex2dec('1103') myhex2dec('6040') myhex2dec('0200') myhex2dec('001F') myhex2dec('0000')  myhex2dec('0000')]);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

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

out = fread(obj, 8); %read from input buffer

if CRCcheck(out)
    fwrite(obj,char('O'));
else
    warning('Bad Checksum')
end

%% Test out

[pos] = readPosition(obj);

if (pos(1) == 0 && pos(2) == 0)
    disp('Homing successful')
else
    disp('Homing failed')
end


end

