% function M=Grover_179(A,a,rho,d,theta,psi,tol)
%
% Returns the mutual inductance between two circular loops of radius A and a (with A >= a),
% whose centers are separated by a horizontal distance "rho" and vetical distance "d",
% and with a tilt angle "theta" and rotation angle "psi", with absolute tolerance "tol" (default: 1e-10)
%
% All dimensions must be in "meters" and angles in "radians"
%
% The formula used in this function is the one provided by:
% F. W. Grover, Proceedings of the I.R.E., 1944, pp. 620-629.
%
% The units have been adapted to the S.I. system
%
% Programmed by F. Sirois and S. Babic
% Ecole Polytechnique de Montreal, June 2009

function M=Grover_179(A,a,rho,d,theta,psi,tol)

if nargin==6,
   tol=1e-13;
elseif nargin<6 || nargin >7,
   error('Wrong number of parameters in function call (Grover_179.m)!');
end

% Preliminary computations
alpha=a/A; delta=d/A; gamma=rho/a;

% Integration, Romberg method (adaptation from author below)
%   Author: Martin Kacenak,
%           Department of Informatics and Control Engineering,
%           Faculty of BERG, Technical University of Kosice,
%           B.Nemcovej 3, 04200 Kosice, Slovak Republic
%   E-mail: ma.kac@post.cz
%   Date:   february 2001

decdigs=abs(floor(log10(tol)));
rom=zeros(2,decdigs);
romall=zeros(1,(2^(decdigs-1))+1);   
romall=feval('f179',0:2*pi/2^(decdigs-1):2*pi,alpha,delta,gamma,psi,theta);
h=2*pi;
rom(1,1)=h*(romall(1)+romall(end))/2;
for i=2:decdigs
   step=2^(decdigs-i+1);
   % trapezoidal approximations
   rom(2,1)=(rom(1,1)+h*sum(romall((step/2)+1:step:2^(decdigs-1))))/2;
   % Richardson extrapolation
   for k=1:i-1
      rom(2,k+1)=((4^k)*rom(2,k)-rom(1,k))/((4^k)-1);
   end
   rom(1,1:i)=rom(2,1:i);
   h=h/2;
end
M=2e-7*sqrt(A*a)*rom(1,decdigs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integrand function  
function f=f179(p,a,d,g,ps,th)

si=sin(ps); ci=cos(ps);
st=sin(th); ct=cos(th);
sp=sin(p); cp=cos(p);
V=sqrt(1-cp.*cp*st*st+2*g*(si*sp-cp*ci*ct)+g*g);
e=(d-a*st*cp); e=e.*e;
t=a*V; m=4*t; t=1+t; m=m./(t.*t+e); k=sqrt(m);
[K,E]=ellipke(m); f= (2./k).*( (1-0.5*k.*k).*K - E );
f=f./V.^1.5.*(ct-g*(ci*cp-si*ct*sp));
