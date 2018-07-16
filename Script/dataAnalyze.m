addpath('M:\Project Demo\Script');
addpath('M:\Project Demo\CubeArrangedData');
datasheet = 'data.xlsx';
sheet = 1;
xlRange = 'B2:K120';
data = xlsread(datasheet,sheet,xlRange);

lineDistrubutionSD = zeros(119,1);
for c = 1:119
    lineDistrubutionSD(c) = std2(data(c,2:4));
end

maximumScore = 8;
scoreSamples = [0 3 6 16 15 37 23 19];

hesTier1 = 150;
hesTier2 = 500;
hesTier3 = 750;

hesTier1Count = zeros(maximumScore,1);
hesTier2Count = zeros(maximumScore,1);
hesTier3Count = zeros(maximumScore,1);
hesTier4Count = zeros(maximumScore,1);


% Tier for unwanted line percentage
% Lower tiers for better performance
tier1 = 20;
tier2 = 35;
tier1Count = zeros(maximumScore,1);
tier2Count = zeros(maximumScore,1);
tier3Count = zeros(maximumScore,1);

% Tier for pen-on percentage
%{
penOnTier1 = 50;
penOnTier2 = 75;
penOnTier3 = 95;
penOnT1 = zeros(maximumScore,1);
penOnT2 = zeros(maximumScore,1);
penOnT3 = zeros(maximumScore,1);
%}

avgOffTier1 = 250;
avgOffTier2 = 450;
avgOffTier3 = 750;
avgOffT1 = zeros(maximumScore,1);
avgOffT2 = zeros(maximumScore,1);
avgOffT3 = zeros(maximumScore,1);
avgOffT4 = zeros(maximumScore,1);
for c = 1:119
    if (data(c,8) >= 0 && data(c,8) < hesTier1)
        hesTier1Count(data(c,1)) = hesTier1Count(data(c,1)) + 1 ;
    end
    if (data(c,8) >= hesTier1 && data(c,8) < hesTier2)
        hesTier2Count(data(c,1)) = hesTier2Count(data(c,1)) + 1 ;
    end
    if (data(c,8) >= hesTier2 && data(c,8) < hesTier3)
        hesTier3Count(data(c,1)) = hesTier3Count(data(c,1)) + 1 ;
    end
    if (data(c,8) >= hesTier3)
        hesTier4Count(data(c,1)) = hesTier4Count(data(c,1)) + 1 ;
    end
    
    if (data(c,5) >= 0 && data(c,5) < tier1)
        tier1Count(data(c,1)) = tier1Count(data(c,1)) + 1;
    end
    if (data(c,5) >= tier1 && data(c,5) < tier2)
        tier2Count(data(c,1)) = tier2Count(data(c,1)) + 1;
    end
    if (data(c,5) >= tier2)
        tier3Count(data(c,1)) = tier3Count(data(c,1)) + 1;
    end
    
    if (data(c,7) >= 0 && data(c,7) < avgOffTier1)
        avgOffT1(data(c,1)) = avgOffT1(data(c,1)) + 1;
    end
    if (data(c,7) >= avgOffTier1 && data(c,7) < avgOffTier2)
        avgOffT2(data(c,1)) = avgOffT2(data(c,1)) + 1;
    end
    if (data(c,7) >= avgOffTier2 && data(c,7) < avgOffTier3)
        avgOffT3(data(c,1)) = avgOffT3(data(c,1)) + 1;
    end
    if (data(c,7) >= avgOffTier3)
        avgOffT4(data(c,1)) = avgOffT4(data(c,1)) + 1;
    end
    %{
    if(data(c,9) >= 0 && data(c,9) < penOnTier1)
        penOnT1(data(c,1)) = penOnT1(data(c,1)) + 1;
    end
    if(data(c,9) >= penOnTier1 && data(c,9) < penOnTier2)
        penOnT2(data(c,1)) = penOnT2(data(c,1)) + 1;
    end
    if(data(c,9) >= penOnTier2 && data(c,9) < penOnTier3)
        penOnT3(data(c,1)) = penOnT3(data(c,1)) + 1;
    end
    %}
end


score = [1 2 3 4 5 6 7 8];
sample = [tier1Count tier2Count tier3Count];

tier1Per = zeros(maximumScore,1);
tier2Per = zeros(maximumScore,1);
tier3Per = zeros(maximumScore,1);
%{
penOnT1Per = zeros(maximumScore,1);
penOnT2Per = zeros(maximumScore,1);
penOnT3Per = zeros(maximumScore,1);
%}
avgOffT1Per = zeros(maximumScore,1);
avgOffT2Per = zeros(maximumScore,1);
avgOffT3Per = zeros(maximumScore,1);
avgOffT4Per = zeros(maximumScore,1);

hesT1Per = zeros(maximumScore,1);
hesT2Per = zeros(maximumScore,1);
hesT3Per = zeros(maximumScore,1);
hesT4Per = zeros(maximumScore,1);

