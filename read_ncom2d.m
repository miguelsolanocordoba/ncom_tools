function data = read_ncom2d(opath,nest)
%READ_NCOM2d Reads NCOM 2D binary output. 
%   DATA = READ_NCPM2D(OPATH,NEST) Reads the NCOM binary file in directory 
%   OPATH for grid NEST and saves the output in structure DATA. 
%
%   DATA.LON -> Longitude [deg]
%   DATA.LAT -> Latitude [deg]
%   DATA.H -> Model Depth [m]
%   DATA.N -> Vertical Layers 
%   DATA.ZM -> Vertical grid [m]
%   DATA.ZW -> Vertical grid [m]
%   DATA.DX -> Delta X 
%   DATA.DY -> Delta Y
%   DATA.DAYS -> Total number of days simulated [days]
%   DATA.E -> Elevation (SSH)[m]
%   DATA.U -> Velocity X-component [m/s] 
%   DATA.V -> Velocity Y-component [m/s]
%   DATA.W -> Velocity W-component [m/s]
%   DATA.T -> Temperature [deg C]
%   DATA.S -> Salinity [psu]
%   DATA.RHO -> Density [kg/m^3]
%   DATA.TC -> Climate Temperature [deg C]
%   DATA.SC -> Climate Salinity [psu]
%   DATA.RHOC -> Climate Density [kg/m^3]
%   DATA.TKE -> Turbulent Kinetic Energy (k)[m^2/s^2]
%   DATA.Q2L -> Turbulent Kinetic Energy * L [m^2/s^2]
%   DATA.L -> Turbulent Length Scale [m]
%   DATA.ZKM -> Vertical Eddy Viscosity for Momentum [m^2/s^2]
%   DATA.ZKM_MAX -> Maximum Vertical Eddy Viscosity for Momentum [m^2/s^2]
%   DATA.ZKH -> Vertical Eddy Viscosity for Scalars [m^2/s^2]
%   DATA.ZKH_MAX -> Maximum Vertical Eddy Viscosity for Scalars [m^2/s^2]
%   DATA.EXT -> Solar Extinction (given in percentage, i.e. 0 to 1)[%]
%   DATA.PATM -> Atmospheric Pressure 
%   DATA.TX -> Surface Wind Stress in X-direction ?[dynes/m^2]
%   DATA.TX -> Surface Wind Stress in Y-direction ?[dynes/m^2]
%   DATA.Q0 -> Surface Heat Flux (Q0 = QB + QE + QS) [DegC*m/s]
%   DATA.EP -> Surface Freshwater Flux (Evaporation - Precipitation) 
%   DATA.SOL -> Solar Heat Flux
%   DATA.SR -> Surface Roughness [m]
%
%   Created by: Miguel Solano 
%   Date: April 30, 2018

%% 
fname=[opath '/pt_01_' num2str(nest) '.D'];

% Filename and format
precision = 'real*4';
machineformat = 'ieee-be'; 

% Open file 
fid = fopen(fname,'r',machineformat); 
A = fread(fid,precision,machineformat);

% Total hours (i.e. fields)
nt=numel(A); 
nf=768; % Values per time step saved (14x50 + 1x51 + 17x1 -> 32 variables)
tothrs=(nt-117)/nf;

% Read in coordinates and grid
data.lon=A(6); 
data.lat=A(7); 
data.h=A(10); 
data.N=A(12); 
data.zm=A(13:63); 
data.zw=A(64:113); 
data.dx=A(115); 
data.dy=A(116);

% Non-repeating variables (eg: lon, lat, z, etc) 
% Pre-allocate

data.days=zeros(tothrs,1);    % Time (in days)
data.e=zeros(tothrs,1);       % Elevation (almost 0)
data.u=zeros(tothrs,50);      % u-component of velocity
data.v=zeros(tothrs,50);      % v-component of velocity
data.w=zeros(tothrs,51);      % w-component of velocity
data.T=zeros(tothrs,50);      % Temperature
data.S=zeros(tothrs,50);      % Salinity
data.rho=zeros(tothrs,50);    % Density
data.Tc=zeros(tothrs,50);     % Climate Temperature
data.Sc=zeros(tothrs,50);     % Climate Salinity
data.rhoc=zeros(tothrs,50);   % Climate Density 
data.tke=zeros(tothrs,50);    % Turbulent Kinetic Energy
data.q2l=zeros(tothrs,50);    % Turbulent Dissipation 
data.zkm=zeros(tothrs,50);    % Eddy Coefficient for Momentum 
data.zkm_max=zeros(tothrs,1); % Maximum Eddy Coefficient for Momentum (0)
data.zkh=zeros(tothrs,50);    % Eddy Coefficient for Scalars
data.zkh_max=zeros(tothrs,1); % Maximum Eddy Coefficient for Scalars (0)
data.ext=zeros(tothrs,50);    % Solar Extinction 
data.patm=zeros(tothrs,1);    % Atmospheric Pressure (0)
data.tx=zeros(tothrs,1);      % Windstress in x direction [dynes/m^2]
data.ty=zeros(tothrs,1);      % Windstress in y direction [dynes/m^2]
data.q0=zeros(tothrs,1);      % Surface Heat Flux (Qb + Qe + Qs)
data.ep=zeros(tothrs,1);      % Freshwater Flux (Evaporation - Precipitation)
data.sol=zeros(tothrs,1);     % Solar Heat Flux
data.sr=zeros(tothrs,1);      % Surface Roughness

% Define Variables
data.days=A(119:nf:end); 
data.e=A(120:nf:end); 

for i=1:tothrs
    data.u(i,:)=A(121+nf*(i-1):170+nf*(i-1));
    data.v(i,:)=A(171+nf*(i-1):220+nf*(i-1));
    data.w(i,:)=A(221+nf*(i-1):271+nf*(i-1));
    data.T(i,:)=A(272+nf*(i-1):321+nf*(i-1));
    data.S(i,:)=A(322+nf*(i-1):371+nf*(i-1));
    data.rho(i,:)=A(372+nf*(i-1):421+nf*(i-1));
    data.Tc(i,:)=A(422+nf*(i-1):471+nf*(i-1));
    data.Sc(i,:)=A(472+nf*(i-1):521+nf*(i-1));
    data.rhoc(i,:)=A(522+nf*(i-1):571+nf*(i-1));
    data.tke(i,:)=A(572+nf*(i-1):621+nf*(i-1));    
    data.q2l(i,:)=A(623+nf*(i-1):672+nf*(i-1)); 
    data.zkm(i,:)=A(725+nf*(i-1):774+nf*(i-1));
    data.zkh(i,:)=A(776+nf*(i-1):825+nf*(i-1));
    data.ext(i,:)=A(827+nf*(i-1):876+nf*(i-1));
end

data.zkm_max(775:nf:end); 
data.zkh_max(826:nf:end); 
data.patm=A(877:nf:end);
data.tx=A(879:nf:end);
data.ty=A(880:nf:end);
data.q0=A(881:nf:end);
data.ep=A(882:nf:end);
data.sol=A(883:nf:end);
data.sr=A(884:nf:end);