Data = load("fitness.txt");
generations = 40000;
updateFreq = 500;
generation = zeros(1,generations/updateFreq);
for c = 0:generations/updateFreq
    generation(c+1) = c*500;
end
training = Data(1,:);
validation = Data(2,:);
test = Data(3,:);
clf;
plot(generation,training,'LineWidth',1.25,'color',[0.3 0.5 0.9]);
hold on;
plot(generation, validation,'LineWidth',1.25,'color',[0.5 0.3 0.9]);
plot(generation, test,'LineWidth',1.25,'color',[0.8 0.2 0.2]);
legend("Training fitness","Validation fitness","Testing fitness");
xlabel('Generation');
ylabel('Fitness');
title('Fitness evolution through generations');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainingResult = load("test_output.txt");
chromoOutputs = trainingResult(:,1);
expectedClass = trainingResult(:,2);
figure(2);
clf;
ClassColor = 'DarkRed';
bar(chromoOutputs,'FaceColor',rgb('DarkSlateBlue'));
line([1 30],[100 100],'LineWidth',3, 'Color', rgb('IndianRed'));
line([1 30],[200 200],'LineWidth',3, 'Color', rgb('SaddleBrown'));
line([5 5],[0 max(chromoOutputs)],'LineWidth',3,'Color',rgb(ClassColor));
line([15 15],[0 max(chromoOutputs)],'LineWidth',3,'Color',rgb(ClassColor));
line([25 25],[0 max(chromoOutputs)],'LineWidth',3,'Color',rgb(ClassColor));
xlim([0 30]);
ylim([0 max(chromoOutputs)+100]);
text(30,100,'Threshold 1');
text(30,200,'Threshold 2');
text(5,max(chromoOutputs)+50,'Class 1');
text(15,max(chromoOutputs)+50,'Class 2');
xlabel('Sample Number');
ylabel('Chromosome Output');
title('Chromosome execution result');
text(25,max(chromoOutputs)+50,'Class 3');