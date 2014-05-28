function [ isequal ] = CRCcheck( output )
%CRCcheck takes the read output from EPOS and compares the received
%CRC with a calculated one
% The input must be a vector that comes straight from fread and contains
% the whole frame received (from Opcode to CRC). The elements are single bytes (each low and hight word
% seperate). Two elements make one word.
%1 is returned for correct CRC, 0 if not

isequal = 0;

output_hex = dec2hex(output, 2);

CRC_device = myhex2dec([output_hex(end,:) output_hex(end-1,:)]); %Calculate the CRC that was received from the device

outputlength = length(output)-2; %Do not include the checksum itself in length
CRCnumberOfWords = outputlength/2+1;
CRCData = uint16(zeros(1,CRCnumberOfWords));

CRCData(1) = uint16(myhex2dec([output_hex(1,:) output_hex(2,:)]));
for i=2:outputlength/2
    CRCData(i) = uint16(myhex2dec([output_hex(2*i,:) output_hex(2*i-1,:)]));
end

CRC_calculated = CRCcalc(CRCData, CRCnumberOfWords);

if CRC_device == CRC_calculated
    isequal = 1;
end

end