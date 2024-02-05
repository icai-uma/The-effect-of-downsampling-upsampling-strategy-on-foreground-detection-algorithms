%clear all
%close all
disp('Starting');
warning off
rng('default');

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
InputSize{7}=[1920 1080];

VideoFileSpec{8}='video8';
deltaFrame{8}=0;
numFrames{8}=468;
InputSize{8}=[1920 1080];

VideoFileSpec{9}='video9';
deltaFrame{9}=0;
numFrames{9}=290;
InputSize{9}=[1920 1080];

VideoFileSpec{10}='video10';
deltaFrame{10}=0;
numFrames{10}=460;
InputSize{10}=[1920 1080];

% params
% CompressionFactor = 0.125; % {0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125}
% TypeCompression = 1; % {1,2} -- 'imresize', 'imfilter'
% typeImresize = 1; % {1,2,3} -- only works for typeCompression='imresize' -- 'nearest' 'bicubic' 'bilinear'

Method = [1 2 3]; % {mfbm, cl-vid, fsom}
TypeDownsampling = [1 2 3 4]; % {imresize ('nearest', 'bicubic', 'bilinear'), imfilter}
ResizeFactor = [0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125];
TypeUpsampling = [1 2]; % {imresize ('bicubic'), SR}

%%% seleccionar videos para el estudio !!!!!!!!!!!

NumVideos = 10; % las categorias del cdnet 2012
NumMethods = numel(Method);
NumTypeDownsamplings = numel(TypeDownsampling);
NumResizeFactors = numel(ResizeFactor);
NumTypeUpsamplings = numel(TypeUpsampling);

numConfigs=NumVideos * NumMethods * NumResizeFactors * NumTypeDownsamplings * NumTypeUpsamplings;

MyArrayID=getenv('SLURM_ARRAY_TASK_ID');
if isunix
    %if exist('MyArrayID','var')
	if ~isempty(MyArrayID)
        ArrayIDNumber=sscanf(MyArrayID,'%d');
        if(size(ArrayIDNumber,1)>0) %picasso
            fprintf('\r\nTask %d starting.\r\n',ArrayIDNumber);
            IsPicasso=1;
            params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
        else
            ArrayIDNumber=1;
            IsPicasso=0;        
            %params.MatlabProjectsDirectory = '/home/icai21/proyectos_matlab/';
            params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
        end
        
    else
        ArrayIDNumber=1;
        IsPicasso=0;        
        %params.MatlabProjectsDirectory = '/home/icai21/proyectos_matlab/';
        params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
    end
elseif ispc
    ArrayIDNumber=1;
    IsPicasso=0;
    params.MatlabProjectsDirectory = 'C:/proyectos_matlab/';    
end


disp('Checking downsampling...');
contFailedDownsampling = 0;
for NdxResizeFactor = 1:NumResizeFactors
    for NdxTypeDownsampling = 1:NumTypeDownsamplings
        for NdxVideo=1:NumVideos
            pathDatasetResized = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/datasetResized/',sprintf('%d-%d/',NdxResizeFactor,NdxTypeDownsampling),VideoFileSpec{NdxVideo},'/frames.mat');
            if exist(pathDatasetResized,'file') ~= 2 %file does not exist
                contFailedDownsampling = contFailedDownsampling + 1;
                fprintf('%d-%d-%s\n',NdxResizeFactor,NdxTypeDownsampling,VideoFileSpec{NdxVideo});
            else
                s=dir(pathDatasetResized);
                if s.bytes<100000 %the size of the file is lower than 100kb
                    contFailedDownsampling = contFailedDownsampling + 1;
                    fprintf('* %d-%d-%s\n',NdxResizeFactor,NdxTypeDownsampling,VideoFileSpec{NdxVideo});
                end
            end
        end
    end
end
fprintf('Total failed downsampling: %d\n',contFailedDownsampling);
