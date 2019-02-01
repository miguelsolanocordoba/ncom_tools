function [meta, data]=read_osflx(opath,nest)
%       PURPOSE
%               Reads metadata of osflx_[nest].B file and fields of
%               osflx_[nest].A file
%       CALL
%               [meta data]=read_osflx(opath,nest)
%       INPUT
%               opath,nest = path,nest
%       OUTPUT
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
%       USES
%               [meta1 data1]=read_osflx(opath,1);
%       HISTORY
%               Version 1       T. Campbell 01/13/09
%-----------------------------

% extract metadata
fname=[opath '/osflx_' num2str(nest) '.B'];
fid=fopen(fname,'r');
A=fscanf(fid,'%d %d %d %d %d %d %d %d %d %d %d',[11 inf]);
fclose(fid);
ndtg=size(A,2);
dimx=A(4,1);
dimy=A(5,1);
for idtg=1:ndtg
  meta{idtg}.dtg=A(1,idtg);
  meta{idtg}.time=A(2,idtg);
  meta{idtg}.indatp=A(7,idtg);
  meta{idtg}.indtau=A(8,idtg);
  meta{idtg}.indsft=A(9,idtg);
  meta{idtg}.indsfs=A(10,idtg);
  meta{idtg}.indsol=A(11,idtg);
end
clear A

n2d=dimx*dimy;          shape2d=[dimx dimy];        order2d=[2 1];

% extract data
fname=[opath '/osflx_' num2str(nest) '.A'];
fid=fopen(fname,'r','ieee-be');

data=cell(1,ndtg); 
for idtg=1:ndtg
  % surface atmospheric pressure
  if (meta{idtg}.indatp==1)
    data{idtg}.patm=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
  % surface wind stress
  if (meta{idtg}.indtau==1)
    data{idtg}.usflx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
    data{idtg}.vsflx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
  % surface heat flux
  if (meta{idtg}.indsft==1 || meta{idtg}.indsft==5)
    data{idtg}.hsflx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
  if (meta{idtg}.indsft==5)
    data{idtg}.tair=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
    data{idtg}.vapmx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
  % surface salinity flux
  if (meta{idtg}.indsfs==1 || meta{idtg}.indsfs==5)
    data{idtg}.ssflx=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
  % solar radiation
  if (meta{idtg}.indsol==1)
    data{idtg}.solar=permute(reshape(fread(fid,n2d,'float32'),shape2d),order2d);
  end
end

fclose(fid);

