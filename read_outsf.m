function data=read_outsf(opath,nest,datev)
%       PURPOSE
%	        Reads contents of outsf_[nest]_yyyymmdd_HHMMSS00.A file
%       CALL
%               data=read_outsf(opath,nest,datev)
%       INPUT
%               opath,nest,datev = path,nest,[yyyy,mm,dd,HH,MM,SS]
%       OUTPUT
%               data.e data.ub data.vb : elevation, depth-averaged velocity x depth
%               data.u data.v data.t data.s : surface u,v,t,s
%               data.ust data.vst : surface windstress
%       USES
%               datasf=read_outsf(opath,1,[2008,10,10,00,03,00]);
%       HISTORY
%               Version 1       S. Gabersek 12/30/08
%-----------------------------

fname=[opath '/outsf_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.B'];
fid=fopen(fname);
A=fscanf(fid,'%d %d %d %d %d %d %d %d %d %d %d %d %d');
dimx=A(4);
dimy=A(5);
inde=A(6);
indvb=A(7);
indv=A(8);
indt=A(9);
inds=A(10);
indst=A(11);
clear A
fclose(fid);

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];

fname=[opath '/outsf_' num2str(nest) '_' datestr(datev,'yyyymmdd_HHMMSS') '00.A'];
fid=fopen(fname,'r','ieee-be');

if (inde==1)
  data.e=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
if (indvb==1)
  data.ub=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.vb=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
if (indv==1)
  data.u=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.v=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
if (indt==1)
  data.t=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
if (inds==1)
  data.s=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end
if (indst==1)
  data.ust=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  data.vst=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
end

fclose(fid);

