%function []=upsamplingSegmentation(pathConfig)

%load(pathConfig);

function []=upsamplingSegmentation4k()

isUpsampling = 1;
createConfig4k;

rng('default');

if exist(params.PathCodeResultsUpsamplingFile) == 2 %file exists
    copyfile(params.PathResultsUpsamplingFile, params.PathCodeResultsUpsamplingFile);
    fprintf('Configuration %d-%d-%d-%d-%d: Upsampling already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
else
    
    % wait until the resized dataset exists
    fprintf('Configuration %d-%d-%d-%d-%d: Waiting for the segmentation...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    % check segmentation results file
%     while (~exist(params.PathResultsSegmentationFile,'file'))
%         pause(0.001);
%     end
	disp(params.PathResultsSegmentationFile);
    if (~exist(params.PathResultsSegmentationFile,'file'))
        disp('segmentation results file does not exist');
        exit;
    end
    
    %%%load(strcat(params.PathDatasetSegmentation,'/segmentedFrames.mat')); % load video frames
    
    fprintf('Configuration %d-%d-%d-%d-%d: Executing upsampling...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
	VideoFrame=imread(sprintf(params.PathDatasetSegmented,1));
    %%%VideoFrame=double(segmentedFrames(params.deltaFrame+1,:,:,:));
    %%%VideoFrame = squeeze(VideoFrame);
    %segmentedFrames = zeros(params.numFrames, size(VideoFrame,1), size(VideoFrame,2),'logical');
    upsampledFrames = false(params.numFrames, params.InputSize(1), params.InputSize(2));
    
    totalResizingFrameTime = 0;
    totalWritingFrameTime = 0;
    [stime,smem]=startTimeMem(params);
    
    
    % resize video
    for NdxFrame=100+1:params.numFrames % the first 100 frames are used in the training process in the method
        VideoFrame=imread(sprintf(params.PathDatasetSegmented,NdxFrame));
        %%%clearvars VideoFrame
        %%%VideoFrame(1,:,:,:)=double(segmentedFrames(NdxFrame,:,:,:));
        %%%VideoFrame = squeeze(VideoFrame);
        switch params.TypeUpsampling
            case 1 
                VideoFrame=imresize(VideoFrame,[params.InputSize(1) params.InputSize(2)],'bicubic');
            case 2 % SR
                OutputSize=[params.InputSize(1) params.InputSize(2)];
                VideoFrame = double(VideoFrame)/255;
                VideoFrame = MFTSuperresAuto(VideoFrame,1/params.ResizeFactor,OutputSize);
                VideoFrame = VideoFrame(:,:,1);
                VideoFrame = logical(VideoFrame);
                %VideoFrame = imsharpen(VideoFrame);
        end
        [resizingFrameTime,mem]=endTimeMem(params,stime,smem); % we do not calculate the mem here
        totalResizingFrameTime = totalResizingFrameTime + resizingFrameTime; % do not measure the time for writing the file
        [writingstime,mem]=startTimeMem(params);
        imwrite(VideoFrame,sprintf(params.PathDatasetUpsampled,NdxFrame));
		disp(NdxFrame);
        upsampledFrames(NdxFrame+params.deltaFrame,:,:) = VideoFrame;
        [writingFrameTime,mem]=endTimeMem(params,writingstime,mem);
        totalWritingFrameTime = totalWritingFrameTime + writingFrameTime;
        [stime,mem]=startTimeMem(params);
    end
    
    
    [resizingFrameTime,MemUsed]=endTimeMem(params,stime,smem);
    totalResizingFrameTime = totalResizingFrameTime + resizingFrameTime;
    CPUtime = totalResizingFrameTime;
    %MemUsed = emem - smem;
    
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
    
    pathOldTemp = strcat(params.PathDatasetResults,sprintf('/temp_resultsUpsampling_%d_%d_%d_%d_%d.mat',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling));
    save(pathOldTemp,'Results');
    movefile(pathOldTemp, params.PathResultsUpsamplingFile);
	disp(strcat(params.PathDatasetUpsampling,'/upsampledFrames.mat'));
    save(strcat(params.PathDatasetUpsampling,'/upsampledFrames.mat'), 'upsampledFrames','-v7.3');
	disp(params.PathCodeResultsUpsamplingFile);
    save(params.PathCodeResultsUpsamplingFile,'Results');
    fprintf('Configuration %d-%d-%d-%d-%d: Upsampling done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
end
