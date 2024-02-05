% Demo code for the paper
% Foreground Detection in Video Sequences with Probabilistic
% Self-Organising Maps
% International Journal of Neural Systems. ISSN: 0129-0657. DOI: 10.1142/S012906571100281X
% Coded by R.M.Luque and Ezequiel Lopez-Rubio -- June 2011

%function []=fsom(pathConfig)
% Batch mode background modeling test

%load(pathConfig);


function []=fsom()
% Batch mode background modeling test

addpath('..');
createConfig;

if exist(params.PathCodeResultsSegmentationFile) == 2 %file exists
    copyfile(params.PathResultsSegmentationFile, params.PathCodeResultsSegmentationFile);
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
else
    
    % wait until the resized dataset exists
    fprintf('Configuration %d-%d-%d-%d-%d: Waiting for the resized dataset...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    % check downsampling results file
%     while (~exist(params.PathResultsDownsamplingFile,'file'))
%         pause(0.001);
%     end
    if (~exist(params.PathResultsDownsamplingFile,'file'))
        disp('downsampling results file does not exist');
        exit;
    end
    
    load(strcat(params.PathDatasetResized,'..','/frames.mat')); % load video frames
    
    fprintf('Configuration %d-%d-%d-%d-%d: Executing segmentation method FSOM...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    totalSegmentingFrameTime = 0;
    totalWritingFrameTime = 0;
    [stime,smem]=startTimeMem(params);
    
    
    % Load the video to analyse
    disp('Loading the input sequence...');        

    NumFrames = params.numFrames;    
       
    % Create the structures of the stochastic approximation model
    disp('Creating the structures of the probabilistic self organising network model...');
    
    %FirstFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),params.deltaFrame+1)));
    VideoFrame(1,:,:,:)=double(frames(params.deltaFrame+1,:,:,:));
    VideoFrame = squeeze(VideoFrame);
    FirstFrame = VideoFrame;
    model = createSOMModel(FirstFrame);
    model.LastFrame = NumFrames;
    
    % Allocate scape for the set of images to initialise the model
    images = zeros(size(FirstFrame,1),size(FirstFrame,2),size(FirstFrame,3),model.NumPatterns);
    images(:,:,:,1) = uint8(FirstFrame);
    
    % Store the frames
    for i=2:model.NumPatterns
        %NextFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),i)));
        clearvars VideoFrame
        VideoFrame(1,:,:,:)=double(frames(i,:,:,:));
        VideoFrame = squeeze(VideoFrame);
        NextFrame = VideoFrame;
        images(:,:,:,i) = uint8(NextFrame);
    end
    images = uint8(images);
    
    disp('Initialising the model...');
    % Initialize the model using a set of frames
    model = initializeSOMModel(model,images);    
    
    disp('Analysing the model...');    
    
    for i=model.NumPatterns+1:NumFrames
        
        %NextFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),i)));
        clearvars VideoFrame
        VideoFrame(1,:,:,:)=double(frames(i,:,:,:));
        VideoFrame = squeeze(VideoFrame);
        NextFrame = VideoFrame;
        
        Coef=CoefSOM(i,model);
        model=TurboSOMMEX(model,double(NextFrame),Coef);
        
        imMask = double(model.imMask >= 0.5);
        
        % Fill holes (size 1) y remove objects with minimum area
        imMaskFFSOM = imMask;
        imMaskFFSOM = bwmorph(imMaskFFSOM,'majority');
        imMaskFFSOM = removeSpuriousObjects(imMaskFFSOM, model.MaximumArea);
        
        %imwrite(imMaskFFSOM,sprintf(params.PathDatasetSegmented,params.deltaFrame+i));
        [segmentingFrameTime,mem]=endTimeMem(params,stime,smem); % we do not calculate the mem here
        totalSegmentingFrameTime = totalSegmentingFrameTime + segmentingFrameTime; % do not measure the time for writing the file
        [writingstime,mem]=startTimeMem(params);		
        segmentedFrames(i,:,:) = imMaskFFSOM;
        [writingFrameTime,mem]=endTimeMem(params,writingstime,mem);
        totalWritingFrameTime = totalWritingFrameTime + writingFrameTime;
        [stime,mem]=startTimeMem(params);        
        
        pause(0.01);
        
    end
    
    disp('End of the process');    
    
    [segmentingFrameTime,MemUsed]=endTimeMem(params,stime,smem);
    totalSegmentingFrameTime = totalSegmentingFrameTime + segmentingFrameTime;
    CPUtime = totalSegmentingFrameTime;
    
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
    save(strcat(params.PathDatasetSegmentation,'/segmentedFrames.mat'), 'segmentedFrames','-v7.3');
    save(params.PathCodeResultsSegmentationFile,'Results');
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
end