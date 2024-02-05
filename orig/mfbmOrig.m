%function []=AutomatedTestBMsinglethread(SelectedFeatures,VideoFileSpec,deltaFrame,numFrames,epsilon)

function []=mfbmOrig()
% Batch mode background modeling test, single thread version
NdxMethod = 1;
addpath('../');
addpath('../mfbm/');
createConfigOrig;

rng('default');
% Batch mode background modeling test, single thread version

if exist(params.PathCodeResultsSegmentationFile) == 2 %file exists
    copyfile(params.PathResultsSegmentationFile, params.PathCodeResultsSegmentationFile);
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
else
    
    % wait until the resized dataset exists
    fprintf('Configuration %d-%d-%d-%d-%d: Waiting for the resized dataset...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
        
    load(strcat(params.VideoPath,'frames.mat')); % load video frames
    
    fprintf('Configuration %d-%d-%d-%d-%d: Executing segmentation method MFBM...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    VideoFrame=double(frames(params.deltaFrame+1,:,:,:));
    VideoFrame = squeeze(VideoFrame);
    %segmentedFrames = zeros(params.numFrames, size(VideoFrame,1), size(VideoFrame,2),'logical');
    segmentedFrames = false(params.numFrames, size(VideoFrame,1), size(VideoFrame,2));
    
	totalSegmentingFrameTime = 0;
    totalWritingFrameTime = 0;
    [stime,smem]=startTimeMem(params);
    
    SelectedFeatures = params.SelectedFeatures;
    VideoFileSpec = params.VideoFileSpec;
    deltaFrame = params.deltaFrame;
    numFrames = params.numFrames;
    epsilon = params.epsilon;
    
    % Create the structures of the stochastic approximation model
    %VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),params.deltaFrame+1)));
    clearvars VideoFrame
    VideoFrame(1,:,:,:)=double(frames(params.deltaFrame+1,:,:,:));
    VideoFrame = squeeze(VideoFrame);
    FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
    model = createBM(FeatureFrame);
    model.Epsilon=epsilon;
    
    % model.NumPatterns=43;
    
    % Allocate scape for the set of images to initialise the model
    FirstFrames = zeros(size(FeatureFrame,1),size(FeatureFrame,2),size(FeatureFrame,3),model.NumPatterns);
    FirstFrames(:,:,:,1) = FeatureFrame;
    
    % Store the frames
    for NdxFrame=2:model.NumPatterns
        %VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame)));
        clearvars VideoFrame
        VideoFrame(1,:,:,:)=double(frames(NdxFrame,:,:,:));
        VideoFrame = squeeze(VideoFrame);
        FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
        FirstFrames(:,:,:,NdxFrame) = FeatureFrame;
    end
    
    % Initialize the model using a set of frames
    model = initializeBM_MEX(model,FirstFrames);
    
    % Estimate the noise of the sequence
    model.Noise = estimateNoise(model);
    
    for NdxFrame=model.NumPatterns+1:numFrames
        %VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame)));
        clearvars VideoFrame
        VideoFrame(1,:,:,:)=double(frames(NdxFrame,:,:,:));
        VideoFrame = squeeze(VideoFrame);
        %tic
        FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
        [model,imMask,resp]=updateBM_MEXsingle(model,FeatureFrame);
        %toc
        %fprintf('Frame %d processed.\r\n',NdxFrame);
        %imwrite(imMask<0.5,(sprintf(strcat('../../../../proyectos_matlab/Videos/ImagenesSegmentadas','/in%06d.jpg'),deltaFrame+NdxFrame)));
        
        imMask = imMask<0.5;
        %%%imwrite(imMask,sprintf(params.PathDatasetSegmented,deltaFrame+NdxFrame));
		[segmentingFrameTime,mem]=endTimeMem(params,stime,smem); % we do not calculate the mem here
        totalSegmentingFrameTime = totalSegmentingFrameTime + segmentingFrameTime; % do not measure the time for writing the file
        [writingstime,mem]=startTimeMem(params);		
        segmentedFrames(NdxFrame+deltaFrame,:,:) = imMask;
		[writingFrameTime,mem]=endTimeMem(params,writingstime,mem);
        totalWritingFrameTime = totalWritingFrameTime + writingFrameTime;
        [stime,mem]=startTimeMem(params);
    end
    
    
    [segmentingFrameTime,MemUsed]=endTimeMem(params,stime,smem);
    totalSegmentingFrameTime = totalSegmentingFrameTime + segmentingFrameTime;
    CPUtime = totalSegmentingFrameTime;
    %CPUtime = etime;
    %MemUsed = emem;
    
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