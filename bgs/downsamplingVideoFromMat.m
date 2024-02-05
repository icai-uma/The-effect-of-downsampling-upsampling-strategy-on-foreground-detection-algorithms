%function []=downsamplingVideo(pathConfig)

%load(pathConfig);

function []=downsamplingVideoFromMat()

NdxMethod = 1; %no importa el valor
addpath('..');
createConfig_bgs;

load(strcat(params.PathDatasetResized,'..','/frames.mat'));

fprintf('Configuration %d-%d-%d-%d-%d: Downsampling video...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);

% Resize video
for NdxFrame=1:params.numFrames
    clearvars VideoFrame
    VideoFrame(1,:,:,:)=frames(NdxFrame,:,:,:);
    VideoFrame = squeeze(VideoFrame);      
    
    imwrite(VideoFrame,sprintf(strcat(params.PathDatasetResized,'/in%06d.jpg'),NdxFrame+params.deltaFrame));    
end

fprintf('Configuration %d-%d-%d-%d-%d: Resizing video %d-%d-%d done...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling,params.NdxVideo,params.NdxResizeFactor,params.NdxTypeDownsampling);

end