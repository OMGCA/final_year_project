function plot_data(fname,datasheet,sheet,index)
% Extract velocity, angle, tick usage etc from raw data
Data = load(fname); 
SDSampleRate = 20;
SampleRate = 30;

% Record x y axis into x y matrix
x = Data(:,2);
y = Data(:,3);
% Record pen pressure into z matrix
z = Data(:,6);
% Create a copy of x y axis to show pen off movement
a = x;
b = y;

angleCounter = zeros(9,1);

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
end

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
velocityStableCounter = 0;
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

% Calculate segmentations by pen state
penSeg = 0;

for c = 1:size(z)
    if(z(c) ~=0)
        if(z(c+1) == 0)
            penSeg = penSeg + 1;
        end
    end
end

for c = 1:size(z)
    timeStamp(c,1) = c;
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


xSegs(xSegs==0) = NaN;
ySegs(ySegs==0) = NaN;
segCounter = zeros(penSeg,1);
for c = 1:penSeg
    for d = 1:length(xSegs(c,:))
        if(isnan(xSegs(c,d)) == 0 || isnan(ySegs(c,d)) == 0)
            segCounter(c) = segCounter(c) + 1;
        end
    end
end
hesitationCounter = 0;
hesitateConst = 10;
for c = 1:penSeg
    for d = hesitateConst+1:segCounter(c)
        if (isnan((ySegs(c,d)-ySegs(c,d-hesitateConst))/(xSegs(c,d)-xSegs(c,d-hesitateConst))) == 1 && d>2*hesitateConst)
            hesitationCounter = hesitationCounter + 1;
        end
    end
end

avgPenOff = timeOff / penSeg;
allAngleSD = std2(angleSD);
allVelocitySD = std2(velocitySD);

HoriProportion = angleCounter(1)*100/timeOn;
VertProportion = angleCounter(9)*100/timeOn;
tilt1Proportion = (angleCounter(5)+angleCounter(6)+angleCounter(4)+angleCounter(7))*100/timeOn;
tilt2Proportion = 100-(HoriProportion+VertProportion);
notExpectedProportion = tilt2Proportion-tilt1Proportion;

dataToWrite = {HoriProportion,VertProportion,tilt1Proportion,notExpectedProportion...
                penSeg,avgPenOff,hesitationCounter,allVelocitySD,allAngleSD};
xlRange1 = 'C';
xlRange2 = num2str(index);
xlswrite(datasheet,dataToWrite,sheet,[xlRange1,xlRange2]);





