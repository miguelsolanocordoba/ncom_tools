function write_owave(opath,nest,meta,data,depth)
%       PURPOSE
%               Writes depths to ozwav_1.D file metadata to owave_[nest].B 
%               file and fields to owave_[nest].A file
%       CALL
%               write_owave(opath,nest,meta,data)
%       INPUT
%               opath,nest = path,nest
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
%               depth = depths at which wave forcing is written (m)
%       OUTPUT
%               none
%       USES
%               write_owave(opath,1,meta1,data1);
%       HISTORY
%               Version 1       M. Solano 5/4/2018
%-----------------------------

ndtg=size(meta,2);
if (meta{1}.indus==1)
  dimx=size(data{1}.us,1);
  dimy=size(data{1}.us,2);
  dimz=size(data{1}.us,3);
elseif (meta{1}.indwb==1)
  dimx=size(data{1}.wbc,1);
  dimy=size(data{1}.wbc,2);
elseif (meta{1}.indsx==1)
  dimx=size(data{1}.sxx,1);
  dimy=size(data{1}.sxx,2);
else
  error('write_owave: no fields set in metadata');
end
r=0;
n3d=dimx*dimy*dimz;     shape3d=[n3d 1];   order3d=[2 1 3];

% write depths
fname=[opath '/ozwav_' num2str(nest) '.D'];
fid=fopen(fname,'w');
fprintf(fid,'    %d',numel(depth));
for i=1:numel(depth)
    fprintf(fid,'\n     %4.4f',depth(i));
end
fclose(fid);

% write metadata
fname=[opath '/owave_' num2str(nest) '.B'];
fid=fopen(fname,'w');
for idtg=1:ndtg
  fprintf(fid,'  %8d   %8d  %d  %d  %d  %d  %d  %d  %d  %d\n',...
  meta{idtg}.dtg, meta{idtg}.time, nest, dimx, dimy, dimz,...
  meta{idtg}.indus, meta{idtg}.indwb, meta{idtg}.indsx,r);
end
fclose(fid);

% write data
fname=[opath '/owave_' num2str(nest) '.A'];
fid=fopen(fname,'w','ieee-be');
for idtg=1:ndtg
    % stokes drift current
    if (meta{idtg}.indus==1)
      fwrite(fid,reshape(permute(data{idtg}.us,order3d),shape3d),'float32');
      fwrite(fid,reshape(permute(data{idtg}.vs,order3d),shape3d),'float32');
    end
    % wave bottom current
    if (meta{idtg}.indwb==1)
      fwrite(fid,reshape(permute(data{idtg}.wbc,order3d),shape3d),'float32');
      fwrite(fid,reshape(permute(data{idtg}.wbf,order3d),shape3d),'float32');
      fwrite(fid,reshape(permute(data{idtg}.wbd,order3d),shape3d),'float32');
    end
    % wave radiation stress
    if (meta{idtg}.indsx==1)
      fwrite(fid,reshape(permute(data{idtg}.sxx,order3d),shape3d),'float32');
      fwrite(fid,reshape(permute(data{idtg}.sxy,order3d),shape3d),'float32');
      fwrite(fid,reshape(permute(data{idtg}.syy,order3d),shape3d),'float32');
    end
end
fclose(fid);

% EOF