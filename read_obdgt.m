function [t s]=read_out3d(opath,nest,datev)
%       PURPOSE
%	        Reads contents of obdgt_[nest]_yyyymmdd_HHMMSS00.A file
%       CALL
%               [t s]=read_obdgt(opath,nest,datev)
%       INPUT
%               opath,nest,datev = path,nest,[yyyy,mm,dd,HH,MM,SS]
%       OUTPUT
%               t.totl = total temperature budget
%               t.hadv = contribution from horizontal advection
%               t.vadv = contribution from vertical advection
%               t.vsrc = contribution from volume sources
%               t.hmix = contribution from vertical mixing
%               t.vmix = contribution from vertical mixing
%               t.sflx = contribution from surface flux
%               s.totl = total salinity budget
%               ...
%       USES
%               [t s]=read_obdgt(opath,1,[2008,10,10,00,03,00]);
%       HISTORY
%               Version 1       T. Campbell 01/28/09
%-----------------------------

fname=[opath '/obdgt_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.B'];
fid=fopen(fname);
A=fscanf(fid,'%d %d %d %d %d %d %d %d');
dimx=A(4);
dimy=A(5);
dimz=A(6);
indt=A(7);
inds=A(8);
clear A
fclose(fid);

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];
n3d=dimx*dimy*(dimz-1); shape3d=[dimx dimy dimz-1]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     shape3f=[dimx dimy dimz];   order3f=[2 1 3];

fname=[opath '/obdgt_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.A'];
fid=fopen(fname,'r','ieee-be');

% temperature budget
if (indt==1)
  t.totl=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.hadv=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.vadv=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.vsrc=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.hmix=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.vmix=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  t.sflx=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end

% salinity budget
if (inds==1)
  s.totl=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.hadv=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.vadv=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.vsrc=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.hmix=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.vmix=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
  s.sflx=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
end

fclose(fid);

