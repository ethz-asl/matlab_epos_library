function [ ] = genericSend(obj, objID, SubnNode, value, datatype)
%Gerneric function to set an entry of the object dictionary
%The arguments are as follows
%   obj: RS232 stream object
%   objID: object index as defined by object dictionary. Must be a string representing a 4 digit hex number (e.g. 2030 for current mode setting value)
%   SubnNode: SubID and CAN Node. Must be a string representing a 4 digit hex number (e.g. 0100 for Node 01, subindex 00)
%   value: value to be written, a scalar (1x1) double value in decimal form
%   datatype: specifiy which variable type the data has. May be one of the following: 'int32', 'uint32', 'int16', 'uint16', 'int8', 'uint8'

% Build write object request frame
%opCode(write): 0x11
%Len-1: 3
%object index: objID
%subindex and nodeID: subnNode
%BYTE Data[4]: value_hex(1:4), value_hex(5:8)

switch datatype
    case 'int32'
        if (value > 2^31-1 || value < -(2^31-1))
            warning('Value too large for int32. Returning')
            return
        end
        
        if value >= 0
            value_hex = dec2hex(value, 8);
        else
            value_hex = dec2hex(2^32+value, 8);
        end
        
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex(7:8)) myhex2dec(value_hex(5:6)) myhex2dec(value_hex(3:4)) myhex2dec(value_hex(1:2)) ]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex(5:8)) myhex2dec(value_hex(1:4)) 0]);
        
    case 'uint32'
        if value >= 0
            value_hex = dec2hex(uint32(value), 8);
        else
            warning('Data of type uint32 may not take negative values. Returning')
            return
        end
        
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex(7:8)) myhex2dec(value_hex(5:6)) myhex2dec(value_hex(3:4)) myhex2dec(value_hex(1:2)) ]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex(5:8)) myhex2dec(value_hex(1:4)) 0]);
        
    case 'int16'
        if (value > 2^15-1 || value < -(2^15-1))
            warning('Value too large for int16. Returning')
            return
        end
        
        if value >= 0
            value_hex = dec2hex(value, 4);
        else
            value_hex = dec2hex(2^16+value, 4);
        end
        
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex(1,3:4)) myhex2dec(value_hex(1,1:2)) 0 0]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex) 0 0]);
        
        
    case 'uint16'
        if value >= 0
            value_hex = dec2hex(uint16(value), 4);
        else
            warning('Data of type uint16 may not take negative values. Returning')
            return
        end
        
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex(1,3:4)) myhex2dec(value_hex(1,1:2)) 0 0]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex) 0 0]);
    
    case 'int8'
        if (value > 2^7-1 || value < -(2^7-1))
            warning('Value too large for int8. Returning')
            return
        end
        
        if value >= 0
            value_hex = dec2hex(value, 2);
        else
            value_hex = dec2hex(2^8+value, 2);
        end
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex) 0 0 0]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex) 0 0]);
        
    case 'uint8'
        if value >= 0
            value_hex = dec2hex(uint16(value), 4);
        else
            warning('Data of type uint16 may not take negative values. Returning')
            return
        end
        DATA = uint16([myhex2dec(objID(3:4)) myhex2dec(objID(1:2)) myhex2dec(SubnNode(3:4)) myhex2dec(SubnNode(1:2)) myhex2dec(value_hex) 0 0 0]);
        DATAforCRC = uint16([4355 myhex2dec(objID) myhex2dec(SubnNode) myhex2dec(value_hex) 0 0]);
    
    otherwise
        warning('send2EPOS: unknown data type. Returning.')
        return
end


%opCode = uint16(myhex2dec('11'));
opCode = uint16(17);
Len_1 = uint16(3);
numberofWordsCRC = 6;
crc_hex = dec2hex(CRCcalc(DATAforCRC, numberofWordsCRC),4);
CRC = uint16([myhex2dec(crc_hex(3:4)) myhex2dec(crc_hex(1:2))]);

fwrite(obj, [opCode Len_1 DATA CRC char('O')]) %send all at once
while obj.BytesAvailable < 10
end
flushinput(obj) %Clear 10 Bytes out of input buffer: ReadyAck + EndAck + 8 Bytes 
fwrite(obj,char('O')); %confirm CRC

end