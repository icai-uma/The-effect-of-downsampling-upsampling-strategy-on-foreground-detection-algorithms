function []=AutomatedTestBM(SelectedFeatures,VideoFileSpec,deltaFrame,numFrames,epsilon)
% Batch mode background modeling test

% Create the structures of the stochastic approximation model
VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+1)));
FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
model = createBM(FeatureFrame);
model.Epsilon=epsilon;

% model.NumPatterns=43;

% Allocate scape for the set of images to initialise the model 
FirstFrames = zeros(size(FeatureFrame,1),size(FeatureFrame,2),size(FeatureFrame,3),model.NumPatterns);
FirstFrames(:,:,:,1) = FeatureFrame;

% Store the frames
for NdxFrame=2:model.NumPatterns
    VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+NdxFrame)));
    FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
    FirstFrames(:,:,:,NdxFrame) = FeatureFrame;
end

% Initialize the model using a set of frames
model = initializeBM_MEX(model,FirstFrames); 

% Estimate the noise of the sequence
model.Noise = estimateNoise(model);

for NdxFrame=model.NumPatterns+1:numFrames
    VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+NdxFrame)));
    FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
    [model,imMask,resp]=updateBM_MEX(model,FeatureFrame);
    
    subplot(1,2,1),imshow(uint8(VideoFrame));
    subplot(1,2,2),imshow(imMask<0.5);
    title(NdxFrame);
    pause(0.001);
end

