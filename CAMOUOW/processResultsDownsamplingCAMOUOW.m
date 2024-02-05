clear all
close all
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

Method = [1 2 3]; % {mfbm, cl-vid, fsom}
TypeDownsampling = [1 2 3 4]; % {imresize ('nearest', 'bicubic', 'bilinear'), imfilter}
ResizeFactor = [0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125];
TypeUpsampling = [1 2]; % {imresize ('bicubic'), SR}


NumVideos = 10;
NumMethods = numel(Method);
NumTypeDownsamplings = numel(TypeDownsampling);
NumResizeFactors = numel(ResizeFactor);
NumTypeUpsamplings = numel(TypeUpsampling);

if isunix
    %params.MatlabProjectsDirectory = '/home/icai21/proyectos_matlab/';
	params.MatlabProjectsDirectory = '/mnt/scratch/users/tic_163_uma/miguelangel/unidad_z/proyectos_matlab/';
elseif ispc
    params.MatlabProjectsDirectory = 'C:/proyectos_matlab/';    
end


resultsDownsampling = [];
NdxResultsDownsampling = 1;
unexistingResultsDownsampling = [];
ndxUnexistingResultsDownsampling = 1;


for NdxVideo=1:NumVideos    
    for NdxTypeDownsampling=1:NumTypeDownsamplings
        for NdxResizeFactor=1:NumResizeFactors
            params.PathResultsDownsamplingFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsDownsampling_%d_%d_%d.mat',NdxVideo,NdxResizeFactor,NdxTypeDownsampling));
            if exist(params.PathResultsDownsamplingFile) == 0
                fprintf('resultsDownsampling_%d_%d_%d not found.\n',NdxVideo,NdxResizeFactor,NdxTypeDownsampling);
                unexistingResultsDownsampling(ndxUnexistingResultsDownsampling,1:3)=[NdxVideo,NdxResizeFactor,NdxTypeDownsampling];
                ndxUnexistingResultsDownsampling = ndxUnexistingResultsDownsampling + 1;
                continue;
            end
            load (params.PathResultsDownsamplingFile);
            resultsDownsampling(NdxResultsDownsampling,1:5) = Results(1,:);
            NdxResultsDownsampling = NdxResultsDownsampling + 1;            
        end
    end
end

save(strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/','joinedResultsDownsampling.mat'),'resultsDownsampling');