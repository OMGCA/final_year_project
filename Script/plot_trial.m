addpath('M:\Project Demo\CubeArrangedData');
sampleName = 'RL28-Other-Right2-260608.txt';
Data = load(sampleName); 
SDSampleRate = 20;
SampleRate = 50;

% Record x y axis into x y matrix
x = Data(:,2);
y = Data(:,3);
% Record pen pressure into z matrix
z = Data(:,6);
% Create a copy of x y axis to show pen off movement
a = x;
b = y;
hesitationCounter = 0;

penOnTimeStamp = [];
timeStamp = [];

for c = 1:size(z)
    timeStamp(c,1) = c;
end

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
    if(isnan(angle(c)) == 1)
        angle(c) = 0;
    end
    for d = 1:9
        % Only pen ON is counted
        if ( abs(angle(c)) >= d*10-10 && abs(angle(c)) < d*10 && z(c) ~= 0)
            angleCounter(d) = angleCounter(d) + 1;
        end
        
    end
    if ( abs(angle(c)) == 90 && z(c) ~= 0)
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
    angleSD(c) = std2(abs(angle(counter:counter+SDSampleRate)));
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

% Calculate segmentations by pen state
penSeg = 0;

for c = 1:size(z)
    if(z(c) ~=0)
        if(z(c+1) == 0)
            penSeg = penSeg + 1;
        end
    end
end

penSegIndex = 1;
penTimeStampIndex = 1;
for c = 1:size(z)
    if(z(c) ~= 0)
        penOnTimeStamp(penSegIndex,penTimeStampIndex) = timeStamp(c);
        penTimeStampIndex = penTimeStampIndex + 1;
        if(z(c+1) == 0 && penSegIndex < penSeg)
            penSegIndex = penSegIndex + 1;
            penTimeStampIndex = 1;
        end
    end
end

xSegs = [];
ySegs = [];

for c = 1:penSeg
    for d = 1:length(penOnTimeStamp)
        if(penOnTimeStamp(c,d) ~= 0)
            xSegs(c,d) = x(penOnTimeStamp(c,d));
            ySegs(c,d) = y(penOnTimeStamp(c,d));
        end
    end
end

gradiTmp = NaN(penSeg,length(xSegs));
segsSD = [];
segCounter = zeros(penSeg,2);

xSegs(xSegs==0) = NaN;
ySegs(ySegs==0) = NaN;

for c = 1:penSeg
    for d = 1:length(xSegs(c,:))
        if(isnan(xSegs(c,d)) ~=1 && isnan(ySegs(c,d)) ~= 1)
            segCounter(c,1) = segCounter(c,1) + 1;
        elseif(isnan(xSegs(c,d)) == 1)
            segCounter(c,1) = segCounter(c,1);
        end
    end
end

hesitationXY = NaN(2,2000);

for c = 1:penSeg
    if(isnan(gradiTmp(c,1)) == 1)
           gradiTmp(c,1) = 0;
    end
    for d = SampleRate+1:segCounter(c)
        if ((ySegs(c,d)-ySegs(c,d-SampleRate))/(xSegs(c,d)-xSegs(c,d-SampleRate)) == Inf || (ySegs(c,d)-ySegs(c,d-SampleRate))/(xSegs(c,d)-xSegs(c,d-SampleRate)) == -Inf)
            gradiTmp(c,d-SampleRate) = 90;
        elseif (isnan((ySegs(c,d)-ySegs(c,d-SampleRate))/(xSegs(c,d)-xSegs(c,d-SampleRate))) == 1 && d~=SampleRate+1)
            gradiTmp(c,d-SampleRate) = gradiTmp(c,d-SampleRate-1);
            hesitationCounter = hesitationCounter + 1;
            hesitationXY(1,hesitationCounter) = xSegs(c,d);
            hesitationXY(2,hesitationCounter) = ySegs(c,d);
        elseif(isnan(gradiTmp(c,1)) == 0 || d > SampleRate+1)
            gradiTmp(c,d-SampleRate) = atan(abs((ySegs(c,d)-ySegs(c,d-SampleRate))/(xSegs(c,d)-xSegs(c,d-SampleRate))))*180/pi;
        end 
    end
end

for c = 1:penSeg
    for d = 1:length(gradiTmp(c,:))
        if(isnan(gradiTmp(c,d)) ~=1 && isnan(gradiTmp(c,d)) ~= 1)
            segCounter(c,2) = segCounter(c,2) + 1;
        elseif(isnan(gradiTmp(c,d)) == 1)
            segCounter(c,2) = segCounter(c,2);
        end
    end
    segsSD(c) = std(gradiTmp(c,1:segCounter(c,2)-1));
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

