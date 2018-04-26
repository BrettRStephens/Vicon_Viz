close all;clear;clc

%% Extract data
bag = rosbag('slammmmm.bag');
odom = select(bag,'Topic','/odom');
vicon = select(bag,'Topic','/vicon/slam/slam');
odomStruct = readMessages(odom);
viconStruct = readMessages(vicon);

xVs = [];
yVs = [];
zVs = [];
xOs = [];
yOs = [];
zOs = [];

for i = 1:length(viconStruct)
    xV = viconStruct{i, 1}.Transform.Translation.X;
    yV = viconStruct{i, 1}.Transform.Translation.Y;
    zV = viconStruct{i, 1}.Transform.Translation.Z;
    
    xVs = [xVs;xV];
    yVs = [yVs;yV];
    zVs = [zVs;zV];
    
end

for i = 1:length(odomStruct)
    xO = odomStruct{i, 1}.Pose.Pose.Position.X;
    yO = odomStruct{i, 1}.Pose.Pose.Position.Y;
    zO = odomStruct{i, 1}.Pose.Pose.Position.Z;
    
    xOs = [xOs;xO];
    yOs = [yOs;yO];
    zOs = [zOs;zO];
    
end

%% Plot data

%figure();plot3(xVs,yVs,zVs);title('Vicon');
%figure();plot3(xOs,yOs,zOs);title('Odom');

%set starting point to the same point for each data source

xOs_offset = offset(xVs,xOs);
yOs_offset = offset(yVs,yOs);
zOs_offset = offset(zVs,zOs);


figure();plot3(xVs,yVs,zVs);hold on;
plot3(xOs_offset,yOs_offset,zOs_offset);legend('Vicon','Odom');




    