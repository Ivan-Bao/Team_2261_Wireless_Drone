clear all; close all;

r2p = @(x) [abs(x) rad2deg(angle(x))];                      % Rectangular -> Phasor
p2r = @(x) x(1)*exp(1i*deg2rad(x(2)));                      % Phasor -> Rectangular 

Ts=0.0005; %sample time

%% mechanical domain parameters
I1=36; %gear ratio for base motor #1
J_gear=0.6*10^-7;%kgm^2
B_g=0.0329;%gear torque gradient
J_arm=0.00122;%kgm^2


%% Motor parameters
% Electrical
R  = 0.335;             % Ohm Armature resistance
L  = 0.035*10^-3;       % Ohm*s Armature inductance

% Bridge
Kb = 9.73*10^-3;        % V/rad Motor constant
Km = 9.73*10^-3;        % Nm/A

I=0.0818;               % Amp, no load current
No_Load_rpm=11700;      % rpm, no load speed

% conversion factor
RPM_to_Hz=1/60; %s/min
Hz_to_rad=2*pi; %rad/rev

%conversion
No_Load_rad=(No_Load_rpm*RPM_to_Hz*Hz_to_rad); %rad/s

% Mechanical
J = 9.06*10^-7;%0.0008666;       % kgm^2 Armature inertia !!!also the interia from arm
B = Km*I/No_Load_rad; % Dm=Te/w=k*I/w Nm/rad speed/torque gradient

%% combined parameter
J1 = I1^2*(J+J_gear)+J_arm;
B1 = I1^2*(B);

J2 = J+J_gear+J_arm/(I1^2);
B2 = B;
%this is different from speed/torque gradient which describes an operating
%condition when under load


%% motor transfer function

%PWM modeling
Vt=12;

%motor forward transfer function
s=tf('s');
H=Vt*Km*I1*1/((L*s+R)*(J1*s+B1));%mechanical and electrical impedance

%motor feedback transferfunction
G=Kb*I1;

%Motor complete transferfunction
Motor=feedback(H,G);%tf for input voltage to speed

%Motor position transferfunction
Pos_motor=Motor/s; %figure(1); rlocus(Pos_motor)

