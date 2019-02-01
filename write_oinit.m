function write_oinit(opath,nest,vgrd,data)
%       PURPOSE
%	        Writes contents of oinit_[nest].A & oinit_[nest].B files
%       CALL
%               write_oinit(opath,nest,data)
%       INPUT
%               opath,nest = path and nest number
%               vgrd = vertical grid data structure
%               data.e data.u data.v data.t data.s - oinitfile contents
%       OUTPUT
%               none
%       USES
%               write_oinit(opath,1,vgrd1,data1);
%       HISTORY
%               Version 1       T. Campbell 01/12/09
%-----------------------------

dimy=size(data.e,1);
dimx=size(data.e,2);
dimz=vgrd.l;
ns=vgrd.ls;

n2d=dimx*dimy;          shape2d=[n2d 1]; order2d=[2 1];
n3d=dimx*dimy*(dimz-1); shape3d=[n3d 1]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     %shape3f=[dimx dimy dimz];   order3f=[2 1 3];

fname=[opath '/oinit_' num2str(nest) '.B'];
fid=fopen(fname,'w');
fprintf(fid,'%d %d %d %d\n',dimx,dimy,dimz,ns);
fclose(fid);

fname=[opath '/oinit_' num2str(nest) '.A'];
fid=fopen(fname,'w','ieee-be');

% free surface elevation (2D)
fwrite(fid,reshape(permute(data.e,order2d),shape2d),'float32');
% u,v (3D, dimz-1)
fwrite(fid,reshape(permute(data.u,order3d),shape3d),'float32');
fwrite(fid,reshape(permute(data.v,order3d),shape3d),'float32');
% t,s (3D, dimz-1)
fwrite(fid,reshape(permute(data.t,order3d),shape3d),'float32');
fwrite(fid,reshape(permute(data.s,order3d),shape3d),'float32');

fclose(fid);

