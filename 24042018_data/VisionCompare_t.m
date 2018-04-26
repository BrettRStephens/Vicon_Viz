close all;
clear;
clc;

%% bring in data from csv file
vicon_str = '/Users/BrettStephens/Documents/MATLAB/Vicon_Viz/24042018_data/vicon02.csv';
odom_str = '/Users/BrettStephens/Documents/MATLAB/Vicon_Viz/24042018_data/vertices.csv';

vicon = readtable(vicon_str);
odom = readtable(odom_str);
%time data
vicon_t = table2array(vicon(:,1))*1e-9; %time in [s]
odom_t = table2array(odom(:,2))*1e-9; %time in [s]

%bring in position data
vicon_pos = table2array(vicon(:,6:8));
odom_pos = table2array(odom(:,3:5));

%bring in rotation (quaternion) data
vicon_quat = table2array(vicon(:,9:12));
odom_quat = table2array(odom(:,6:9));

%convert to euler
vicon_ZYX = quat2eul(vicon_quat);
odom_ZYX = quat2eul(odom_quat);

%split out odom position data
odom_pos_x = odom_pos(:,1);
odom_pos_y = odom_pos(:,2);
odom_pos_z = odom_pos(:,3); 

%split out the vicon position data
vicon_pos_x = vicon_pos(:,1);
vicon_pos_y = vicon_pos(:,2);
vicon_pos_z = vicon_pos(:,3);

%sanity check: raw data
figure();
plot3(vicon_pos_x, vicon_pos_y, vicon_pos_z);hold on;
plot3(odom_pos_x, odom_pos_y, odom_pos_z);
title('raw data');

%time align data
%set first time stamp from data source that started first to 0
if vicon_t(1) < odom_t(1) %ie vicon started to collect data first
    t_offset = vicon_t(1);
    vicon_t = vicon_t - t_offset;
    odom_t = odom_t - t_offset;
else t_offset = odom_t(1);
    odom_t = odom_t - t_offset;
    vicon_t = vicon_t - t_offset;
end

%linearly interpolate vicon position (downsample to size of odom position)
vicon_x_ds = interp1(vicon_t, vicon_pos_x, odom_t);
vicon_y_ds = interp1(vicon_t, vicon_pos_y, odom_t);
vicon_z_ds = interp1(vicon_t, vicon_pos_z, odom_t);

%linearly interpolate vicon rotation
vicon_eul_z = interp1(vicon_t, vicon_ZYX(:,1), odom_t);
vicon_eul_y = interp1(vicon_t, vicon_ZYX(:,2), odom_t);  
vicon_eul_x = interp1(vicon_t, vicon_ZYX(:,3), odom_t);

vicon_ZYX_ds = [vicon_eul_z,vicon_eul_y,vicon_eul_x];

% %clip noisy start/end 
% clip_st = 100;
% clip_end = 5;
% vicon_x_clip = vicon_x_ds(clip_st:end-clip_end);
% vicon_y_clip = vicon_y_ds(clip_st:end-clip_end);
% vicon_z_clip = vicon_z_ds(clip_st:end-clip_end);
% odom_x_clip = odom_pos_x(clip_st:end-clip_end);
% odom_y_clip = odom_pos_y(clip_st:end-clip_end);
% odom_z_clip = odom_pos_z(clip_st:end-clip_end);

% %sanity check: plot clipped data
% figure()
% plot3(vicon_x_clip,vicon_y_clip,vicon_z_clip);hold on;
% plot3(odom_x_clip, odom_y_clip, odom_z_clip);
% title('clipped data');

odom_rots = [];
for i = 1:length(vicon_ZYX_ds)
    R_rv = eul2rotm(vicon_ZYX_ds(i,:));
    R_rc = eul2rotm(odom_ZYX(i,:));
    R_cv = R_rc\R_rv;
    odom_rot = R_cv\[odom_pos_x(i);odom_pos_y(i);odom_pos_z(i)];
    odom_rots = [odom_rots;odom_rot'];
end
    
% odom_rots = [];
% for i = 1:length(odom_pos_x)
%     rotm = eul2rotm(eul_diff_ZYX(i,:));
%     odom_rot = rotm*[odom_pos_x(i);odom_pos_y(i);odom_pos_z(i)];
%     odom_rots = [odom_rots;odom_rot'];
% end

%sanity check: plot time aligned data
figure();
plot3(vicon_x_ds, vicon_y_ds, vicon_z_ds);hold on;
plot3(odom_rots(:,1), odom_rots(:,2), odom_rots(:,3));
title('time aligned data');

%translation alignment 
%make vicon data start at the origin (0,0,0)
vicon_x = vicon_x_clip - vicon_x_clip(1);
vicon_y = vicon_y_clip - vicon_y_clip(1);
vicon_z = vicon_z_clip - vicon_z_clip(1);

%make odom start at same point as vicon
odom_x = offset(vicon_x,odom_x_clip);
odom_y = offset(vicon_y,odom_y_clip);
odom_z = offset(vicon_z,odom_z_clip);

%rotation alignment



n = length(odom_x); %problem length

%% plot
figure();
plot3(vicon_x, vicon_y, vicon_z);hold on;plot3(odom_x, odom_y, odom_z);
title('time and position aligned data');

%% RMSE
rmse_x = sqrt((sum((odom_x-vicon_x).^2))/n);
rmse_y = sqrt((sum((odom_y-vicon_y).^2))/n);
rmse_z = sqrt((sum((odom_z-vicon_z).^2))/n);

