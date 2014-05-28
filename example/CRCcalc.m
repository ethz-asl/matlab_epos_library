function [ CRC ] = CRCcalc(DataArray, CRCnumberOfWords)
%Calculates the 16 bit CRC checksum according to communication guide for
%EPOS2
%Arguments are the DataArray that is being sent (opCode to Data) and the
%number of words

CRC = uint16(0);
for i=1:CRCnumberOfWords
    
    %shifter = uint16(myhex2dec('8000'));
    shifter = uint16(32768);
    c = DataArray(i);
    
    while(shifter)
        %carry = bitand(CRC, uint16(myhex2dec('8000')), 'uint16');
        carry = bitand(CRC, uint16(32768), 'uint16');
        CRC = bitshift(CRC,1,'uint16');
        if(bitand(c, shifter, 'uint16'))
            CRC = CRC +  1;
        end
        if(carry)
            %CRC = bitxor(CRC,uint16(myhex2dec('1021')),'uint16');
            CRC = bitxor(CRC,uint16(4129),'uint16');
        end
        shifter = bitshift(shifter,-1,'uint16');
    end
end
end