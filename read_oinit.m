function data=read_oinit(opath,nest)
%       PURPOSE
%	        Reads contents of oinit_[nest].A file
%       CALL
%               data=read_oinit(opath,nest)
%       INPUT
%               opath,nest = path and nest number
%       OUTPUT
%               data.e data.u data.v data.t data.s - oinitfile contents
%       USES

%       HISTORY
%               Version 1       S. Gabersek 09/29/08
%-----------------------------

fname=[opath '/oinit_' num2str(nest) '.B'];
fid=fopen(fname);
A=fscanf(fid,'%d %d %d %d');
dimx=A(1);
dimy=A(2);
dimz=A(3); % number of levels
ns=A(4); % number of sigma levels
clear A
fclose(fid);

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];
n3d=dimx*dimy*(dimz-1); shape3d=[dimx dimy dimz-1]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     shape3f=[dimx dimy dimz];   order3f=[2 1 3];

fname=[opath '/oinit_' num2str(nest) '.A'];
fid=fopen(fname,'r','ieee-be');

% free surface elevation (2D)
data.e=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
% u,v (3D, dimz)
data.u=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
data.v=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
% t,s (3D, dimz)
data.t=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
data.s=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);

fclose(fid);

