close all;
clear;
clc;

%% bring in data from csv file
vicon_str = '/Users/BrettStephens/Documents/MATLAB/Vicon_Viz/23042018_data/rs02.csv';
odom_str = '/Users/BrettStephens/Documents/MATLAB/Vicon_Viz/23042018_data/vertices2.csv';

vicon = readtable(vicon_str);
odom = readtable(odom_str);
%time data
vicon_t = table2array(vicon(:,1));
odom_t = table2array(odom(:,2));

n = length(odom_t);
%position data
vicon_pos = table2array(vicon(:,6:8));
odom_pos = table2array(odom(:,3:5));

%% edit the data
%split out odom data
odom_pos_x = odom_pos(:,1);
odom_pos_y = odom_pos(:,2);
odom_pos_z = odom_pos(:,3);

%downsample vicon data
vicon_ds_x = resample(vicon_pos(:,1),n,length(vicon_t));   
vicon_ds_y = resample(vicon_pos(:,2),n,length(vicon_t));   
vicon_ds_z = resample(vicon_pos(:,3),n,length(vicon_t)); 

%clip noisy endpoints 
clip = 10;
vicon_ds_x_clip = vicon_ds_x(clip:end-clip);
vicon_ds_y_clip = vicon_ds_y(clip:end-clip);
vicon_ds_z_clip = vicon_ds_z(clip:end-clip);
odom_x_clip = odom_pos_x(clip:end-clip);
odom_y_clip = odom_pos_y(clip:end-clip);
odom_z_clip = odom_pos_z(clip:end-clip);


% figure();title('clipped and downsampled vicon');
% plot3(vicon_ds_x_clip, vicon_ds_y_clip, vicon_ds_z_clip);hold on;
% plot3(odom_x_clip, odom_y_clip, odom_z_clip);

%make vicon data start at the origin (0,0,0)
vicon_x = vicon_ds_x_clip - vicon_ds_x_clip(1);
vicon_y = vicon_ds_y_clip - vicon_ds_y_clip(1);
vicon_z = vicon_ds_z_clip - vicon_ds_z_clip(1);

%make odom start at same point as vicon
odom_x = offset(vicon_x,odom_x_clip);
odom_y = offset(vicon_y,odom_y_clip);
odom_z = offset(vicon_z,odom_z_clip);

%% plot
figure();
plot3(vicon_x, vicon_y, vicon_z);hold on;plot3(odom_x, odom_y, odom_z);
title('clipped, downsampled and snapped to origin');

figure();
plot(vicon_x, vicon_y);hold on;plot(odom_x, odom_y);
title('clipped, downsampled and snapped to origin (x,y)');

% %% sample frequency calc
% for i = 2:length(odom_t)
%     odom_delta_t(i-1) = odom_t(i) - odom_t(i-1);
% end
% for i = 2:length(vicon_t)
%     vicon_delta_t(i-1) = vicon_t(i) - vicon_t(i-1);
% end
% 
% %avg time in s
% odom_delta_t_avg = mean(odom_delta_t)*(1e-9);
% vicon_deta_t_avg = mean(vicon_delta_t)*(1e-9);
% odom_freq = 1/odom_delta_t_avg;
% vicon_freq = 1/vicon_deta_t_avg;

%% RMSE
rmse_x = sqrt((sum((odom_x-vicon_x).^2))/n);
rmse_y = sqrt((sum((odom_y-vicon_y).^2))/n);
rmse_z = sqrt((sum((odom_z-vicon_z).^2))/n);

