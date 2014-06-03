MATLAB EPOS Library
===================
A MATLAB library for easy control of Maxon Motor EPOS2 motor controllers over RS-232 serial connection.

Description
------------------

This library permits communication via Matlab functions scripts through RS-232 with EPOS2 controllers. It comes with a number of functions that allow setting the operative mode, sending setpoint values and reading actual values from the device.
There is also a Matlab GUI which is an easy way to drive your system in manual mode. The GUI uses callbacks to the above mentioned functions.

The generic folder contains scripts that are not yet tailored to a specific solution and provide the easiest way to be adapted.
The examples folder shows an application of this code that was used for two EPOS2 controllers (Node 1 and 2). It should serve as resource to see how the generic versions may be adapted to fit specific applications. In this case, Node 1 was connected to the computer via RS-232 and to Node 2 via CAN port. The node numbers were set by physically by DIP-switches on the device itself.


Using this Code
----------------
You are free to use this code for your own purposes. Please give credit to the author:

J. Carius: **Dynamic Maneuvers with a Single-Wheel Robot**, Bachelor Thesis, Autonomous Systems Lab ETH Zurich, 2014.

	@phdthesis{citation_key,
	author = {Carius, Jan},
	title = {{Dynamic Maneuvers with a Single-Wheel Robot}},
	school = {Swiss Federal Institute of Technology Zurich},
	year = {2014},
	type = {Bachelor's Thesis}
	}

The code has been tested on MATLAB R2013a on Windows 7 (64bit) with two Maxon Motor EPOS2 controllers. If using a different operating system, you might have to adapt the naming of the serial port in the file 'RS232_initialize.m'.

    obj = serial('COM1','BaudRate',115200, 'Databits', 8, 'Parity', 'none', 'StopBits', 1, 'InputBufferSize', 1024, 'OutputBufferSize', 1024);

Note that all functions, that send a setpoint value, need integers as arguments. Otherwise the decimal to hexadecimal conversion will produce an error.
	
If any problems arise, feel free to leave your comments or contact me directly.

Speed Issues
-------------
To improve performance of communication, the way of communication has been modified and is **not** according to the communication guide of EPOS2. The correct procedure has been commented out and may at any time be recovered. Furthermore, hexadecimal to decimal conversion and vice versa has been carried out where possible to reduce online computation effort. For better orientation, the original code was left in comments.
