function [ obj ] = RS232_initialize()
%Initializes the Serial Port connection and returns the obj handle

%% Open the port
obj = serial('COM1','BaudRate',115200, 'Databits', 8, 'Parity', 'none', 'StopBits', 1, 'InputBufferSize', 1024, 'OutputBufferSize', 1024); %The name of the port must be changed according to hardware and operating system
obj.ReadAsyncMode = 'continuous';

fopen(obj)
if strcmp(obj.status, 'open')
    disp('Port open')
else
    error('Could not open COM1 port');
end

end