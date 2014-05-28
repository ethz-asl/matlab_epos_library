function [ returncode ] = RS232_shutdown()
%Closes all connections
returncode = 1;

%% close connection and delete object

fclose(instrfind)
delete(instrfind)

if isempty(instrfind)
    disp('Closed all connections.')
    returncode = 0;
else
    warning('Shutdown failed. Close connections manually')
end

end

