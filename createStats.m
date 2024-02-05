

%%% column index
% 1 - S (Acierto) == Accuracy
% 3 - FP
% 5 - FN
% 7 - Precision
% 9 - Recall
% 11 - Acc
% 13 - F-measure
% 15 - Time per frame
% 16 - Mem (NO USE THIS VALUE)
% 17 - NdxVideo
% 18 - NumMedianFilters
% 19 - SubsamplingFactor
% 20 - SmallestArea
% 21 - LargestArea
% 22 - ID SubsamplingFactor
% 23 - ID NumMedianFilters
% 24 - ID Area

ColumnAcc = 1;
ColumnFmeasure = 13;
ColumnTime = 15;
ColumnVideo = 17;
ColumnNumMedianFilters = 18;
ColumnSubsamplingFactor = 19;
ColumnSmallestArea = 20;
ColumnLargestArea = 21;
ColumnIDNumMedianFilters = 22;
ColumnIDArea = 23;
ColumnIDSubsamplingFactor = 24;

% Search rows from the desired NdxVideo (column 17)
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);

% Search rows from the desired video (column 17) and polygon area (columns 20 and 21)
NdxVideo = 1;
SmallestArea = 50;
LargestArea = 100;
rowsFullResultsNdxVideo = find((FullResults(:,ColumnVideo) == NdxVideo) & (FullResults(:,ColumnSmallestArea) == SmallestArea) & (FullResults(:,ColumnLargestArea) == LargestArea));
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);

% max accuracy (column 1) for this parameters (video and polygon area)
ResultsNdxVideo(find(ResultsNdxVideo(:,ColumnAcc) == max(ResultsNdxVideo(:,ColumnAcc))),:);



%% GENERATE STATS

ListMeasures={'S Mean','S Std','FP Mean','FP Std','FN Mean','FN Std','PR Mean','PR Std',...
                'RC Mean','RC Std','AC Mean','AC Std','FM Mean','FM Std',...
                'Time per frame', 'Mem', 'Video', 'NumMedianFilters',...
                'SubsamplingFactor', 'PolygonSize', 'LargestArea'}; %PolygonSize es en realidad SmallestArea
Measures={'Accuracy','Accuracy Std','FP','FP Std','FN','FN Std','PR','PR Std',...
            'RC','RC Std','AC','AC Std','F-measure','F-measure Std',...
            'Time per frame', 'Mem', 'Video', 'NumMedianFilters',...
                'SubsamplingFactor', 'PolygonSize', 'LargestArea'}; %PolygonSize es en realidad SmallestArea
ListVideos={'Highway','Office','Boats','Canoe','Fall','Overpass','Backdoor','Bungalows'};
NumVideos=numel(ListVideos);

% Methods={'MFBM','CL-VID','CucchiaraSakbot','ElBafFuzzy','ElgammalKDE',...
%     'FSOM','GrimsonGMM','MaddalenaSOBS','OliverPCA','WrenGA',...
%     'ZivkovicGMM'};
% MethodsTags={'MFBM','CV','CS','EBF','EK',...
%     'FSOM','GG','MS','OP','WG',...
%     'ZG'};
Methods={'value','mean','median'};
NumMethods=numel(Methods);
MyColorMap = distinguishable_colors(NumMethods);
ListSymbol={'h-','p-','o-','^-','s-','*-','d-','x-','+-','<-','v-'};
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};



%% ACCURACY

