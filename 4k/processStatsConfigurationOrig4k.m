%function []=statsConfiguration(pathConfig)

%load(pathConfig);

function []=processStatsConfigurationOrig4k()

isUpsampling = 1;

for NdxVideo=1:31
    createConfigOrigProcess4k;
    addpath('..');
    
    if exist(params.PathCodeResultsStatsFile) == 2 %file exists
        copyfile(params.PathResultsStatsFile, params.PathCodeResultsStatsFile);
        fprintf('Configuration %d-%d-%d-%d-%d: Stats already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    else
        if exist(strcat(params.PathDatasetSegmentation,'/segmentedFrames.mat')) ~= 2 %file no exists
            disp('error');
            continue;
        end
        load(strcat(params.PathDatasetSegmentation,'/segmentedFrames.mat'));
        
        fprintf('Configuration %d-%d-%d-%d-%d: Executing stats...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
        
        % read temporalROI.txt
        fileID = fopen(params.PathDatasetVideoROI,'r');
        roi = fscanf(fileID,'%d');
        
        
        % resize video
        cont = 1;
        statsFrame = [0 0 0 0 0 0 0];
        for NdxFrame=roi(1):roi(2) % roi(1) is the first image with GT and roi(2) is the last one
            %BW=imread(sprintf(params.PathDatasetUpsampled,NdxFrame));
            clearvars BW
            BW(1,:,:,:)=segmentedFrames(NdxFrame,:,:,:);
            BW = squeeze(BW);
            GT=imread(sprintf(params.PathDatasetGT,NdxFrame));
            statsFrame(cont,1:7) = measureCDnet(BW, GT);
            cont = cont + 1;
        end
        
        meanStatsFrame = mean(statsFrame(:,1:7));
        desvStatsFrame = std(statsFrame(:,1:7));
        
        %%% guardar resultados de memoria y tiempo!!!!
        Results=[meanStatsFrame desvStatsFrame params.NdxVideo params.NdxMethod params.NdxResizeFactor params.NdxTypeDownsampling params.NdxTypeUpsampling];
        
        save(params.PathResultsStatsFile,'Results');
        save(params.PathCodeResultsStatsFile,'Results');
        fprintf('Configuration %d-%d-%d-%d-%d: Stats done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
        
    end
    
    % delete images in order to alleviate memory
    if params.NdxTypeUpsampling == 1
        [stat, mess, id] = rmdir( params.PathDatasetSegmentation, 's'); % Delete the directory and its files
    end
    fprintf('Configuration %d-%d-%d-%d-%d: Image folders removed...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
end
