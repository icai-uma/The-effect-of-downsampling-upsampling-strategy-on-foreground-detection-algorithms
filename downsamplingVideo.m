%function []=downsamplingVideo(pathConfig)

%load(pathConfig);

function []=downsamplingVideo()

createConfig;

datasetResizedImages = sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),1);

if exist(params.PathCodeResultsDownsamplingFile) == 2 %file exists
    copyfile(params.PathResultsDownsamplingFile, params.PathCodeResultsDownsamplingFile);
    fprintf('Video %d-%d-%d already done.\r\n',params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling);    
else    
    fprintf('Configuration %d-%d-%d-%d-%d: Downsampling video...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    VideoFrame=imread(sprintf(params.VideoFileSpec,1));
    if params.TypeDownsampling<4
        NumRowsResizedImg=round(size(VideoFrame,1)*params.ResizeFactor);
        NumColsResizedImg=round(size(VideoFrame,2)*params.ResizeFactor);
    elseif params.TypeDownsampling==4
        n = round(1/params.ResizeFactor);
        NumRowsResizedImg = size(1:n:size(VideoFrame,1),2);
        NumColsResizedImg = size(1:n:size(VideoFrame,2),2);
    end
    frames = zeros(params.numFrames, NumRowsResizedImg, NumColsResizedImg, 3,'uint8');
    
    totalResizingFrameTime = 0;
    totalWritingFrameTime = 0;
    [stime,smem]=startTimeMem(params);
    
    % Resize video
    for NdxFrame=1:params.numFrames
        VideoFrame=imread(sprintf(params.VideoFileSpec,NdxFrame+params.deltaFrame));
        NumRowsImg=size(VideoFrame,1);
        NumColsImg=size(VideoFrame,2);
        
        % ResizeFactor reduces each dimension in these percentage
        switch params.TypeDownsampling
            case 1
                typeImresize = 'nearest';
                ResizedFrame=imresize(VideoFrame,[round(NumRowsImg*params.ResizeFactor) round(NumColsImg*params.ResizeFactor)],typeImresize);
            case 2
                typeImresize = 'bicubic';
                ResizedFrame=imresize(VideoFrame,[round(NumRowsImg*params.ResizeFactor) round(NumColsImg*params.ResizeFactor)],typeImresize);
            case 3
                typeImresize = 'bilinear';
                ResizedFrame=imresize(VideoFrame,[round(NumRowsImg*params.ResizeFactor) round(NumColsImg*params.ResizeFactor)],typeImresize);
            case 4 % 'imfilter'
                n = round(1/params.ResizeFactor);
                FrameFiltered=imfilter(VideoFrame,ones(n,n)/(n*n));
                ResizedFrame=FrameFiltered(1:n:end,1:n:end,:);
%             case 5 % SR
%                 OutputSize=round(params.ResizeFactor*[params.InputSize(1) params.InputSize(2)]);
%                 VideoFrame = double(VideoFrame)/255;
%                 ResizedFrame = MFTSuperresAuto(VideoFrame,params.ResizeFactor,OutputSize);
%                 %VideoFrame = imsharpen(VideoFrame);
        end
        [resizingFrameTime,mem]=endTimeMem(params,stime,smem); % we do not calculate the mem here
        totalResizingFrameTime = totalResizingFrameTime + resizingFrameTime; % do not measure the time for writing the file
        [writingstime,mem]=startTimeMem(params);
        %%%imwrite(ResizedFrame,sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame+params.deltaFrame));
        frames(NdxFrame+params.deltaFrame,:,:,:) = ResizedFrame;
        [writingFrameTime,mem]=endTimeMem(params,writingstime,mem);
        totalWritingFrameTime = totalWritingFrameTime + writingFrameTime;
        [stime,mem]=startTimeMem(params);
    end
    
    [resizingFrameTime,MemUsed]=endTimeMem(params,stime,smem);
    totalResizingFrameTime = totalResizingFrameTime + resizingFrameTime;
    CPUtime = totalResizingFrameTime;
    %MemUsed = emem - smem;
    
    fprintf('Video resized...\n');
    fprintf('CPUtime:%0.3f \n',CPUtime);
    fprintf('MemUsed:%d \n',MemUsed);
    
    %%% guardar resultados de memoria y tiempo!!!!
    Results=[];
    Results(end+1) = CPUtime;
    Results(end+1) = MemUsed;
    
    Results(end+1) = params.NdxVideo;
    Results(end+1) = params.NdxResizeFactor;
    Results(end+1) = params.NdxTypeDownsampling;
    
    pathOldTemp = strcat(params.PathDatasetResized,'..',sprintf('/temp_resultsDownsampling_%d_%d_%d.mat',params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling));
    save(pathOldTemp,'Results');
    pathNewTemp = strcat(params.PathDatasetResized,'..',sprintf('/resultsDownsampling_%d_%d_%d.mat',params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling));
    movefile(pathOldTemp, pathNewTemp);
    save(strcat(params.PathDatasetResized,'..','/frames.mat'), 'frames','-v7.3');
    save(params.PathCodeResultsDownsamplingFile,'Results');    
    fprintf('Configuration %d-%d-%d-%d-%d: Resizing video %d-%d-%d done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling,params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling);
    
end