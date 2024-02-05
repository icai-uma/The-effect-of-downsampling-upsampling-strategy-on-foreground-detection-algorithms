% execute in Windows
function []=processResultsMethodCAMOUOW(selectedMethod)

disp('Starting');
warning off
rng('default');

if strcmp(selectedMethod,'mfbm')
    NdxMethod = 1;
elseif strcmp(selectedMethod,'clvid')
    NdxMethod = 2;
elseif strcmp(selectedMethod,'fsom')
    NdxMethod = 3;
elseif strcmp(selectedMethod,'wren')
    NdxMethod = 4;
elseif strcmp(selectedMethod,'grimson')
    NdxMethod = 5;
elseif strcmp(selectedMethod,'zivkovic')
    NdxMethod = 6;
elseif strcmp(selectedMethod,'temporal_median')
    NdxMethod = 7;
elseif strcmp(selectedMethod,'eigenbackground')
    NdxMethod = 8;
elseif strcmp(selectedMethod,'fuzzy_choquet_integral')
    NdxMethod = 9;
elseif strcmp(selectedMethod,'adaptative_som')
    NdxMethod = 10;
elseif strcmp(selectedMethod,'fuzzy_adaptative_som')
    NdxMethod = 11;
elseif strcmp(selectedMethod,'KDE')
    NdxMethod = 12;
elseif strcmp(selectedMethod,'SUBSENSE')
    NdxMethod = 13;
elseif strcmp(selectedMethod,'LOBSTER')
    NdxMethod = 14;
elseif strcmp(selectedMethod,'PAWCS')
    NdxMethod = 15;    
else
    disp('Error: method not found!');
    exit;
end

% Video to be processed

VideoFileSpec{1}='video1';
deltaFrame{1}=0;
numFrames{1}=373;
InputSize{1}=[1200 1600];

VideoFileSpec{2}='video2';
deltaFrame{2}=0;
numFrames{2}=178;
InputSize{2}=[1200 1600];

VideoFileSpec{3}='video3';
deltaFrame{3}=0;
numFrames{3}=373;
InputSize{3}=[1200 1600];

VideoFileSpec{4}='video4';
deltaFrame{4}=0;
numFrames{4}=373;
InputSize{4}=[1200 1600];

VideoFileSpec{5}='video5';
deltaFrame{5}=0;
numFrames{5}=373;
InputSize{5}=[1200 1600];

VideoFileSpec{6}='video6';
deltaFrame{6}=0;
numFrames{6}=373;
InputSize{6}=[1200 1600];

VideoFileSpec{7}='video7';
deltaFrame{7}=0;
numFrames{7}=274;
InputSize{7}=[1080 1920];

VideoFileSpec{8}='video8';
deltaFrame{8}=0;
numFrames{8}=468;
InputSize{8}=[1080 1920];

VideoFileSpec{9}='video9';
deltaFrame{9}=0;
numFrames{9}=290;
InputSize{9}=[1080 1920];

VideoFileSpec{10}='video10';
deltaFrame{10}=0;
numFrames{10}=460;
InputSize{10}=[1080 1920];

Method = [1 2 3]; % {mfbm, cl-vid, fsom}
TypeDownsampling = [1 2 3 4]; % {imresize ('nearest', 'bicubic', 'bilinear'), imfilter}
ResizeFactor = [0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125];
% TypeUpsampling = [1 2]; % {imresize ('bicubic'), SR}
TypeUpsampling = [1]; % {imresize ('bicubic'), SR}


NumVideos = 10;
NumMethods = numel(Method);
NumTypeDownsamplings = numel(TypeDownsampling);
NumResizeFactors = numel(ResizeFactor);
NumTypeUpsamplings = numel(TypeUpsampling);

if isunix
    %params.MatlabProjectsDirectory = '/home/icai21/proyectos_matlab/';
    params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
elseif ispc
    params.MatlabProjectsDirectory = 'C:/proyectos_matlab/';
end

resultsSegmentation = [];
NdxResultsSegmentation = 1;
unexistingResultsSegmentation = [];
ndxUnexistingResultsSegmentation = 1;

resultsUpsampling = [];
NdxResultsUpsampling = 1;
unexistingResultsUpsampling = [];
ndxUnexistingResultsUpsampling = 1;

resultsStats=[];
NdxResultsStats = 1;
unexistingResultsStats=[];
ndxUnexistingResultsStats = 1;

for NdxVideo=1:NumVideos
    for NdxTypeDownsampling=1:NumTypeDownsamplings
        for NdxResizeFactor=1:NumResizeFactors
            NdxTypeUpsampling = 1;
            params.PathResultsSegmentationFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsSegmentation_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));            
            if exist(params.PathResultsSegmentationFile) == 0
                fprintf('resultsSegmentation_%d_%d_%d_%d_%d not found.\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
                unexistingResultsSegmentation(ndxUnexistingResultsSegmentation,1:5)=[NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling];
                ndxUnexistingResultsSegmentation = ndxUnexistingResultsSegmentation + 1;
                %continue;
            else
                load (params.PathResultsSegmentationFile);
                resultsSegmentation(NdxResultsSegmentation,1:6) = Results(1,:);
                NdxResultsSegmentation = NdxResultsSegmentation + 1;
            end
            
            for NdxTypeUpsampling=1:NumTypeUpsamplings
                params.PathResultsUpsamplingFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsUpsampling_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
                params.PathResultsStatsFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsStats_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
                
                if exist(params.PathResultsUpsamplingFile) == 0
                    fprintf('resultsUpsampling_%d_%d_%d_%d_%d not found.\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
                    unexistingResultsUpsampling(ndxUnexistingResultsUpsampling,1:5)=[NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling];
                    ndxUnexistingResultsUpsampling = ndxUnexistingResultsUpsampling + 1;
                    continue;
                end
                load (params.PathResultsUpsamplingFile);
                resultsUpsampling(NdxResultsUpsampling,1:6) = Results(1,:);
                resultsUpsampling(NdxResultsUpsampling,7) = NdxTypeUpsampling;
                NdxResultsUpsampling = NdxResultsUpsampling + 1;
                
                if exist(params.PathResultsStatsFile) == 0
                    fprintf('resultsStats_%d_%d_%d_%d_%d not found.\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
                    unexistingResultsStats(ndxUnexistingResultsStats,1:5)=[NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling];
                    ndxUnexistingResultsStats = ndxUnexistingResultsStats + 1;
                    continue;
                end
                load (params.PathResultsStatsFile);
                resultsStats(NdxResultsStats,1:19) = Results(1,:);
                NdxResultsStats = NdxResultsStats + 1;
            end
        end
    end
end

save(strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/','joinedResultsSegmentation_',selectedMethod,'.mat'),'resultsSegmentation');
save(strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/','joinedResultsUpsampling_',selectedMethod,'.mat'),'resultsUpsampling');
save(strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/','joinedResultsStats_',selectedMethod,'.mat'),'resultsStats');