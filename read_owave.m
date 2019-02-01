function [meta,data,depth]=read_owave(opath,nest,ndtg)
%       PURPOSE
%               Reads metadata of owave_[nest].B file and fields of
%               owave_[nest].A file
%       CALL
%               [meta data]=read_owave(opath,nest,[ndtg])
%       INPUT
%               opath,nest = path,nest
%               ndtg = number of dtg indices to read
%       OUTPUT
%               meta{1:ndtg}.dtg    = YYYYMMDD
%               meta{1:ndtg}.time   = HHMMSSCC
%               meta{1:ndtg}.indus = flag for stokes drift current
%               meta{1:ndtg}.indwb = flag for wave bottom current
%               meta{1:ndtg}.indsx = flag for wave radiation stress
%               data{1:ndtg}.us = x-component of stokes drift current (m/s)
%               data{1:ndtg}.vs = x-component of stokes drift current (m/s)
%               data{1:ndtg}.wbc = magnitude of wave bottom current (m/s)
%               data{1:ndtg}.wbf = frequency of wave bottom current (rad/s)
%               data{1:ndtg}.wbd = direction of wave bottom current (rad)
%               data{1:ndtg}.sxx = xx-component of wave radiation stress (m3/s2)
%               data{1:ndtg}.sxy = xy-component of wave radiation stress (m3/s2)
%               data{1:ndtg}.syy = yy-component of wave radiation stress (m3/s2)
%               depth = depths of SDC. 
%       USES
%               [meta1 data1]=read_owave(opath,1);
%       HISTORY
%               Version 1       T. Campbell 09/02/09
%-----------------------------

% extract metadata
fname=[opath '/owave_' num2str(nest) '.B'];
fid=fopen(fname,'r');
A=fscanf(fid,'%d %d %d %d %d %d %d %d %d %d',[10 inf]);
fclose(fid);

ndtg_max=size(A,2);
dimx=A(4,1);
dimy=A(5,1);
dimz=A(6,1);
if exist('ndtg')~=0
  if ndtg > ndtg_max
    error(['requested ndtg is too large: ',num2str(ndtg,'%6i'),num2str(ndtg_max,'%6i')]);
  end
else
  ndtg = ndtg_max;
end
for idtg=1:ndtg
  meta{idtg}.dtg=A(1,idtg);
  meta{idtg}.time=A(2,idtg);
  meta{idtg}.indus=A(7,idtg);
  meta{idtg}.indwb=A(8,idtg);
  meta{idtg}.indsx=A(9,idtg);
end

clear A

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];
n3d=dimx*dimy*(dimz); shape3d=[dimx dimy dimz]; order3d=[2 1 3];
n3f=dimx*dimy*dimz;     shape3f=[dimx dimy dimz];   order3f=[2 1 3];

% extract data
fname=[opath '/owave_' num2str(nest) '.A'];
fid=fopen(fname,'r','ieee-be');

data=cell(1,ndtg); 
for idtg=1:ndtg
    % stokes drift current (3D, dimz-1)
    if (meta{idtg}.indus==1)
      data{idtg}.us=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
      data{idtg}.vs=permute(reshape(fread(fid,n3d,'float32'),shape3d),order3d);
    end
    % wave bottom current
    if (meta{idtg}.indwb==1)
        data{idtg}.wbc=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
        data{idtg}.wbf=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
        data{idtg}.wbd=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
    end
    % wave radiation stress
    if (meta{idtg}.indsx==1)
        data{idtg}.sxx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
        data{idtg}.sxy=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
        data{idtg}.syy=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
    end
end

fclose(fid);

fname=[opath '/ozwav_' num2str(nest) '.D'];
A=load(fname); 
depth=A(2:end); 
