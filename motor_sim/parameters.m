clear all; close all;

r2p = @(x) [abs(x) rad2deg(angle(x))];                      % Rectangular -> Phasor
p2r = @(x) x(1)*exp(1i*deg2rad(x(2)));                      % Phasor -> Rectangular 

Ts=0.0005; %sample time

%% gear and arm parameters
I1=36; %gear ratio for base motor #1
J_gear=0.6*10^-7;%kgm^2
B_g=0.0329;%gear torque gradient
J_arm=0.00122;%kgm^2

%% encoder parameters
CPT=1024; %count per turn of the incoder
Res=2*pi/(4+CPT);% effective resolution in rads/state smaller the better

%% Motor parameters
% Electrical
R  = 0.335;       % Ohm Armature resistance
L  = 0.035*10^-3;       % Ohm*s Armature inductance

% Bridge
Kb = 9.73*10^-3;       % V/rad Motor constant
Km = 9.73*10^-3;      % Nm/A

I=0.0818; %in Amp no load current
No_Load_rpm=11700; %no load speed rpm

% conversion factor
RPM_to_Hz=1/60; %s/min
Hz_to_rad=2*pi; %rad/rev

%conversion
No_Load_rad=(No_Load_rpm*RPM_to_Hz*Hz_to_rad); %rad/s

% Mechanical
J = 9.06*10^-7;%0.0008666;       % kgm^2 Armature inertia !!!also the interia from arm
B = Km*I/No_Load_rad; % Dm=Te/w=k*I/w Nm/rad speed/torque gradient

%% combined barameter
J1 = I1^2*(J+J_gear)+J_arm;
B1 = I1^2*(B);

J2 = J+J_gear+J_arm/(I1^2);
B2 = B;
%this is different from speed/torque gradient which describes an operating
%condition when under load

%% pade approximation

s=tf('s');

[num_pade den_pade]=pade(Ts/1.5,1); %first order pade approximation used to simulate zoh behaviour 4.3
ZOH_pade=tf(num_pade,den_pade);
%ZOH_pade=tf(333,den_pade);
ZOH_pade=(1-ZOH_pade)/(Ts*s);

%% Step 1 system identification and motor transfer function

%PWM modeling
Vt=12;

%motor forward transfer function
H=Vt*Km*I1*1/((L*s+R)*(J1*s+B1));%mechanical and electrical impedance

%motor feedback transferfunction
G=Kb*I1;

%Motor complete transferfunction
Motor=feedback(H,G);%tf for input voltage to speed

%Motor position transferfunction
Pos_motor=Motor/s; %figure(1); rlocus(Pos_motor)

%% Step 2 Rlocus of motor unity gain feed back
figure(1); rlocus(Pos_motor);
pole(Pos_motor);

%% Step 3 Model System & Design Filter

nhat = 4; 
N = 4/(Ts*nhat); %filter pole location

K_i=1;%k*z1*z2/N; %I gain
K_p=30;%(k*(z1+z2)-Ki)/N; %p gain 40
K_d=0.2;%(k-Kp)/N; %D gain

%% Step 4 System Nyquist Plot and determine appropriate zero location
%Purpose: Find Z
figure(2);
subplot(2,1,1);
margin(Pos_motor);
subplot(2,1,2);
%nyquist(Pos_motor);
nyqlog(Pos_motor);

Z1 = -(-(K_i+K_p*N)+sqrt((K_i+K_p*N)^2-4*(K_p+K_d*N)*K_i*N))/(2*(K_p+K_d*N));
Z2 = -(-(K_i+K_p*N)-sqrt((K_i+K_p*N)^2-4*(K_p+K_d*N)*K_i*N))/(2*(K_p+K_d*N));

%% Step 5 Controller P&Z
%Purpose: Build controller, find new Ku
K = 1; %let K = 1 first
ControllerTF = K*(s+Z1)*(s+Z2)/(s*(s+N));%K is still unchosen yet
newOpenTF = ControllerTF * Pos_motor;
figure(3);
rlocus(newOpenTF);

%% Step 6: Controller Nyquist Plot
%Purpose: Test open sys TF, find new Ku
figure(4);
subplot(2,1,1);margin(newOpenTF);
subplot(2,1,2);nyqlog(newOpenTF); title('PID #1');
%Result from Step 6:  
Ku = K_p+K_d*N; 

%% Step 7: Tune PID Gains

Ki = Ku*Z1*Z2/N;
Kp = (Ku*(Z1+Z2)-Ki)/N;
Kd = (Ku-Kp)/N;

PID_C=Kp+Ki/s+Kd*N/(1+N/s); %continuous domain PID transfer function
PID_D=c2d(PID_C,Ts,'zoh');%convert continuous domain PID into discrete domain PID

display(Ki); display(Kp); display(Kd);



