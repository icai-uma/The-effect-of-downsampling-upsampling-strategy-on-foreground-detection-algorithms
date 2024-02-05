% Foreground Detection by Competitive Learning for Varying Input Distributions
% International Journal of Neural Systems 
% DOI: 10.1142/S0129065717500563  
% Authors: Ezequiel L�pez-Rubio, Miguel A. Molina-Cabello, Rafael M. Luque-Baena, Enrique Dom�nguez
% Date: July 2018 

function []=bgs4k()

NdxMethod = 15; %%%%%%%%%%

NameMethod{4} = 'wren';
NameMethod{5} = 'grimson';
NameMethod{6} = 'zivkovic';
NameMethod{7} = 'temporal_median';
NameMethod{8} = 'eigenbackground';
NameMethod{9} = 'fuzzy_choquet_integral'; %%% no funciona
NameMethod{10} = 'adaptative_som';
NameMethod{11} = 'fuzzy_adaptative_som';
NameMethod{12} = 'KDE';
NameMethod{13} = 'SUBSENSE';
NameMethod{14} = 'LOBSTER';
NameMethod{15} = 'PAWCS';

addpath('..');
createConfig_bgs4k;

if exist(params.PathCodeResultsSegmentationFile) == 2 %file exists
    copyfile(params.PathResultsSegmentationFile, params.PathCodeResultsSegmentationFile);
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
else
    
    % wait until the resized dataset exists
    fprintf('Configuration %d-%d-%d-%d-%d: Waiting for the resized dataset...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    if (~exist(params.PathResultsDownsamplingFile,'file'))
        disp('downsampling results file does not exist');
        %exit;
    end
    
%%%%%%load(strcat(params.PathDatasetResized,'..','/frames.mat')); % load video frames
    
    fprintf('Configuration %d-%d-%d-%d-%d: Executing segmentation method %s...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling,NameMethod{NdxMethod});
    
    %%%[stime,smem]=startTimeMem(params); % no funciona con la llamada system(command);
    %command = '~/unidad_z/Mis\ Documentos/experiments/bgslibrary_modified/build/bgs_demo2 ./dataset/pedestrians/input/ in .jpg 6 zivkovic ./output/zivkovic/pedestrians/ 1099'

    %executable = '/mnt/home/users/tic_163_uma/jorgegarcia/unidad_z/Mis\ Documentos/experiments/bgslibrary_modified/build/bgs_demo2';
    executable = '/mnt/home/users/tic_163_uma/jorgegarcia/unidad_z/Mis\ Documentos/experiments/bgslibrary_modified_with_mem_and_time/build/bgs_demo2';
    %videoPath = strcat(params.MatlabProjectsDirectory,'datasets/dataset2014/dataset/',VideoFileSpec{NdxVideo},'/input/');
    videoPath = params.PathDatasetResized;
    %outputPath = '/mnt/home/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/prueba/';
    outputPath = strcat(params.PathDatasetSegmentation,'/');
    command = sprintf('%s %s in .jpg 6 %s %s %d', executable, videoPath, NameMethod{NdxMethod}, outputPath, numFrames{NdxVideo});
    command
    tic;
    [status,cmdout] = system(command);
    status
    cmdout
    
    fileID = fopen(strcat(outputPath,'resources.txt'),'r');
    A = fscanf(fileID,'%f');
    CPUtime = A(1);
    MemUsed = A(2);
    fclose(fileID);
    
    %CPUtime=toc;
    %MemUsed=0;
    
    %%%[CPUtime,MemUsed]=endTimeMem(params,stime,smem); % no funciona con la llamada system(command);

    
    fprintf('CPUtime:%0.3f \n',CPUtime);
    fprintf('MemUsed:%d \n',MemUsed);
    
    %%% guardar resultados de memoria y tiempo!!!!
    Results=[];
    Results(end+1) = CPUtime;
    Results(end+1) = MemUsed;
    
    Results(end+1) = params.NdxVideo;
    Results(end+1) = params.NdxMethod;
    Results(end+1) = params.NdxResizeFactor;
    Results(end+1) = params.NdxTypeDownsampling;
    
    pathOldTemp = strcat(params.PathDatasetResults,sprintf('/temp_resultsSegmentation_%d_%d_%d_%d_%d.mat',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling));
    save(pathOldTemp,'Results');
    movefile(pathOldTemp, params.PathResultsSegmentationFile);
    
    save(params.PathCodeResultsSegmentationFile,'Results');
    params.PathCodeResultsSegmentationFile
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    VideoFrame=imread(sprintf(strcat(params.PathDatasetSegmentation,'/bin%06d.png'),1));
    segmentedFrames = zeros(params.numFrames, size(VideoFrame,1), size(VideoFrame,2),'uint8');
    
    % copy segmented images to .mat
    for NdxFrame=1:params.numFrames
        VideoFrame=imread(sprintf(strcat(params.PathDatasetSegmentation,'/bin%06d.png'),NdxFrame));
		if size(VideoFrame,3)==3
			VideoFrame = rgb2gray(VideoFrame);
		end
        segmentedFrames(NdxFrame+params.deltaFrame,:,:) = VideoFrame;
        filename = sprintf(strcat(params.PathDatasetSegmentation,'/bin%06d.png'),NdxFrame);
        delete(filename);
    end
    save(strcat(params.PathDatasetSegmentation,'/segmentedFrames.mat'), 'segmentedFrames','-v7.3');
    save(strcat(params.MatlabProjectsDirectory,'resizeStudy4k/',sprintf('segmentedFrames_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling)), 'segmentedFrames','-v7.3');
    fprintf('Configuration %d-%d-%d-%d-%d: Compressing segmentation done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling,params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling);
end


