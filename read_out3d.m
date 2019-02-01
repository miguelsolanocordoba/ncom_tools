function data=read_out3d(opath,nest,datev)
%       PURPOSE
%	        Reads contents of out3d_[nest]_yyyymmdd_HHMMSS00.A file
%       CALL
%               data=read_out3d(opath,nest,datev)
%       INPUT
%               opath,nest,datev = path,nest,[yyyy,mm,dd,HH,MM,SS]
%       OUTPUT
%               data.e data.ub data.vb : elevation, u/v transport (all 2D)
%               data.u data.v data.w data.t data.s (all 3D, w has
%               one more vertical level!)
%               data.p data.tx data.ty data.qt data.sf data.sw data.z
%               pressure, stress x/y, flux heat/salt/solar, roughness
%       USES
%               The number of output fields depends on the
%               accompanying .B file: date,time,nest,nx,ny,nz,
%               followed by:
%               inde3  , include surface elevation:    =0 no, =1 yes.
%               indvb3 , include barotropic transport: =0 no, =1 yes.
%                        note:  = (depth-ave  u and v velocity)*(depth).
%               indv3  , include 3-D u and v velocity: =0 no, =1 yes.
%               indw3  , include 3-D vertical velocity:=0 no, =1 yes.
%               indt3  , include 3-D temperature:      =0 no, =1 yes.
%               inds3  , include 3-D salinity:         =0 no, =1 yes.
%               inda3  , include surface atm forcing:  =0 no, =1 yes.
%                        note:  this includes surface windstress, solar,
%                        net surface heat flux (longwave + latent +
%                        sensible), and evaporation - precipitation.

%               data=read_out3d(opath,1,[2008,10,10,00,03,00]);
%       HISTORY
%               Version 1       S. Gabersek 12/30/08
%-----------------------------

fname=[opath '/out3d_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.B'];
fid=fopen(fname);
A=fscanf(fid,'%d %d %d %d %d %d %d %d %d %d %d %d %d');
dimx=A(4);
dimy=A(5);
dimz=A(6);
inde3=A(7);
indvb3=A(8);
indv3=A(9);
indw3=A(10);
indt3=A(11);
inds3=A(12);
inda3=A(13);
clear A
fclose(fid);

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];
n3d=dimx*dimy*(dimz-1); shape3d=[dimx dimy dimz-1]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     shape3f=[dimx dimy dimz];   order3f=[2 1 3];

fname=[opath '/out3d_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.A'];
fid=fopen(fname,'r','ieee-be');

% surface displacement (2D)
if (inde3==1)
  data.e=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
% barotropic transport (2D)
if (indvb3==1)
  data.ub=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.vb=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
% u,v (3D, dimz-1)
if (indv3==1)
  data.u=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  data.v=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end
% w (3D, dimz)
if (indw3==1)
  data.w=permute(reshape(fread(fid,n3f,'float32'),shape3f),order3f);
end
% t (3D, dimz-1)
if (indt3==1)
  data.t=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end
% s (3D, dimz-1)
if (inds3==1)
  data.s=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end
% atmos forcing (2D)
if (inda3==1)
  data.p =permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.tx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.ty=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.qt=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.sf=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.sw=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.z =permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end

fclose(fid);

