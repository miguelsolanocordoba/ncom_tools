function write_osflx(opath,nest,meta,data)
%       PURPOSE
%               Writes metadata to osflx_[nest].B file and fields to
%               osflx_[nest].A file
%       CALL
%               write_osflx(opath,nest,meta,data)
%       INPUT
%               opath,nest = path,nest
%               meta{1:ndtg}.dtg    = YYYYMMDD
%               meta{1:ndtg}.time   = HHMMSSCC
%               meta{1:ndtg}.indatp = flag for surface atmospheric pressure
%               meta{1:ndtg}.indtau = flag for surface wind stress
%               meta{1:ndtg}.indsft = flag for surface heat flux
%               meta{1:ndtg}.indsfs = flag for surface salinity flux
%               meta{1:ndtg}.indsol = flag for solar radiation
%               data{1:ndtg}.patm  = surface atmospheric pressure (m)
%               data{1:ndtg}.usflx = x-component of surface wind stress (m2/s2)
%               data{1:ndtg}.vsflx = y-component of surface wind stress (m2/s2)
%               data{1:ndtg}.hsflx = surface heat flux (indsft=5: IR flux)
%               data{1:ndtg}.tair  = air temperature in degC
%               data{1:ndtg}.vapmx = water vapor mixing ratio in kg/kg
%               data{1:ndtg}.ssflx = surface moisture flux (indsfs=5: negative of total precip)
%               data{1:ndtg}.solar = solar radiation, cloud cover, or related field
%       OUTPUT
%               none
%       USES
%               write_osflx(opath,1,meta1,data1);
%       HISTORY
%               Version 1       T. Campbell 01/13/09
%-----------------------------

ndtg=size(meta,2);
if (meta{1}.indatp==1)
  dimy=size(data{1}.patm,1);
  dimx=size(data{1}.patm,2);
elseif (meta{1}.indtau==1)
  dimy=size(data{1}.usflx,1);
  dimx=size(data{1}.usflx,2);
elseif (meta{1}.indsft==1 || meta{1}.indsft==5)
  dimy=size(data{1}.hsflx,1);
  dimx=size(data{1}.hsflx,2);
elseif (meta{1}.indsfs==1 || meta{1}.indsfs==5)
  dimy=size(data{1}.ssflx,1);
  dimx=size(data{1}.ssflx,2);
elseif (meta{1}.indsol==1)
  dimy=size(data{1}.solar,1);
  dimx=size(data{1}.solar,2);
else
  error('write_osflx: no fields set in metadata');
end
r=2;
n2d=dimx*dimy;          shape2d=[n2d 1]; order2d=[2 1];

% write metadata
fname=[opath '/osflx_' num2str(nest) '.B'];
fid=fopen(fname,'w');
for idtg=1:ndtg
  fprintf(fid,'  %8d   %8d  %d  %d  %d  %d  %d  %d  %d  %d  %d\n',...
  meta{idtg}.dtg, meta{idtg}.time, nest, dimx, dimy, r,...
  meta{idtg}.indatp, meta{idtg}.indtau,...
  meta{idtg}.indsft, meta{idtg}.indsfs, meta{idtg}.indsol);
end
fclose(fid);

% write data
fname=[opath '/osflx_' num2str(nest) '.A'];
fid=fopen(fname,'w','ieee-be');
for idtg=1:ndtg
  % surface atmospheric pressure
  if (meta{idtg}.indatp==1)
    fwrite(fid,reshape(permute(data{idtg}.patm,order2d),shape2d),'float32');
  end
  % surface wind stress
  if (meta{idtg}.indtau==1)
    fwrite(fid,reshape(permute(data{idtg}.usflx,order2d),shape2d),'float32');
    fwrite(fid,reshape(permute(data{idtg}.vsflx,order2d),shape2d),'float32');
  end
  % surface heat flux
  if (meta{idtg}.indsft==1 || meta{idtg}.indsft==5)
    fwrite(fid,reshape(permute(data{idtg}.hsflx,order2d),shape2d),'float32');
  end
  if (meta{idtg}.indsft==5)
    fwrite(fid,reshape(permute(data{idtg}.tair ,order2d),shape2d),'float32');
    fwrite(fid,reshape(permute(data{idtg}.vapmx,order2d),shape2d),'float32');
  end
  % surface salinity flux
  if (meta{idtg}.indsfs==1 || meta{idtg}.indsfs==5)
    fwrite(fid,reshape(permute(data{idtg}.ssflx,order2d),shape2d),'float32');
  end
  % solar radiation
  if (meta{idtg}.indsol==1)
    fwrite(fid,reshape(permute(data{idtg}.solar,order2d),shape2d),'float32');
  end
end
fclose(fid);

