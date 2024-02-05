% Foreground Detection by Competitive Learning for Varying Input Distributions
% International Journal of Neural Systems 
% DOI: 10.1142/S0129065717500563  
% Authors: Ezequiel L�pez-Rubio, Miguel A. Molina-Cabello, Rafael M. Luque-Baena, Enrique Dom�nguez
% Date: July 2018 

%function []=cl_vid(pathConfig)

%load(pathConfig);

function []=cl_vid()

addpath('..');
createConfig;

if exist(params.PathResultsSegmentationFile) == 2 %file exists
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation already done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
else
    
    % wait until the resized dataset exists
    fprintf('Configuration %d-%d-%d-%d-%d: Waiting for the resized dataset...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    % check downsampling results file
    while (~exist(params.PathResultsDownsamplingFile,'file'))
        pause(0.001);
    end
    
    fprintf('Configuration %d-%d-%d-%d-%d: Executing segmentation method CL-VID...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
    [stime,smem]=startTimeMem(params);

VideoFileSpec = params.VideoFileSpec;
deltaFrame = params.deltaFrame;
numFrames = params.numFrames;

% Create the structures of the stochastic approximation model
VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),params.deltaFrame+1)));
FeatureFrame=VideoFrame/255;
model = createModel(FeatureFrame,params);

% Allocate scape for the set of images to initialise the model 
FirstFrames = zeros(size(FeatureFrame,1),size(FeatureFrame,2),size(FeatureFrame,3),model.NumPatterns);
FirstFrames(:,:,:,1) = FeatureFrame;

% Store the frames
for NdxFrame=2:model.NumPatterns
    VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame)));
    FeatureFrame=VideoFrame/255;
    FirstFrames(:,:,:,NdxFrame) = FeatureFrame;
end

% Initialize the model using a set of frames
MeanFirstFrames = median(FirstFrames,4);
model.Mu = repmat(MeanFirstFrames, [1 1 1 model.NumNeurons]);
model.Mu = model.Mu + 0.001 * randn (size(model.Mu));
model.Mu=shiftdim(model.Mu,2);

% Estimate the noise of the sequence
model.Noise = estimateNoise(model);

for NdxFrame=model.NumPatterns+1:numFrames
    VideoFrame=double(imread(sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame)));
    FeatureFrame=VideoFrame/255;
    [model,imMask,resp,imDistances]=updateBM_MEX(model,FeatureFrame);
	
	imMask = medfilt2(imMask, [5 5]);    
    imMask = double(imMask < 0.5);
    
    s = strel('disk',5);
    ID = imdilate(imMask,s);
    imMask = imerode(ID,s);
    
    % Fill holes (size 1) and remove objects with minimum area (10 pixels size)
    imMask = bwmorph(imMask,'majority');
    imMask = removeSpuriousObjects(imMask, 10);
    
    imwrite(imMask,sprintf(params.PathDatasetSegmented,deltaFrame+NdxFrame));
    
end

    [etime,emem]=endTimeMem(params,stime);
    CPUtime = etime;
    MemUsed = emem - smem;
    
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
    fprintf('Configuration %d-%d-%d-%d-%d: Segmentation done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    
end

