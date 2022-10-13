clear all

% Example 11 of paper (in terms of paper notations)
Rp=0.40;
Rs=0.10;
x1=0.10;
x2=0.20;
theta=90*(pi/180);
h=x1-x2*cos(theta);
d=x2*sin(theta);
psi=0*(pi/180);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of mutual inductance (M) by Grover's formula (179)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Conversion of above notation in Grover's notation
A=Rp; a=Rs; rho=d; d=h;

M_Grover=Grover_179(A,a,rho,d,theta,psi);

disp('----------------------------------------------------------');
disp('Parameters for Grover''s formula:');
disp(' ');
disp(['   Rs=' num2str(A)]);
disp(['   Rp=' num2str(a)]);
disp(['  rho=' num2str(rho)]);
disp(['    d=' num2str(d)]);
disp(['theta=' num2str(theta)]);
disp(['  psi=' num2str(psi)]);
disp(' ');
disp('Result obtained with Grover''s formula (179):');
disp(' ');
disp(['   M=' num2str(M_Grover*1e9) ' nH']);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of mutual inductance (M) by Babic's formula (24)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Conversion of above notation in Babic's notation
Rp=A; Rs=a;
xc=0; yc=rho; zc=d;
a=sin(psi)*sin(theta);
b=-cos(psi)*sin(theta);
c=cos(theta);

% tester en prenant n/Rs
%M_Babic=Babic_19(Rp,Rs,[xc yc zc],[a b c]);
M_Babic=Babic_24(Rp,Rs,[xc yc zc],[a b c]);

disp('----------------------------------------------------------');
disp('Parameters for Babic''s formula:');
disp(' ');
disp(['  Rp=' num2str(Rp) '      (i.e. parameter "A" of Grover)']);
disp(['  Rs=' num2str(Rs) '      (i.e. parameter "a" of Grover)']);
disp(['  xc=' num2str(xc) '      ==> parameter "rho" of Grover = sqrt(xc^2+yc^2)']);
disp(['  yc=' num2str(yc)]);
disp(['  zc=' num2str(zc) '      (i.e. parameter "d" of Grover)']);
disp(['   a=' num2str(a)]);
disp(['   b=' num2str(b)]);
disp(['   c=' num2str(c)]);
disp(' ');
disp('Result obtained with Babic''s formula (24):');
disp(' ');
disp(['   M=' num2str(M_Babic*1e9) ' nH']);
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For the sake of validating what we are computing, we draw the two
% circular loops...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preliminary computations
n_pts=701;
pc=[xc yc zc];        % Le centre de la boucle secondaire
r1=Rs*[-sin(psi)*cos(theta) ; cos(psi)*cos(theta) ; sin(theta)]';     % Calculs faits sur une feuille en faisant tourner le point Rs*[0 1 0] selon theta et psi
n=[a b c]; n=n/norm(n);
r2=cross(n,r1);
u=r2/norm(r2);
v=cross(n,u);

figure(1)
clf
hold on
for tt=0:2*pi/n_pts:2*pi*(1-1/n_pts),
   pp=Rp*[cos(tt) sin(tt) 0];
   plot3(pp(1),pp(2),pp(3),'.b');
   ps=pc+Rs*u*cos(tt)+Rs*v*sin(tt);
   plot3(ps(1),ps(2),ps(3),'.g');
end
box on
set(gca,'DataAspectRatioMode','Manual');
line([0 2*Rp],[0 0],[0 0]);
line([0 0],[0 3*Rp],[0 0]);
line([0 0],[0 0],[0 2*Rp]);
xlabel('x'); ylabel('y'); zlabel('z');
%axis(Rp*[-2 2 -2 3 -1 2]);
view([1 0.7 0.7]);


