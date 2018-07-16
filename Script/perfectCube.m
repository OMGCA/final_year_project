addpath('Z:\Project Demo\CubeArrangedData');
datasheet = 'perfectCube1.xlsx';
perfectCube1 = xlsread(datasheet);

SDSampleRate = 20;
SampleRate = 5;

% Record x y axis into x y matrix
x = perfectCube1(:,1);
y = perfectCube1(:,2);
% Record pen pressure into z matrix
z = perfectCube1(:,3);
% Create a copy of x y axis to show pen off movement
a = x;
b = y;


angleCounter = zeros(9,1);
% 0~10, 80~90, 30~70(right),-70~-30(left)
angleCounter2 = zeros(4,1);

timeUsed = size(z,1);
timeOn = 0;
timeOff = 0;


% Calculate the velocity in terms of timestamp
velocity = zeros(size(x));
for c = SampleRate+1:size(x)
    velocity(c) = (((x(c)-x(c-SampleRate)).^2+(y(c)-y(c-SampleRate)).^2).^0.5)/10000;
end
velocityCopy = velocity;

% Calculate the gradient in terms of timestamp
gradient = zeros(size(x));
for c = SampleRate+1:size(x)
    gradient(c) = (y(c)-y(c-SampleRate))/(x(c)-x(c-SampleRate));

    if(atan(gradient(c))*180/pi <= 70 && atan(gradient(c))*180/pi >= 30 && z(c) ~= 0)
        if(x(c) >= x(c-SampleRate))
            angleCounter2(3,1) = angleCounter2(3,1) + 1;
        end
    end
    if(atan(gradient(c))*180/pi <= -30 && atan(gradient(c))*180/pi >= -70 && z(c) ~= 0)
        if(x(c) <= x(c-SampleRate))
            angleCounter2(4,1) = angleCounter2(4,1) + 1;
        end
    end
    
end
angleCatagories = [2 3 4 5];
% Convert gradient in angular value
angle = atan(gradient)*180/pi;




% Counting ticks on each angle ranges
for c = 1:size(angle)
    for d = 1:9
        % Only pen ON is counted
        if ( abs(angle(c)) >= d*10-10 && abs(angle(c)) < d*10 && z(c) ~= 0)
            angleCounter(d) = angleCounter(d) + 1;
        end
        
    end
    if ( abs(angle(c)) == 90 )
            angleCounter(9) = angleCounter(9) + 1;
    end
end

angleCopy = angle;
angleCounter2(1,1) = angleCounter(1,1);
angleCounter2(2,1) = angleCounter(9,1);


% Calculate standard deviation of a set of angles
% Number of set is defined by SDSampleRate
angleSD = zeros(floor(size(x,1)/SDSampleRate),1);
counter = 1;
for c = 1:size(angleSD)
    angleSD(c) = std2(angle(counter:counter+SDSampleRate));
    counter = counter + SDSampleRate;
end


% Calculate standard deviation of a set of velocities
% Number of set is defined by SDSampleRate
velocitySD = zeros(floor(size(x,1)/SDSampleRate),1);
counter = 1;
for c = 1:size(velocitySD)
    velocitySD(c) = std2(velocity(counter:counter+SDSampleRate));
    counter = counter + SDSampleRate;
end


% Define pen up and down coordinates
for c = 1:size(x)
   if z(c) == 0
        x(c) = NaN;
        y(c) = NaN;
        velocity(c) = NaN;
        angle(c) = NaN;
        timeOff = timeOff + 1;
   end
   if z(c) ~=0
        a(c) = NaN;
        b(c) = NaN;
        velocityCopy(c) = NaN;
        angleCopy(c) = NaN;
        timeOn = timeOn + 1;
   end
end
timeOnPercent = timeOn/timeUsed;

angleCounter2 = angleCounter2/timeOnPercent/100;

HoriProportion = angleCounter(1)*100/timeOn;
VertProportion = angleCounter(9)*100/timeOn;
tilt1Proportion = (angleCounter(5)+angleCounter(6)+angleCounter(4)+angleCounter(7))*100/timeOn;
tilt2Proportion = 100-(HoriProportion+VertProportion+tilt1Proportion);

% Code above can be saved individually for datalogging only
% Code below only involves with data plotting

timeElapsed = ['Ticks used: ', num2str(timeUsed)];
timePenOn = ['Pen-on ticks: ', num2str(timeOn),newline...
             'Pen-on ticks percentage: ' num2str(timeOn*100/timeUsed),'%'];
timePenOff = ['Pen-off ticks: ', num2str(timeOff)];

angleStat = ['Ticks on 0~10бу:', num2str(angleCounter(1)),newline...
             'Ticks on 10~20бу:', num2str(angleCounter(2)),newline...
             'Ticks on 20~30бу:', num2str(angleCounter(3)),newline...
             'Ticks on 30~40бу:', num2str(angleCounter(4)),newline...
             'Ticks on 40~50бу:', num2str(angleCounter(5)),newline...
             'Ticks on 50~60бу:', num2str(angleCounter(6)),newline...
             'Ticks on 60~70бу:', num2str(angleCounter(7)),newline...
             'Ticks on 70~80бу:', num2str(angleCounter(8)),newline...
             'Ticks on 80~90бу:', num2str(angleCounter(9)),newline...
             'Horizontal line percentage: ',num2str(HoriProportion),'%',newline...
             'Vertical line percentage: ',num2str(VertProportion),'%',newline...
             '30~70бу line percentage: ',num2str(tilt1Proportion),'%',newline...
             'Unwanted line percentage: ',num2str(tilt2Proportion),'%'];

% Plot cube figure
figure(1)
clf;
subplot(2,3,1)
hold off;
% Plot pen off movement
p1 = plot(a,b,'-.r','color',[.134,.134,.149],'LineWidth',0.75);
hold on;
% Plot pen on movement
p2 = plot(x,y,'LineWidth',1.4,'color',[0.3 0.5 0.9]);
title('Cube');
lgd = legend([p1 p2],timePenOff,timePenOn);
title(lgd,timeElapsed);


% Plot velocity graph
subplot(2,3,2)
plot(velocity,'LineWidth',1,'color',[0.3 0.5 0.9]);
hold on;
plot(velocityCopy,'-.r','color','r');
title('Velocity-Time Graph');
xlabel('Timestamp');
xlim([0 size(z,1)+100]);
ylim([0 2]);
% Plot standard deviation of velocity
subplot(2,3,5)
plot(velocitySD,'LineWidth',1,'color',[0.3 0.5 0.9]);
title('Standard Deviation of Velocity Graph');
xlabel('Timestamp/SD Sample Rate');
ylim([0 0.5]);


% Plot angle graph
subplot(2,3,3)
plot(angle,'color',[0.3 0.5 0.9]);
hold on;
plot(angleCopy,'-.r','color','r');
title('Angle-Time Graph');
xlim([0 size(z,1)+100]);
ylim([-180 180]);
xlabel('Timestamp');
ylabel('Angle(бу)');

% Plot standard deviation of angle
subplot(2,3,6)
plot(angleSD,'LineWidth',0.75,'color',[0.3 0.5 0.9]);
title('Standard Deviation of Angle Graph');
xlabel('Timestamp/SD Sample Rate');
ylim([0 90]);

% Empty plot for placing legend
hSub = subplot(2,3,4);
plot(1,NaN,1,NaN,'r');
set(hSub,'Visible','off');
lgd = legend(hSub);
title(lgd,angleStat);

figure(2)
hold off;
bar(angleCatagories,angleCounter2);
ylim([0 50]);