for c = 1:maximumScore
    tier1Per(c) = tier1Count(c,1)/scoreSamples(c);
    tier2Per(c) = tier2Count(c,1)/scoreSamples(c);
    tier3Per(c) = tier3Count(c,1)/scoreSamples(c);
    %{
    penOnT1Per(c) = penOnT1(c,1)/scoreSamples(c);
    penOnT2Per(c) = penOnT2(c,1)/scoreSamples(c);
    penOnT3Per(c) = penOnT3(c,1)/scoreSamples(c);
    %}
    avgOffT1Per(c) = avgOffT1(c,1)/scoreSamples(c);
    avgOffT2Per(c) = avgOffT2(c,1)/scoreSamples(c);
    avgOffT3Per(c) = avgOffT3(c,1)/scoreSamples(c);
    avgOffT4Per(c) = avgOffT4(c,1)/scoreSamples(c);
    
    hesT1Per(c) = hesTier1Count(c,1)/scoreSamples(c);
    hesT2Per(c) = hesTier2Count(c,1)/scoreSamples(c);
    hesT3Per(c) = hesTier3Count(c,1)/scoreSamples(c);
    hesT4Per(c) = hesTier4Count(c,1)/scoreSamples(c);
    
    
    if isnan(tier1Per(c)) == 1
        tier1Per(c) = 0;
    end
    if isnan(tier2Per(c)) == 1
        tier2Per(c) = 0;
    end
    if isnan(tier3Per(c)) == 1
        tier3Per(c) = 0;
    end
    if isnan(avgOffT1Per(c)) == 1
        avgOffT1Per(c) = 0;
    end
    if isnan(avgOffT2Per(c)) == 1
        avgOffT2Per(c) = 0;
    end
    if isnan(avgOffT3Per(c)) == 1
        avgOffT3Per(c) = 0;
    end
    if isnan(avgOffT4Per(c)) == 1
        avgOffT4Per(c) = 0;
    end
    
    if isnan(hesT1Per(c)) == 1
        hesT1Per(c) = 0;
    end
    if isnan(hesT2Per(c)) == 1
        hesT2Per(c) = 0;
    end
    if isnan(hesT3Per(c)) == 1
        hesT3Per(c) = 0;
    end
    if isnan(hesT4Per(c)) == 1
        hesT4Per(c) = 0;
    end
   
end
samplePer = [tier1Per tier2Per tier3Per];
% penOnPer = [penOnT1Per penOnT2Per penOnT3Per];
avgOffPer = [avgOffT1Per avgOffT2Per avgOffT3Per avgOffT4Per];

hesPer = [hesT1Per hesT2Per hesT3Per hesT4Per];

%{
figure(1);
clf;
plot(lineDistrubutionSD,'Linewidth',1.5);
hold on;
plot(data(:,2),'b');
plot(data(:,3),'r');
plot(data(:,4),'g');
legend('Standard Deviation of line distrubution','Horizontal Proportion','Vertical Proportion'...
      ,'30-70бу Proportion');
ylim([0 80]);
%}

%{
figure(2);
clf;
plot(data(:,6));
hold on;
plot(data(:,7),'g');
plot(data(:,8),'r');
legend('Tick used','Pen-On','Pen-Off');
%}


figure(2);
clf;
subplot(2,1,1);
bar(score,samplePer);
title('Unwanted line tier distribution in different score');
xlabel('Score');
ylim([0 1]);
legend(['Tier 1 (<' num2str(tier1) '%)' ],['Tier 2 (<' num2str(tier2) '%)'],['Tier 3 (>=' num2str(tier2) '%)'])

subplot(2,1,2);
plot(score,samplePer);
hold on;
xlabel('Score');
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(tier1) '%)' ],['Tier 2 (<' num2str(tier2) '%)'],['Tier 3 (>=' num2str(tier2) '%)'])

%{
figure(2);
subplot(2,1,1);
hold off;
bar(score,penOnPer);
title('Pen-On% tier distribution in different score');
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(penOnTier1) '%)' ],['Tier 2 (<' num2str(penOnTier2) '%)'],['Tier 3 (<' num2str(penOnTier3) '%)'])

subplot(2,1,2);
xlim([1 8]);
plot(score,penOnT1Per);
hold on;
plot(score,penOnT2Per);
plot(score,penOnT3Per);

xlabel('Score');
ylabel('Pen-On %');
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(penOnTier1) '%)' ],['Tier 2 (<' num2str(penOnTier2) '%)'],['Tier 3 (<' num2str(penOnTier3) '%)'])
%}

figure(3);
clf;
subplot(2,1,1);
hold off;
bar(score, avgOffPer);
title('Pen-Off average ticks distrubution in different score');
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(avgOffTier1) ')' ],['Tier 2 (<' num2str(avgOffTier2) ')'],['Tier 3 (<' num2str(avgOffTier3) ')'],['Tier 4 (>=' num2str(avgOffTier3) ')'])

subplot(2,1,2);
hold off;
plot(score,avgOffPer);
hold on;
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(avgOffTier1) ')' ],['Tier 2 (<' num2str(avgOffTier2) ')'],['Tier 3 (<' num2str(avgOffTier3) ')'],['Tier 4 (>=' num2str(avgOffTier3) ')'])

figure(5);
clf;
subplot(2,1,1);
hold off;
bar(score, hesPer);
title('Hesitation ticks distrubution in different score');
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(hesTier1) ')' ],['Tier 2 (<' num2str(hesTier2) ')'],['Tier 3 (<' num2str(hesTier3) ')'],['Tier 4 (>=' num2str(hesTier3) ')'])

subplot(2,1,2);
hold off;
plot(score, hesPer);
xlim([1 8]);
ylim([0 1]);
legend(['Tier 1 (<' num2str(hesTier1) ')' ],['Tier 2 (<' num2str(hesTier2) ')'],['Tier 3 (<' num2str(hesTier3) ')'],['Tier 4 (>=' num2str(hesTier3) ')'])

