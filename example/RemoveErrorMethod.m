%This is a script to clear the error that appears when first plugging in
%It assumes the serial port is not yet connected

obj = RS232_initialize();
faultReset(obj);
enableOperation(obj);
disableOperation(obj);
[~] = RS232_shutdown();