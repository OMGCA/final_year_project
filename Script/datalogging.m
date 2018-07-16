datasheet = 'Z:\Project Demo\CubeArrangedData\data.xlsx';
sheet = 1;
xlRange = 'A2:B120';
[dataScore,dataSet] = xlsread(datasheet,sheet,xlRange);

% Unknown corruption at RL4-1&2,RL5-1
for c = 1:119
    buffer = dataSet(c);
    fname = buffer{1};
    plot_data(fname,datasheet,sheet,c+1);
end