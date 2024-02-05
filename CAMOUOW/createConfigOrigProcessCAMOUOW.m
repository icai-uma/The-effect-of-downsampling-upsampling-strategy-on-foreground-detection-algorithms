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
InputSize{7}=[1080 1920];

VideoFileSpec{8}='video8';
deltaFrame{8}=0;
numFrames{8}=468;
InputSize{8}=[1080 1920];

VideoFileSpec{9}='video9';
deltaFrame{9}=0;
numFrames{9}=290;
InputSize{9}=[1080 1920];

VideoFileSpec{10}='video10';
deltaFrame{10}=0;
numFrames{10}=460;
InputSize{10}=[1080 1920];

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

%ArrayIDNumber=911;
%ArrayIDNumber=1;

ArrayIDNumber = mod(ArrayIDNumber,numConfigs);
if ArrayIDNumber == 0
    ArrayIDNumber = numConfigs;
end

%ArrayIDNumber = 731; % NdxVideo =3; NdxResizeFactor = 1; NdxTypeDownsampling=5;
%%%NdxVideo =11; NdxResizeFactor = 1; NdxTypeDownsampling=5;
%%%sub2ind([NumVideos NumResizeFactors NumTypeDownsamplings NumTypeUpsamplings NumMethods],NdxVideo,NdxResizeFactor,NdxTypeDownsampling)

NdxResizeFactor = 0;
NdxTypeDownsampling = 0;
NdxTypeUpsampling = 0;

%NdxVideo = 11; NdxResizeFactor = 1; NdxTypeDownsampling=4; NdxTypeUpsampling=1;

pwdPath = strsplit(pwd,'/');
%st = dbstack(1); % name of the file that call createConfig.m file
%disp(st.name);

if strcmp(pwdPath{size(pwdPath,2)},'mfbm')
    NdxMethod = 1;
elseif strcmp(pwdPath{size(pwdPath,2)},'clvid')
    NdxMethod = 2;
elseif strcmp(pwdPath{size(pwdPath,2)},'fsom')
    NdxMethod = 3;
%elseif strcmp(st.name,'upsamplingSegmentation')
elseif exist('isUpsampling','var') % hay que cambiarlo cuando se ejecuta el upsampling y las stats
    NdxMethod = 6; % hay que cambiarlo manualmente para cada metodo!!!!
	NdxTypeUpsampling = 0; % hay que cambiarlo manualmente para cada metodo, primero NdxTypeUpsampling = 2 y luego NdxTypeUpsampling = 1!!!!
end

%%ResizeFactor = 0.75;
%%TypeDownsampling = imresize bicubic
%%Method = mfbm
%%TypeUpsampling = imresize bicubic
%%Video = dynamicBackground/canoe
%NdxResizeFactor = 2;
%NdxTypeDownsampling = 2;
%NdxMethod = 2;
%NdxTypeUpsampling = 1;
%NdxVideo = 10;


