function [ value ] = genericRead(obj, objID, SubnNode, datatype)
%Gerneric function to read an entry of the object dictionary
%The arguments are as follows
%   obj: RS232 stream object
%   objID: object index as defined by object dictionary. Must be a string representing a 4 digit hex number (e.g. 2030 for current mode setting value)
%   SubnNode: SubID and CAN Node. Must be a string representing a 4 digit hex number (e.g. 0100 for Node 01, subindex 00)
%   datatype: specifiy which variable type the data has. May be one of the following: 'int32', 'uint32', 'int16', 'uint16', 'int8', 'uint8'

% Build read request frame

%opCode = uint16(myhex2dec('10'));
opCode = uint16(16);
Len_1 = uint16(1);
DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2))]);
DATAforCRC = uint16([4097 myhex2dec(objID) myhex2dec(SubnNode) 0]);
numberofWordsCRC = 4;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

fwrite(obj,[opCode Len_1 DATA CRC char('O')]); %send all at once
out = fread(obj, 14); %read from input buffer
out = out(3:end); %discard ready and endack

fwrite(obj,char('O'));

switch datatype
    case 'int32'
        value = myhex2dec([dec2hex(out(10),2) dec2hex(out(9),2) dec2hex(out(8),2) dec2hex(out(7),2)]);
        if value > (2^31-1) %check if negative
            value = value - 2^32;
        end
        
    case 'uint32'
         value = myhex2dec([dec2hex(out(10),2) dec2hex(out(9),2) dec2hex(out(8),2) dec2hex(out(7),2)]);
         
    case 'int16'
        value = myhex2dec([dec2hex(out(8),2) dec2hex(out(7),2)]);
        if value > (2^15-1) %check if negative
            value = value - 2^16;
        end
        
    case 'uint16'
        value = myhex2dec([dec2hex(out(8),2) dec2hex(out(7),2)]);
        
    case 'int8'
        value = out(7);
        if value > (2^7-1) %check if negative
            value = value - 2^8;
        end
        
    case 'uint8'
        value = out(7);
        
    otherwise
        warning('send2EPOS: unknown data type. Returning.')
        return
end

end