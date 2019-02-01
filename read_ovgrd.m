function vgrd=read_ovgrd(opath,nest)
%       PURPOSE
%	        Reads contents of ovgrd_[nest].D file and construct
%               vertical grid
%       CALL
%               vgrd=read_ovgrd(opath,nest)
%       INPUT
%               opath,nest = path,nest
%       OUTPUT
%               vgrd.l   : number of layers + 1
%               vgrd.ls  : number of sigma layers + 1
%               vgrd.zw  : layer depths
%               vgrd.dzw : 
%               vgrd.zm  : 
%               vgrd.dzm : 
%               vgrd.sw  : 
%               vgrd.dsw : 
%               vgrd.sm  : 
%               vgrd.dsm : 
%       USES
%               vgrd1=read_ovgrd(opath,1);
%       HISTORY
%               Version 1       T. Campbell 01/09/09
%-----------------------------
zero=0.0;
one=1.0;
zp5=0.5;

% read data from ovgrd file
fname=[opath '/ovgrd_' num2str(nest) '.D'];
fid=fopen(fname,'r','ieee-be');
fseek(fid,4,'cof');
vgrd.l=int32(fread(fid,1,'float32'));
vgrd.ls=int32(fread(fid,1,'float32'));
l=vgrd.l; ls=vgrd.ls;
vgrd.zw=fread(fid,double(l),'float32');
fclose(fid);

% setup zlevel part of vertical grid.
% remember that sw, sm, zw, zm are defined to be negative.
vgrd.zm=vgrd.zw(1:l-1);
vgrd.dzw=vgrd.zw;
vgrd.dzm=vgrd.zw(1:l-1);
for k=1:l-1
  vgrd.zm(k)=zp5*(vgrd.zw(k)+vgrd.zw(k+1));
  vgrd.dzm(k)=vgrd.zw(k)-vgrd.zw(k+1);
end
vgrd.dzw(1)=zp5*vgrd.dzm(1);
for k=2:l-1
  vgrd.dzw(k)=vgrd.zm(k-1)-vgrd.zm(k);
end
vgrd.dzw(l)=zp5*vgrd.dzm(l-1);

% setup sigma grid.
vgrd.sw=vgrd.zw;
vgrd.sm=vgrd.zw(1:l-1);
vgrd.dsw=vgrd.zw;
vgrd.dsm=vgrd.zw(1:l-1);
a=vgrd.zw(1)-vgrd.zw(ls);

for k=1:ls
  vgrd.sw(k)=-(vgrd.zw(1)-vgrd.zw(k))/a;
  vgrd.dsw(k)=vgrd.dzw(k)/a;
end

for k=1:ls-1
  vgrd.sm(k)=-(vgrd.zw(1)-vgrd.zm(k))/a;
  vgrd.dsm(k)=vgrd.dzm(k)/a;
end
% note:  The calculation of grid cell depth in some of model loops
%        uses the construct    dz = dsm(k)*d1(i,j) + dzm(k).  This
%        construct depends on dzm being zero on the sigma part of the
%        grid, and dsm being zero on the z-level part of the grid.
vgrd.dzm(1:ls-1)=zero;
vgrd.sm(ls:l-1)=zero;
vgrd.dsm(ls:l-1)=zero;
vgrd.sw(ls+1:l)=zero;
vgrd.dsw(ls+1:l)=zero;