params.IsPicasso = IsPicasso;
params.VideoFileSpec = strcat(params.MatlabProjectsDirectory,'datasets/CAMO-UOW/Videos/',VideoFileSpec{NdxVideo},'/%d.png');
params.VideoPath = strcat(params.MatlabProjectsDirectory,'datasets/CAMO-UOW/Videos/',VideoFileSpec{NdxVideo},'/');
params.PathDatasetGT = strcat(params.MatlabProjectsDirectory,'datasets/CAMO-UOW/Groundtruth/T',VideoFileSpec{NdxVideo},'/%d.png');
%params.PathDatasetVideoROI = strcat(params.MatlabProjectsDirectory,'datasets/dataset2014/dataset4k/',VideoFileSpec{NdxVideo},'/temporalROI.txt');
params.PathDatasetResized = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/datasetResized/',sprintf('%d-%d/',NdxResizeFactor,NdxTypeDownsampling),VideoFileSpec{NdxVideo},'/input/');
params.PathDatasetSegmented = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),'segmentation/',VideoFileSpec{NdxVideo},'/bin%06d.png');
params.PathDatasetUpsampled = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),'upsampling/',VideoFileSpec{NdxVideo},'/bin%06d.png');
params.PathDatasetResults = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),'results/',VideoFileSpec{NdxVideo});
params.PathDatasetSegmentation = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),'segmentation/',VideoFileSpec{NdxVideo});
params.PathDatasetUpsampling = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),'upsampling/',VideoFileSpec{NdxVideo});
params.pathConfigFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/methods/',sprintf('%d-%d-%d-%d/',NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling),sprintf('config_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathResultsDownsamplingFile = strcat(params.PathDatasetResized,'..',sprintf('/resultsDownsampling_%d_%d_%d.mat',NdxVideo,NdxResizeFactor,NdxTypeDownsampling));
params.PathResultsSegmentationFile = strcat(params.PathDatasetResults,sprintf('/resultsSegmentation_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathResultsUpsamplingFile = strcat(params.PathDatasetResults,sprintf('/resultsUpsampling_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathResultsStatsFile = strcat(params.PathDatasetResults,sprintf('/resultsStats_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathCodeResultsDownsamplingFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsDownsampling_%d_%d_%d.mat',NdxVideo,NdxResizeFactor,NdxTypeDownsampling));
params.PathCodeResultsSegmentationFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsSegmentation_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathCodeResultsUpsamplingFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsUpsampling_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.PathCodeResultsStatsFile = strcat(params.MatlabProjectsDirectory,'resizeStudyCAMOUOW/',sprintf('resultsStats_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
params.videoSelected = VideoFileSpec{NdxVideo};
params.deltaFrame=deltaFrame{NdxVideo};
params.numFrames=numFrames{NdxVideo};
params.InputSize=InputSize{NdxVideo};
params.NdxVideo = NdxVideo;
params.NdxMethod = NdxMethod;
params.NdxResizeFactor = NdxResizeFactor;
params.NdxTypeDownsampling = NdxTypeDownsampling;
params.NdxTypeUpsampling = NdxTypeUpsampling;

fprintf('\r\nConfiguration %d-%d-%d-%d-%d starting.\r\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);

statsFile = strcat(params.PathDatasetResults,sprintf('/stats_%d_%d_%d_%d_%d.mat',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling));

if exist(statsFile) == 2 %file exists
    fprintf('\r\nConfiguration %d-%d-%d-%d-%d already done.\r\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
else
    
    % Para que no se apelotonen los procesos en el servidor de licencias
    % ListToolBoxes={'Image_Toolbox','Signal_Toolbox','Wavelet_Toolbox','Statistics_Toolbox'};
    % ListToolBoxes={'Image_Toolbox','Signal_Toolbox','Wavelet_Toolbox'};
    ListToolBoxes={'Image_Toolbox'};
    for NdxTool=1:numel(ListToolBoxes)
        while ( license('checkout',ListToolBoxes{NdxTool}) ~= 1 )
            fprintf('License for %s not found.\r\n',ListToolBoxes{NdxTool});
            pause(rand(1)*60);
        end
        fprintf('License for %s found.\r\n',ListToolBoxes{NdxTool});
        %pause(rand(1)*60);
    end       
    
    % Create the directory where we write the config file, resized dataset
    % and the results if they do not exist
    if exist(params.PathDatasetResized) ~= 7 %folder does not exist
        disp(params.PathDatasetResized);
        mkdir(params.PathDatasetResized);
    end
    if exist(params.PathDatasetResults) ~= 7 %folder does not exist
        mkdir(params.PathDatasetResults);
    end    
    if exist(params.PathDatasetSegmentation) ~= 7 %folder does not exist
        mkdir(params.PathDatasetSegmentation);
    end 
    if exist(params.PathDatasetUpsampling) ~= 7 %folder does not exist
        mkdir(params.PathDatasetUpsampling);
    end       

    % create segmentation method call
    switch params.NdxMethod
        case 1 %mfbm
            SelectedFeatures{11}=[1 2 3];
            epsilon=[0.0001 0.0005 0.001 0.005 0.01];
            NdxFeatureSort=11;
            NdxEpsilon=4;
            params.SelectedFeatures = SelectedFeatures{NdxFeatureSort};
            params.epsilon = epsilon(NdxEpsilon);
            addpath('./mfbm');
            commandMethod = strcat('matlab -r addpath(''./mfbm'');AutomatedTestBM(''' , params.pathConfigFile, ''') &');
        case 2 %cl-vid            
            params.NumNeurons = 6;
            params.CoefWinner = 0.05;
            params.CoefAll = 0.0001;
            params.DistanceThreshold = 0.01;
            addpath('./clvid');
            commandMethod = strcat('matlab -r addpath(''./clvid'');cl_vid(''' , params.pathConfigFile, ''') &');
        case 3 %fsom
            addpath('./fsom');
            commandMethod = strcat('matlab -r addpath(''./fsom'');fsom(''' , params.pathConfigFile, ''') &');
    end	
    
    % save config file    
    if exist(params.pathConfigFile) ~= 2 %folder does not exist
        save(params.pathConfigFile,'params');
        fprintf('Configuration %d-%d-%d-%d-%d: Config file created...\r\n',params.NdxVideo,params.NdxMethod,params.NdxResizeFactor,params.NdxTypeDownsampling,params.NdxTypeUpsampling);
    end    

end

