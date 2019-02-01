clear; close all; clc
%% ALIGN_SDC2WND Aligns Stokes Drift Current to wind direction. 
% ALIGN_SDC2WND reads NCOM input wave forcing and surface forcing files and
% aligns the stokes drift direction to the wind direction, with the same
% original magnitude of the SDC. 
%
% Created May 3, 2018 by M. Solano

% PATHS 
addpath C:\Users\msolano\Documents\MATLAB\ncom_toolbox

% Input path 
ipath='\\rowe\export\home\msolano\model_ncom\run_lcp\input';
nest=1;
N=50; 

% Dates
days=13; 
date1=datenum('20151024','yyyymmdd'); 
date2=addtodate(date1,days,'day'); 

% Plotting options
pltpoint=1;
NameArray = {'LineWidth'};
ValueArray = {1}';

%% Surface Forcing 
[mosflx, osflx]=read_osflx(ipath,nest);

% Read variables
nt=numel(osflx); 
date=zeros(1,nt); 
for i=1:nt
    time=mod(i-1,24);
    date(i)=addtodate(datenum(num2str(mosflx{i}.dtg),'yyyymmdd'),time,'hour');
end

[~,ind1]=min(abs(date-date1)); 
[~,ind2]=min(abs(date-date2)); 
sdate=date(ind1:ind2); clear date
nt=numel(sdate); 

tx=zeros(nt,1);  
ty=zeros(nt,1); 

for i=1:nt 
    tx(i)=osflx{ind1+i-1}.usflx(pltpoint);
    ty(i)=osflx{ind1+i-1}.vsflx(pltpoint); 
end

tau=sqrt(tx.^2 + ty.^2); 

%% Wave forcing
[mowave, owave]=read_owave(ipath,nest);

% New data same as old data (us/vs need to be overwritten after alignment)
meta=mowave; 
data=owave;

% Read variables
nt=numel(owave); 
date=zeros(1,nt); 
for i=1:nt
    tstr=sprintf('%8.0f',mowave{i}.time);
    hour=str2num(tstr(1:2)); 
    minute=str2num(tstr(3:4)); 
    if isempty(hour)
        hour=0;
        if isempty(minute)
            minute=0; 
        end
    end
    time=hour*60+minute; 
    date(i)=addtodate(datenum(num2str(mowave{i}.dtg),'yyyymmdd'),time,'minute');
end

% [~ ,ind1]=min(abs(date-date1)); 
% [~,ind2]=min(abs(date-date2)); 
% wdate=date(ind1:ind2); clear date
% nt=numel(wdate);
wdate=date; 

us=zeros(nt,N); 
vs=zeros(nt,N); 
sdc=zeros(nt,N); 
for i=1:nt
%     us(i,:)=squeeze(owave{ind1+i-1}.us(1,1,:)); 
%     vs(i,:)=squeeze(owave{ind1+i-1}.vs(1,1,:)); 
    us(i,:)=squeeze(owave{i}.us(1,1,:)); 
    vs(i,:)=squeeze(owave{i}.vs(1,1,:)); 
    sdc(i,:)=sqrt(us(i,:).^2+vs(i,:).^2);
end

%% Align 
% Interpolate wind stress to SDC times 
txn=interp1(sdate,tx,wdate); 
tyn=interp1(sdate,ty,wdate); 
taun=sqrt(txn.^2 + tyn.^2); 

rx=txn./taun; 
ry=tyn./taun;

usn=zeros(size(us)); 
vsn=zeros(size(vs)); 
for i=1:N
    usn(:,i)=rx'.*sdc(:,i); 
    vsn(:,i)=ry'.*sdc(:,i); 
end

% Change NaN to 0's 
usn(isnan(usn))=0; 
vsn(isnan(vsn))=0; 

for i=1:nt
    for j=1:2
        for k=1:2
            data{i}.us(j,k,:)=usn(i,:);
            data{i}.vs(j,k,:)=vsn(i,:);
        end
    end
end

% Compute angle between wind and wave
mags=sqrt(us(:,1).^2+vs(:,1).^2); 
magsn=sqrt(usn(:,1).^2+vsn(:,1).^2); 

theta=acosd((us(:,1).*usn(:,1)+vs(:,1).*vsn(:,1))./(mags.*magsn));

%% Plots 

% Plot wind stress with wave forcing 
fh=figure; 
quiver(sdate,zeros(size(sdate)),tx',ty');

pbaspect([5 1 1])
xlim([sdate(1) sdate(end)])
ax=gca; 
ax.XTick=linspace(sdate(1),sdate(end),7);
ax.YTick=([-1 -0.5 0 0.5 1]) ;
datetick('x','mmm-dd','keepticks','keeplimits')
title('Surface Wind Stress')
%ylabel('Stress [N/m^2]')
print('-dpng','-r325','tau_dir.png')


fh=figure; 
quiver(wdate(1:2:end),zeros(size(wdate(1:2:end))),us(1:2:end,1)',vs(1:2:end,1)');

pbaspect([5 1 1])
xlim([sdate(1) sdate(end)])
ax=gca; 
ax.XTick=linspace(sdate(1),sdate(end),7);
ax.YTick=([-1 -0.5 0 0.5 1]);
datetick('x','mmm-dd','keepticks','keeplimits')
title('Surface Stokes Drift Velocity (before)')
%ylabel('Velocity [m/s]')
print('-dpng','-r325','sdc_dir.png')


fh=figure; 
quiver(wdate(1:2:end),zeros(size(wdate(1:2:end))),usn(1:2:end,1)',vsn(1:2:end,1)');

pbaspect([5 1 1])
xlim([sdate(1) sdate(end)])
ax=gca; 
ax.XTick=linspace(sdate(1),sdate(end),7);
ax.YTick=([-1 -0.5 0 0.5 1]);
datetick('x','mmm-dd','keepticks','keeplimits')
title('Surface Stokes Drift Velocity (after)')
%ylabel('Velocity [m/s]')
print('-dpng','-r325','sdcn_dir.png')

return
%% Write new wave forcing file (with aligned winds) 
write_owave(ipath,nest,meta,data)