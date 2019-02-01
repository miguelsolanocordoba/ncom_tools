function write_ovgrd(opath,nest,vgrd)
%       PURPOSE
%	        Writes contents of ovgrd_[nest].D file
%       CALL
%               write_ovgrd(opath,nest,vgrd)
%       INPUT
%               opath,nest = path,nest
%               vgrd.l  : number of layers + 1
%               vgrd.ls : number of sigma layers + 1
%               vgrd.zw : layer depths
%       OUTPUT
%               none
%       USES
%               write_ovgrd(opath,1,vgrd1);
%       HISTORY
%               Version 1       T. Campbell 01/12/09
%               Version 2       M. Solano   06/08/18
%-----------------------------
zero=0.0;
one=1.0;
zp5=0.5;

% File
fname=[opath '/ovgrd_' num2str(nest) '.D'];
fid=fopen(fname,'w','ieee-be');
nbyte=8+4*size(vgrd.zw,1);
fwrite(fid,nbyte,'int32');

l=vgrd.l; ls=vgrd.ls;

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




% % Compute zm,sw,sm
% vgrd.zm=zeros(vgrd.l-1,1); 
% vgrd.sm=zeros(vgrd.l-1,1); 
% vgrd.dzw=zeros(vgrd.l,1); 
% vgrd.dzm=zeros(vgrd.l-1,1); 
% vgrd.dsw=zeros(vgrd.l,1); 
% vgrd.dsm=zeros(vgrd.l-1,1); 
% for i=1:vgrd.l-1
%     vgrd.zm(i)=(vgrd.zw(i)+vgrd.zw(i+1))/2;
% end
% 
% vgrd.sw=vgrd.zw/abs(min(vgrd.zw)); 
% vgrd.sm=vgrd.zm/abs(min(vgrd.zm)); 
% 
% % Compute gradients(dzw,dzm,dsw,dsm)
% vgrd.dzw=gradient(abs(vgrd.zw)); 
% vgrd.dzm=gradient(abs(vgrd.zm)); 
% vgrd.dsw=gradient(abs(vgrd.sw)); 
% vgrd.dsm=gradient(abs(vgrd.zm)); 

% Write 
vgrd.l=fwrite(fid,single(vgrd.l),'float32');
vgrd.ls=fwrite(fid,single(vgrd.ls),'float32');
vgrd.zw=fwrite(fid,vgrd.zw,'float32');
vgrd.zm=fwrite(fid,vgrd.zm,'float32');
vgrd.sw=fwrite(fid,vgrd.sw,'float32');
vgrd.sm=fwrite(fid,vgrd.sm,'float32');
vgrd.dzw=fwrite(fid,vgrd.dzw,'float32');
vgrd.dzm=fwrite(fid,vgrd.dzm,'float32');
vgrd.dsw=fwrite(fid,vgrd.dsw,'float32');
vgrd.dsm=fwrite(fid,vgrd.dsm,'float32');
fwrite(fid,nbyte,'int32');
fclose(fid);

