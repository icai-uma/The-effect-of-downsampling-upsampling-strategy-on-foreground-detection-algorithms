function []=upsamplingDataset4k()

% Para que no se apelotonen los procesos en el servidor de licencias
ListToolBoxes={'Image_Toolbox'};
for NdxTool=1:numel(ListToolBoxes)
	while ( license('checkout',ListToolBoxes{NdxTool}) ~= 1 )
		fprintf('License for %s not found.\r\n',ListToolBoxes{NdxTool});
		pause(rand(1)*60);
	end
	fprintf('License for %s found.\r\n',ListToolBoxes{NdxTool});
	%pause(rand(1)*60);
end

addpath('../');

% Video to be processed
VideoFileSpec{1}='baseline/highway';
deltaFrame{1}=0;
numFrames{1}=1700;
InputSize{1}=[240 320];

VideoFileSpec{2}='baseline/office';
deltaFrame{2}=0;
numFrames{2}=2050;
InputSize{2}=[240 360];

VideoFileSpec{3}='baseline/pedestrians';
deltaFrame{3}=0;
numFrames{3}=1099;
InputSize{3}=[240 360];

VideoFileSpec{4}='baseline/PETS2006';
deltaFrame{4}=0;
numFrames{4}=1200;
InputSize{4}=[576 720];

if isunix
    params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
elseif ispc
    params.MatlabProjectsDirectory = 'C:/proyectos_matlab/';
end

MyArrayID=getenv('SLURM_ARRAY_TASK_ID');
ArrayIDNumber=sscanf(MyArrayID,'%d');
fprintf('\r\nTask %d starting.\r\n',ArrayIDNumber);
NumProcesos = 1000;
NumVideos = 4;
[NdxProceso,NdxVideo]=ind2sub([floor(NumProcesos/NumVideos) NumVideos],ArrayIDNumber);
NdxProceso = mod(NdxProceso, (NumProcesos/NumVideos));
if NdxProceso==0
	NdxProceso = floor(NumProcesos/NumVideos);
end
selectedFramesIni = (NdxProceso-1)*ceil(numFrames{NdxVideo}/floor(NumProcesos/NumVideos))+1;
selectedFramesFin = NdxProceso*ceil(numFrames{NdxVideo}/floor(NumProcesos/NumVideos));

if selectedFramesIni>numFrames{NdxVideo}
    fprintf('Video %d [%d-%d]: Ini out of range. Exit...\r\n',NdxVideo,selectedFramesIni,selectedFramesFin);
    exit;
end
if selectedFramesFin>numFrames{NdxVideo}
    fprintf('Video %d [%d-%d]: End out of range. Edited...\r\n',NdxVideo,selectedFramesIni,selectedFramesFin);
    selectedFramesFin = numFrames{NdxVideo};    
end

selectedFrames = selectedFramesIni:selectedFramesFin;

fprintf('Video %d [%d-%d]: Creating structures...\r\n',NdxVideo,selectedFramesIni,selectedFramesFin);



params.VideoPath = strcat(params.MatlabProjectsDirectory,'datasets/dataset2014/dataset/',VideoFileSpec{NdxVideo},'/');
params.VideoPath4k = strcat(params.MatlabProjectsDirectory,'datasets/dataset2014/dataset4k/',VideoFileSpec{NdxVideo},'/');
params.VideoFileSpec = strcat(params.VideoPath,'input/'); % in%06d.jpg
params.VideoFileSpec4k = strcat(params.VideoPath4k,'input/'); % in%06d.jpg
params.PathDatasetGT = strcat(params.VideoPath,'groundtruth/'); % gt%06d.png
params.PathDatasetGT4k = strcat(params.VideoPath4k,'groundtruth/'); % gt%06d.png
params.PathDatasetVideoROI = strcat(params.VideoPath,'temporalROI.txt');
params.PathDatasetVideoROI4k = strcat(params.VideoPath4k,'temporalROI.txt');

if exist(params.VideoPath4k) ~= 7 %folder does not exist
    disp(params.VideoPath4k);
    mkdir(params.VideoPath4k);
end
if exist(params.VideoFileSpec4k) ~= 7 %folder does not exist
    disp(params.VideoFileSpec4k);
    mkdir(params.VideoFileSpec4k);
end
if exist(params.PathDatasetGT4k) ~= 7 %folder does not exist
    disp(params.PathDatasetGT4k);
    mkdir(params.PathDatasetGT4k);
end
status = copyfile(params.PathDatasetVideoROI, params.PathDatasetVideoROI4k);

load(strcat(params.VideoPath,'frames.mat')); % load video frames

fprintf('Video %d: Executing upsampling...\r\n',NdxVideo);

VideoFrame=frames(1,:,:,:);
VideoFrame = squeeze(VideoFrame);
InputSize = size(VideoFrame);
OutputSize(2) = 1920; %Full HD
OutputSize(1) = round(OutputSize(2)*InputSize(1)/InputSize(2));
%upsampledFrames = zeros(numFrames{NdxVideo}, OutputSize(1), OutputSize(2), 3,'uint8');

for NdxFrame=selectedFrames
    disp(NdxFrame);
    
    VideoFrame=imread(sprintf(strcat(params.VideoFileSpec,'in%06d.jpg'),NdxFrame));
    VideoFrame = double(VideoFrame)/255;
    VideoFrame = MFTSuperresAuto(VideoFrame,round(OutputSize(1)/InputSize(1)),OutputSize);    
    %upsampledFrames(NdxFrame,:,:,:) = VideoFrame;
    imwrite(VideoFrame,sprintf(strcat(params.VideoFileSpec4k,'in%06d.jpg'),NdxFrame));    
    
    VideoFrame=imread(sprintf(strcat(params.PathDatasetGT,'gt%06d.png'),NdxFrame));
    VideoFrame = double(VideoFrame)/255;
    VideoFrame = MFTSuperresAuto(VideoFrame,round(OutputSize(1)/InputSize(1)),OutputSize);
    VideoFrame(:,:,2) = VideoFrame(:,:,1);
    VideoFrame(:,:,3) = VideoFrame(:,:,1);    
    imwrite(VideoFrame,sprintf(strcat(params.PathDatasetGT4k,'gt%06d.png'),NdxFrame));
end

%frames = upsampledFrames;
%disp(strcat(params.VideoPath4k,'frames.mat'));
%save(strcat(params.VideoPath4k,'frames.mat'), 'frames','-v7.3');
fprintf('Video %d [%d-%d]: Upsampling done...\r\n',NdxVideo,selectedFramesIni,selectedFramesFin);



end
