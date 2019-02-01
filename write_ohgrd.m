function write_ohgrd(opath,nest,hgrd)
%       PURPOSE
%	        Writes contents of ohgrd_[nest].A & ohgrd_[nest].B files
%       CALL
%               write_ohgrd(opath,nest,hgrd)
%       INPUT
%               opath,nest = path,nest
%               hgrd.lon, hgrd.lat : longitude & latitude
%               hgrd.dx, hgrd.dy   : spacing
%               hgrd.h             : depth
%               hgrd.ang           : rotation angle
%       OUTPUT
%               none
%       USES
%               write_ohgrd(opath,1,hgrd1);
%       HISTORY
%               Version 1       T. Campbell 01/12/09
%-----------------------------

dimy=size(hgrd.h,1);
dimx=size(hgrd.h,2);

n2d=dimx*dimy;          shape2d=[n2d 1]; order2d=[2 1];

fname=[opath '/ohgrd_' num2str(nest) '.B'];
fid=fopen(fname,'w');
fprintf(fid,'%d %d %d %d %d %d\n',dimx,dimy,0,0,0,0);
fclose(fid);

fname=[opath '/ohgrd_' num2str(nest) '.A'];
fid=fopen(fname,'w','ieee-be');

fwrite(fid,reshape(permute(hgrd.lon,order2d),shape2d),'float32');
fwrite(fid,reshape(permute(hgrd.lat,order2d),shape2d),'float32');
fwrite(fid,reshape(permute(hgrd.dx ,order2d),shape2d),'float32');
fwrite(fid,reshape(permute(hgrd.dy ,order2d),shape2d),'float32');
fwrite(fid,reshape(permute(hgrd.h  ,order2d),shape2d),'float32');
fwrite(fid,reshape(permute(hgrd.ang,order2d),shape2d),'float32');

fclose(fid);