%% Generate NumMedianFilters-Accuracy per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=18; 
IdxMeasureY=1;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;
    confX = unique(XValues);
    num_confX = numel(confX);
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        plot(XValues(i,:),YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        k = find(confX==(XValues(i,:)),1);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(confX(i),media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(confX(i),mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
            
	XAxisStart=floor(min (XValues) * 1000) / 1000;
	XAxisEnd=ceil(max (XValues) * 1000) / 1000;
 	YAxisStart=floor(min (YValues) * 1000) / 1000;
	YAxisEnd=ceil(max (YValues) * 1000) / 1000;
 %XAxisEnd=XAxisEnd+1; %ELIMINAR ESTA LINEA CUANDO SE TENGAN TODAS LAS ESTADISTICAS!!!!!!!!!!!!!!!!!!!!!!!         
	axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
	title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
 	xlabel(Measures{IdxMeasureX},'fontsize',16);
 	ylabel(Measures{IdxMeasureY},'fontsize',16);
    
    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate NumMedianFilters-Accuracy in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=18;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;
%XAxisEnd=XAxisEnd+1; %ELIMINAR ESTA LINEA CUANDO SE TENGAN TODAS LAS ESTADISTICAS!!!!!!!!!!!!!!!!!!!!!!!
axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');

%% Generate SubsamplingFactor-Accuracy per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=19; 
IdxMeasureY=1;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;
    confX = unique(XValues);
    num_confX = numel(confX);
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        plot(XValues(i,:),YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        k = find(confX==(XValues(i,:)),1);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(confX(i),media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(confX(i),mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
            
	XAxisStart=floor(min (XValues) * 1000) / 1000;
	XAxisEnd=ceil(max (XValues) * 1000) / 1000;
 	YAxisStart=floor(min (YValues) * 1000) / 1000;
	YAxisEnd=ceil(max (YValues) * 1000) / 1000;
          
	axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
	title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
 	xlabel(Measures{IdxMeasureX},'fontsize',16);
 	ylabel(Measures{IdxMeasureY},'fontsize',16);

    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate SubsamplingFactor-Accuracy in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=19;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;

axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');

%% Generate PolygonSize-Accuracy per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=20; 
IdxMeasureY=1;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;    
    XValuesMin = XValues;
    XValuesMax = ResultsNdxVideo(:,IdxMeasureX+1);

    OptionsMinSizePolygonLimit= [1  50  100 150 200 300  1  50  100  1  100 200  1];
    OptionsMaxSizePolygonLimit= [50 100 150 200 300 400 100 150 200 200 300 400 400];
    num_confX = numel(OptionsMinSizePolygonLimit);
    XValues = 1:num_confX;
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        kMin = find(OptionsMinSizePolygonLimit==(XValuesMin(i,:)));
        kMax = find(OptionsMaxSizePolygonLimit==(XValuesMax(i,:)));
        k=intersect(kMin,kMax);
        plot(k,YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(i,media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(i,mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
    XAxisStart=floor(min (XValues) * 1000) / 1000;
    XAxisEnd=ceil(max (XValues) * 1000) / 1000;
    YAxisStart=floor(min (YValues) * 1000) / 1000;
    YAxisEnd=ceil(max (YValues) * 1000) / 1000;

    axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
    title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
    xlabel(Measures{IdxMeasureX},'fontsize',16);
    ylabel(Measures{IdxMeasureY},'fontsize',16);

    ListConfPolygonSize={'1-50','50-100','100-150','150-200','200-300','300-400','1-100','50-150','100-200','1-200','100-300','200-400','1-400'};
    set(gca,'xticklabel',ListConfPolygonSize);
    set(gca,'xtick',1:13);

    ax = gca;
    ax.XTickLabelRotation = -45;
    
    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate PolygonSize-Accuracy in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=20;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
ListConfPolygonSize={'1-50','50-100','100-150','150-200','200-300','300-400','1-100','50-150','100-200','1-200','100-300','200-400','1-400'};
        set(gca,'xticklabel',ListConfPolygonSize);
        set(gca,'xtick',1:12);
        set(gca,'fontsize',16);
        
        ax = gca;
        ax.XTickLabelRotation = -45;
        confX = 1:numel(ListConfPolygonSize);
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;

axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');


%% TIME STATS
%% Generate NumMedianFilters-Time per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=18; 
IdxMeasureY=15;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;
    confX = unique(XValues);
    num_confX = numel(confX);
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        plot(XValues(i,:),YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        k = find(confX==(XValues(i,:)),1);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(confX(i),media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(confX(i),mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
            
	XAxisStart=floor(min (XValues) * 1000) / 1000;
	XAxisEnd=ceil(max (XValues) * 1000) / 1000;
 	YAxisStart=floor(min (YValues) * 1000) / 1000;
	YAxisEnd=ceil(max (YValues) * 1000) / 1000;
 %XAxisEnd=XAxisEnd+1; %ELIMINAR ESTA LINEA CUANDO SE TENGAN TODAS LAS ESTADISTICAS!!!!!!!!!!!!!!!!!!!!!!!         
	axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
	title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
 	xlabel(Measures{IdxMeasureX},'fontsize',16);
 	ylabel(Measures{IdxMeasureY},'fontsize',16);
    
    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate NumMedianFilters-Time in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=18;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;
%XAxisEnd=XAxisEnd+1; %ELIMINAR ESTA LINEA CUANDO SE TENGAN TODAS LAS ESTADISTICAS!!!!!!!!!!!!!!!!!!!!!!!
axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');

%% Generate SubsamplingFactor-Time per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=19; 
IdxMeasureY=15;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;
    confX = unique(XValues);
    num_confX = numel(confX);
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        plot(XValues(i,:),YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        k = find(confX==(XValues(i,:)),1);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(confX(i),media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(confX(i),mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
            
	XAxisStart=floor(min (XValues) * 1000) / 1000;
	XAxisEnd=ceil(max (XValues) * 1000) / 1000;
 	YAxisStart=floor(min (YValues) * 1000) / 1000;
	YAxisEnd=ceil(max (YValues) * 1000) / 1000;
          
	axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
	title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
 	xlabel(Measures{IdxMeasureX},'fontsize',16);
 	ylabel(Measures{IdxMeasureY},'fontsize',16);

    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate SubsamplingFactor-Time in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=19;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;

axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');

%% Generate PolygonSize-Time per video figures
SelectedVideos=1:NumVideos;
IdxMeasureX=20; 
IdxMeasureY=15;
ListSymbol={'.','h','p','o'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    NdxMethod = 1;    
    XValuesMin = XValues;
    XValuesMax = ResultsNdxVideo(:,IdxMeasureX+1);

    OptionsMinSizePolygonLimit= [1  50  100 150 200 300  1  50  100  1  100 200  1];
    OptionsMaxSizePolygonLimit= [50 100 150 200 300 400 100 150 200 200 300 400 400];
    num_confX = numel(OptionsMinSizePolygonLimit);
    XValues = 1:num_confX;
    datos_x_conf=zeros(num_confX,0);
    for i=1:numConf
        kMin = find(OptionsMinSizePolygonLimit==(XValuesMin(i,:)));
        kMax = find(OptionsMaxSizePolygonLimit==(XValuesMax(i,:)));
        k=intersect(kMin,kMax);
        plot(k,YValues(i,:), ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'MarkerSize',8,'LineWidth',1.5);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    for i=1:num_confX
        a=datos_x_conf(i,:);
        a(a==0)=[];
        media = mean(a);
        plot(i,media, ListSymbol{2},'Color',MyColorMap(2,:),'MarkerSize',10,'LineWidth',1.5);
        mediana = median(a);
        plot(i,mediana, ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
        medianArray(NdxVideo,i) = mediana;
    end
    XAxisStart=floor(min (XValues) * 1000) / 1000;
    XAxisEnd=ceil(max (XValues) * 1000) / 1000;
    YAxisStart=floor(min (YValues) * 1000) / 1000;
    YAxisEnd=ceil(max (YValues) * 1000) / 1000;

    axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
    title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
    xlabel(Measures{IdxMeasureX},'fontsize',16);
    ylabel(Measures{IdxMeasureY},'fontsize',16);

    ListConfPolygonSize={'1-50','50-100','100-150','150-200','200-300','300-400','1-100','50-150','100-200','1-200','100-300','200-400','1-400'};
    set(gca,'xticklabel',ListConfPolygonSize);
    set(gca,'xtick',1:13);

    ax = gca;
    ax.XTickLabelRotation = -45;
    
    PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');
end

%% Generate PolygonSize-Time in all videos figure
SelectedVideos=1:NumVideos;
IdxMeasureX=20;
MyColorMap = distinguishable_colors(NumVideos);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
hold on
ListConfPolygonSize={'1-50','50-100','100-150','150-200','200-300','300-400','1-100','50-150','100-200','1-200','100-300','200-400','1-400'};
        set(gca,'xticklabel',ListConfPolygonSize);
        set(gca,'xtick',1:12);
        set(gca,'fontsize',16);
        
        ax = gca;
        ax.XTickLabelRotation = -45;
        confX = 1:numel(ListConfPolygonSize);
%plot medianArray
for NdxVideo=SelectedVideos
    for i=1:num_confX 
        plot(confX(i),medianArray(NdxVideo,i), ListSymbol{NdxVideo},'Color',MyColorMap(NdxVideo,:),'MarkerSize',8,'LineWidth',1.5);
    end
end
XAxisStart=floor(min (confX) * 1000) / 1000;
XAxisEnd=ceil(max (confX) * 1000) / 1000;
YAxisStart=floor(min(min( medianArray)) * 1000) / 1000;
YAxisEnd=ceil(max (max(medianArray)) * 1000) / 1000;

axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
title(sprintf('%s','Videos'),'fontsize',16);
xlabel(Measures{IdxMeasureX},'fontsize',16);
ylabel(Measures{IdxMeasureY},'fontsize',16);
PdfFileName=sprintf('figuras/Performance_%s_%s_%s.pdf','Videos',Measures{IdxMeasureX},Measures{IdxMeasureY});
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 11]);
set(gcf,'PaperPosition',[0 0 12 11]);
%set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
%set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
set(gca,'fontsize',16);
saveas(gcf,PdfFileName,'pdf');




%% GENERATE THE LEGEND VALUE-MEAN-MEDIAN
Methods={'value','mean','median'};
NumMethods=numel(Methods);
SelectedMethods=1:NumMethods;
MyColorMap = distinguishable_colors(NumMethods);
ListSymbol={'.','h','p'};
figure
Handle=zeros(NumMethods,1);
for NdxMethod=SelectedMethods
    Handle(NdxMethod)=plot(2:6,2:6,...
        ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'LineWidth',1.5);
    hold on
end
legHdl = gridLegend(Handle(SelectedMethods),3,Methods(SelectedMethods));
PdfFileName='figuras/LegendValueMeanMedian.pdf';
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[16 1]);
set(gcf,'PaperPosition',[0 0.2 16 11]);
set(gca,'fontsize',11);
set(gca, 'visible', 'off');
saveas(gcf,PdfFileName,'pdf');

%% GENERATE THE LEGEND FOR THE VIDEO DATASET
Methods={'Highway','Office','Boats','Canoe','Fall','Overpass','Backdoor','Bungalows'};
NumMethods=numel(Methods);
SelectedMethods=1:NumMethods;
MyColorMap = distinguishable_colors(NumMethods);
ListSymbol={'h','p','o','^','s','*','d','x','+','<','v'};
figure
Handle=zeros(NumMethods,1);
for NdxMethod=SelectedMethods
    Handle(NdxMethod)=plot(2:6,2:6,...
        ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'LineWidth',1.5);
    hold on
end
legHdl = gridLegend(Handle(SelectedMethods),3,Methods(SelectedMethods));
PdfFileName='figuras/LegendVideos.pdf';
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[14 1.5]);
set(gcf,'PaperPosition',[0 0.2 14 10]);
set(gca,'fontsize',11);
set(gca, 'visible', 'off');
saveas(gcf,PdfFileName,'pdf');

%% GENERATE THE LEGEND FOR THE PARETO FRONT DATASET
Methods={'value','pareto','mean','median'};
NumMethods=numel(Methods);
MyColorMap = distinguishable_colors(NumMethods);
tempcolor = MyColorMap(1,:);
MyColorMap(1,:) = MyColorMap(3,:);
MyColorMap(3,:) = tempcolor;
SelectedMethods=1:NumMethods;
ListSymbol={'.','-','h','p'};
figure
Handle=zeros(NumMethods,1);
for NdxMethod=SelectedMethods
    Handle(NdxMethod)=plot(2:6,2:6,...
        ListSymbol{NdxMethod},'Color',MyColorMap(NdxMethod,:),'LineWidth',1.5);
    hold on
end
legHdl = gridLegend(Handle(SelectedMethods),4,Methods(SelectedMethods));
PdfFileName='figuras/LegendValueParetoMeanMedian.pdf';
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPositionMode','manual');
set(gcf,'PaperSize',[12 1]);
%set(gcf,'PaperPosition',[0 0.2 16 11]);
set(gcf,'PaperPosition',[0 0.3 12 11]);
set(gca,'fontsize',11);
set(gca, 'visible', 'off');
saveas(gcf,PdfFileName,'pdf');


%% Generate Accuracy-Time per video figures and the Pareto front
Methods={'value','pareto','mean','median'};
NumMethods=numel(Methods);
MyColorMap = distinguishable_colors(NumMethods);
tempcolor = MyColorMap(1,:);
MyColorMap(1,:) = MyColorMap(3,:);
MyColorMap(3,:) = tempcolor;
SelectedVideos=1:NumVideos;
IdxMeasureX=1; 
IdxMeasureY=15;
ListSymbol={'.','-','h','p'};
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);
members=[];
for NdxVideo=SelectedVideos
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
	figure
    hold on
    XValues = ResultsNdxVideo(:,IdxMeasureX);
    YValues = ResultsNdxVideo(:,IdxMeasureY);
    confX = unique(XValues);
    num_confX = numel(confX);
    datos_x_conf=zeros(num_confX,0);
    
    % los puntos en verde (MyColorMap(3,:)) y la media en azul (MyColorMap(1,:))
    % para que se vea mejor
    for i=1:numConf
        plot(XValues(i,:),YValues(i,:), ListSymbol{1},'Color',MyColorMap(1,:),'MarkerSize',8,'LineWidth',1.5);
        k = find(confX==(XValues(i,:)),1);
        datos_x_conf(k,end+1) = YValues(i,:);
    end
    x = [XValues YValues];
    members(NdxVideo,:) = paretofronts(x,[0,1],1,1,[],ListVideos{NdxVideo}); % [0,1] means: 0 maximize acc and 1 minimize time
    paretoFrontPoints = x(find(members(NdxVideo,:)==1),:)';
    [Y,I]=sort(paretoFrontPoints(1,:));
    paretoFrontPoints=paretoFrontPoints(:,I);
    %line(paretoFrontPoints(1,:),paretoFrontPoints(2,:)); 
    line(paretoFrontPoints(1,:),paretoFrontPoints(2,:),'Color',MyColorMap(2,:),'LineWidth',3); 
    
    plot(mean(XValues),mean(YValues), ListSymbol{3},'Color',MyColorMap(3,:),'MarkerSize',10,'LineWidth',1.5);
    plot(median(XValues),median(YValues), ListSymbol{4},'Color',MyColorMap(4,:),'MarkerSize',10,'LineWidth',1.5);
            
	XAxisStart=floor(min (XValues) * 1000) / 1000;
	XAxisEnd=ceil(max (XValues) * 1000) / 1000;
 	YAxisStart=floor(min (YValues) * 1000) / 1000;
	YAxisEnd=ceil(max (YValues) * 1000) / 1000;
	axis([XAxisStart XAxisEnd YAxisStart YAxisEnd]); % start and end values for axis x and y
	title(sprintf('%s',ListVideos{NdxVideo}),'fontsize',16);
 	xlabel(Measures{IdxMeasureX},'fontsize',16);
 	ylabel(Measures{IdxMeasureY},'fontsize',16);
    
    PdfFileName=sprintf('figuras/Performance_%s_ParetoFront_%s_%s.pdf',ListVideos{NdxVideo},Measures{IdxMeasureX},Measures{IdxMeasureY});
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[12 11]);
    set(gcf,'PaperPosition',[0 0 12 11]);
    %set(gcf, 'PaperPosition', [-0.8 0.3 17 9]); %Position the plot further to the left and down. Extend the plot to fill entire paper.
    %set(gcf, 'PaperSize', [15 9]); %Keep the same paper size
    set(gca,'fontsize',16);
    saveas(gcf,PdfFileName,'pdf');    
end


%% Select the optimal parameter value set

SelectedVideos=1:NumVideos;
NdxVideo = 1;
rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
numConf = size(ResultsNdxVideo,1); % calculate the number of configurations per each video
medianArray=zeros(NumVideos,0);

%configurationVotes = ones(numConf,1); % possible configurations
configurationVotes = ones(max(FullResults(:,22)),max(FullResults(:,23)),max(FullResults(:,24))); % possible configurations
configurationVotes2 = zeros(max(FullResults(:,22)),max(FullResults(:,23)),max(FullResults(:,24))); % possible configurations
configurationVotes3 = zeros(max(FullResults(:,22)),max(FullResults(:,23)),max(FullResults(:,24))); % possible configurations
configurationVotes4 = zeros(max(FullResults(:,22)),max(FullResults(:,23)),max(FullResults(:,24))); % possible configurations
for NdxVideo=SelectedVideos
    
% ColumnIDNumMedianFilters = 22;
% ColumnIDArea = 23;
% ColumnIDSubsamplingFactor = 24;

    % RANKING 1: product of the S/time from each video
    for NdxNumFilters=1:max(ResultsNdxVideo(:,ColumnIDNumMedianFilters))
        for NdxArea=1:max(ResultsNdxVideo(:,ColumnIDArea))
            for NdxSubsamplingFactor=1:max(ResultsNdxVideo(:,ColumnIDSubsamplingFactor))
                rowsFullResultsNdxVideo = find((FullResults(:,ColumnVideo) == NdxVideo) & (FullResults(:,ColumnIDSubsamplingFactor) == NdxSubsamplingFactor) & (FullResults(:,ColumnIDNumMedianFilters) == NdxNumFilters) & (FullResults(:,ColumnIDArea) == NdxArea));
                ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:);
                configurationVotes(NdxNumFilters,NdxArea,NdxSubsamplingFactor) = configurationVotes(NdxNumFilters,NdxArea,NdxSubsamplingFactor) * ResultsNdxVideo(1,IdxMeasureX) / ResultsNdxVideo(1,IdxMeasureY);
            end
        end
    end
    
    % RANKING 2: best time with the 5% best S from each video
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:); 
    
    % Sort rows of matrix
    ResultsNdxVideo = sortrows(ResultsNdxVideo,ColumnAcc) ;
    
    % Take the 5% of the rows according to the best accuracy
    ResultsNdxVideo = ResultsNdxVideo(round(numConf*0.95):numConf,:);
    
    % Take the row with the best time
    BestResultsNdxVideo = ResultsNdxVideo(find(ResultsNdxVideo(:,ColumnTime) == min(ResultsNdxVideo(:,ColumnTime))),:);
    
    % Increment the counter    
    i = BestResultsNdxVideo(:,ColumnIDNumMedianFilters);
    j = BestResultsNdxVideo(:,ColumnIDArea);
    k = BestResultsNdxVideo(:,ColumnIDSubsamplingFactor);
    configurationVotes2(i,j,k) = configurationVotes2(i,j,k) + 1;
    
    % RANKING 3: 5 best time with the 5% best S from each video
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:); 
    
    % Sort rows of matrix
    ResultsNdxVideo = sortrows(ResultsNdxVideo,ColumnAcc) ;
    
    % Take the 5% of the rows according to the best accuracy
    ResultsNdxVideo = ResultsNdxVideo(round(numConf*0.95):numConf,:);
    
    % For the 5 best configuration
    for cont=1:5
        % Take the row with the best time    
        ndx = find(ResultsNdxVideo(:,ColumnTime) == min(ResultsNdxVideo(:,ColumnTime)));
        BestResultsNdxVideo = ResultsNdxVideo(ndx,:);

        % Increment the counter
        i = BestResultsNdxVideo(:,ColumnIDNumMedianFilters);
        j = BestResultsNdxVideo(:,ColumnIDArea);
        k = BestResultsNdxVideo(:,ColumnIDSubsamplingFactor);
        configurationVotes3(i,j,k) = configurationVotes3(i,j,k) + 1;
        
        % Remove the row
        if ndx == 1 % first element
            ResultsNdxVideo = ResultsNdxVideo(2:end,:);
        elseif ndx == size(ResultsNdxVideo,1) % last element
            ResultsNdxVideo = ResultsNdxVideo(1:end-1,:);
        else
            ResultsNdxVideo = ResultsNdxVideo([1:ndx-1,ndx+1:end],:);
        end
    end 
    
    % RANKING 4: best time with the 5% best fmeasure from each video
    % select the results for the video NdxVideo
    rowsFullResultsNdxVideo = find(FullResults(:,ColumnVideo) == NdxVideo);
    ResultsNdxVideo = FullResults(rowsFullResultsNdxVideo,:); 
    
    % Sort rows of matrix
    ResultsNdxVideo = sortrows(ResultsNdxVideo,ColumnFmeasure) ;
    
    % Take the 5% of the rows according to the best fmeasure
    ResultsNdxVideo = ResultsNdxVideo(round(numConf*0.95):numConf,:);
    
    % Take the row with the best time
    BestResultsNdxVideo = ResultsNdxVideo(find(ResultsNdxVideo(:,ColumnTime) == min(ResultsNdxVideo(:,ColumnTime))),:);
    
    % Increment the counter
    i = BestResultsNdxVideo(:,ColumnIDNumMedianFilters);
    j = BestResultsNdxVideo(:,ColumnIDArea);
    k = BestResultsNdxVideo(:,ColumnIDSubsamplingFactor);
    configurationVotes4(i,j,k) = configurationVotes4(i,j,k) + 1;
end


NumMedianFilters = [1 2 3 5 7 10 15 20 30];
SubsamplingFactor = [0.01 0.05 0.1 0.25 0.5 0.75 1];
SmallestArea = [1 50  100 150 200 300  1  50  100  1  100 200  1];
LargestArea = [50 100 150 200 300 400 100 150 200 200 300 400 400];

% RANKING 2: BEST CONFIGURATION
bestScore = max(max(max(configurationVotes2)));
[NdxNumFilters,NdxArea,NdxSubsamplingFactor] = find(configurationVotes2 == bestScore);
%configurationVotes2(NdxSubsamplingFactor,NdxNumFilters,NdxArea)

fprintf('The best configuration is those with the following parameter values:\n');
fprintf('\t NumMedianFilters=%d\n',NumMedianFilters(NdxNumFilters));
fprintf('\t SubsamplingFactor=%0.2f\n',SubsamplingFactor(NdxSubsamplingFactor));
fprintf('\t Area=[%d..%d]\n',SmallestArea(NdxArea),LargestArea(NdxArea));
%    NumMedianFilters=5
% 	 SubsamplingFactor=0.01
% 	 Area=[50..100]

% RANKING 4: BEST CONFIGURATION
bestScore = max(max(max(configurationVotes4)));
[NdxNumFilters,NdxArea,NdxSubsamplingFactor] = find(configurationVotes4 == bestScore);
%configurationVotes4(NdxSubsamplingFactor,NdxNumFilters,NdxArea)

fprintf('The best configuration is those with the following parameter values:\n');
fprintf('\t NumMedianFilters=%d\n',NumMedianFilters(NdxNumFilters));
fprintf('\t SubsamplingFactor=%0.2f\n',SubsamplingFactor(NdxSubsamplingFactor));
fprintf('\t Area=[%d..%d]\n',SmallestArea(NdxArea),LargestArea(NdxArea));
% 	 NumMedianFilters=5
% 	 SubsamplingFactor=0.01
% 	 Area=[50..100]

%% Comparative between methods


close all