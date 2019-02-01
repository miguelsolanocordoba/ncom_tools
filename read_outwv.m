function data=read_outwv(opath,nest,datev)
%       PURPOSE
%	        Reads contents of outwv_[nest]_yyyymmdd_HHMMSS00.A file
%       CALL
%               data=read_outwv(opath,nest,datev)
%       INPUT
%               opath,nest,datev = path,nest,[yyyy,mm,dd,HH,MM,SS]
%       OUTPUT
%               data.us = x-component of stokes drift current (m/s)
%               data.vs = x-component of stokes drift current (m/s)
%               data.wbc = magnitude of wave bottom current (m/s)
%               data.wbf = frequency of wave bottom current (rad/s)
%               data.wbd = direction of wave bottom current (rad)
%               data.sxx = xx-component of wave radiation stress (m3/s2)
%               data.sxy = xy-component of wave radiation stress (m3/s2)
%               data.syy = yy-component of wave radiation stress (m3/s2)
%       USES
%               The number of output fields depends on the
%               accompanying .B file: date,time,nest,nx,ny,nz,
%               followed by:
%               indus , include stokes drift current:  =0 no, =1 yes.
%               indwb , include wave bottom current:   =0 no, =1 yes.
%               indsx , include wave radiation stress: =0 no, =1 yes.
%
%               data=read_outwv(opath,1,[2008,10,10,00,03,00]);
%       HISTORY
%               Version 1       T. Campbell 05/07/10
%-----------------------------

fname=[opath '/outwv_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.B'];
fid=fopen(fname);
A=fscanf(fid,'%d %d %d %d %d %d %d %d %d',[9 inf]);
dimx=A(4);
dimy=A(5);
dimz=A(6);
indus=A(7);
indwb=A(8);
indsx=A(9);
clear A
fclose(fid);

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];
n3d=dimx*dimy*(dimz-1); shape3d=[dimx dimy dimz-1]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     shape3f=[dimx dimy dimz];   order3f=[2 1 3];

fname=[opath '/outwv_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.A'];
fid=fopen(fname,'r','ieee-be');

% stokes drift current (3D, dimz-1)
if (indus==1)
  data.us=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  data.vs=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end
% wave bottom current
if (indwb==1)
  data.wbc=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.wbf=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.wbd=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
% wave radiation stress
if (indsx==1)
  data.sxx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.sxy=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.syy=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end

fclose(fid);