angleStat = ['Ticks on 0~10��:', num2str(angleCounter(1)),newline...
             'Ticks on 10~20��:', num2str(angleCounter(2)),newline...
             'Ticks on 20~30��:', num2str(angleCounter(3)),newline...
             'Ticks on 30~40��:', num2str(angleCounter(4)),newline...
             'Ticks on 40~50��:', num2str(angleCounter(5)),newline...
             'Ticks on 50~60��:', num2str(angleCounter(6)),newline...
             'Ticks on 60~70��:', num2str(angleCounter(7)),newline...
             'Ticks on 70~80��:', num2str(angleCounter(8)),newline...
             'Ticks on 80~90��:', num2str(angleCounter(9)),newline...
             'Horizontal line percentage: ',num2str(HoriProportion),'%',newline...
             'Vertical line percentage: ',num2str(VertProportion),'%',newline...
             '30~70�� line percentage: ',num2str(tilt1Proportion),'%',newline...
             'Unwanted line percentage: ',num2str(tilt2Proportion),'%'];

% Plot cube figure
%{
figure(5)
clf;
%subplot(2,3,1)
hold off;
% Plot pen off movement
p1 = plot(a,b,'-.r','color',[.134,.134,.149],'LineWidth',0.75);
hold on;
% Plot pen on movement
p2 = plot(x,y,'LineWidth',1.4,'color',[0.3 0.5 0.9]);
title('Cube');
lgd = legend([p1 p2],timePenOff,timePenOn);
title(lgd,timeElapsed);
axis equal;
%}


% Plot velocity graph

figure(1);
clf
subplot(1,2,1)
plot(velocity,'LineWidth',1,'color',[0.3 0.5 0.9]);
hold on;
plot(velocityCopy,'-.r','color','r');
title('Velocity-Time Graph');
xlabel('Timestamp');
xlim([0 size(z,1)+100]);
ylim([0 2]);
% Plot standard deviation of velocity
subplot(1,2,2)
plot(velocitySD,'LineWidth',1,'color',[0.3 0.5 0.9]);
title('Standard Deviation of Velocity Graph');
xlabel('Timestamp/SD Sample Rate');
ylim([0 0.5]);



% Plot angle graph
 %clf;
%{
figure(1);
subplot(1,2,1)
plot(angle,'color',[0.3 0.5 0.9]);
hold on;
plot(angleCopy,'-.r','color','r');
title('Angle-Time Graph');
xlim([0 size(z,1)+100]);
ylim([-180 180]);
xlabel('Timestamp');
ylabel('Angle(��)');
%}


% Plot standard deviation of angle
%{
subplot(1,2,2)
plot(angleSD,'LineWidth',0.75,'color',[0.3 0.5 0.9]);
title('Standard Deviation of Angle Graph');
xlabel('Timestamp/SD Sample Rate');
ylim([0 90]);
%}
%{
% Empty plot for placing legend
hSub = subplot(2,3,4);
plot(1,NaN,1,NaN,'r');
set(hSub,'Visible','off');
lgd = legend(hSub);
title(lgd,angleStat);
%}



figure(4)
clf;
hold off;
movementLegend = ['Average hesitation ticks = ', num2str(timeOff/penSeg)];
plot(z);
legend(movementLegend);
axis equal;


figure(6);
clf;
plot(a,b,'-.r','color',[.134,.134,.149],'LineWidth',0.75);
hold on;
for c = 1:penSeg
    plot(xSegs(c,:),ySegs(c,:),'LineWidth',0.25*c);
end
plot(hesitationXY(1,:),hesitationXY(2,:),'*','LineWidth',6,'color','red');
title(sampleName);
axis equal;
legend("Pen-Off","Seg1","Seg2","Seg3","Seg4","Seg5","Seg6","Seg7","Seg8","Seg9","Seg10","Seg11","Seg12","Seg13","Seg14","Seg15","Seg16","Seg17");

figure(7)
clf;
hold on;
for c = 1:penSeg
    plot(gradiTmp(c,:),'LineWidth',c*0.25);
end
ylim([0 105]);
legend("Seg1","Seg2","Seg3","Seg4","Seg5","Seg6","Seg7","Seg8","Seg9","Seg10","Seg11","Seg12","Seg13","Seg14","Seg15","Seg16","Seg17");


