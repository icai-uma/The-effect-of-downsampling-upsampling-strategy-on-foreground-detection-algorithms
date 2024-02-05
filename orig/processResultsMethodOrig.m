% execute in Windows
function []=checkSegmentationFiles(selectedMethod)

disp('Starting');
warning off
rng('default');

if strcmp(selectedMethod,'mfbm')
    NdxMethod = 1;
elseif strcmp(selectedMethod,'clvid')
    NdxMethod = 2;
elseif strcmp(selectedMethod,'fsom')
    NdxMethod = 3;
elseif strcmp(selectedMethod,'wren')
    NdxMethod = 4;
elseif strcmp(selectedMethod,'grimson')
    NdxMethod = 5;
elseif strcmp(selectedMethod,'zivkovic')
    NdxMethod = 6;
elseif strcmp(selectedMethod,'temporal_median')
    NdxMethod = 7;
elseif strcmp(selectedMethod,'eigenbackground')
    NdxMethod = 8;
elseif strcmp(selectedMethod,'fuzzy_choquet_integral')
    NdxMethod = 9;
elseif strcmp(selectedMethod,'adaptative_som')
    NdxMethod = 10;
elseif strcmp(selectedMethod,'fuzzy_adaptative_som')
    NdxMethod = 11;
elseif strcmp(selectedMethod,'KDE')
    NdxMethod = 12;
elseif strcmp(selectedMethod,'SUBSENSE')
    NdxMethod = 13;
elseif strcmp(selectedMethod,'LOBSTER')
    NdxMethod = 14;
elseif strcmp(selectedMethod,'PAWCS')
    NdxMethod = 15;    
else
    disp('Error: method not found!');
    exit;
end

% Video to be processed

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

VideoFileSpec{5}='cameraJitter/badminton';
deltaFrame{5}=0;
numFrames{5}=1150;
InputSize{5}=[480 720];

VideoFileSpec{6}='cameraJitter/boulevard';
deltaFrame{6}=0;
numFrames{6}=2500;
InputSize{6}=[240 352];

VideoFileSpec{7}='cameraJitter/sidewalk';
deltaFrame{7}=0;
numFrames{7}=1200;
InputSize{7}=[240 352];

VideoFileSpec{8}='cameraJitter/traffic';
deltaFrame{8}=0;
numFrames{8}=1570;
InputSize{8}=[240 320];

VideoFileSpec{9}='dynamicBackground/boats';
deltaFrame{9}=0;
numFrames{9}=7999;
InputSize{9}=[240 320];

VideoFileSpec{10}='dynamicBackground/canoe';
deltaFrame{10}=0;
numFrames{10}=1189;
InputSize{10}=[240 320];

VideoFileSpec{11}='dynamicBackground/fall';
deltaFrame{11}=0;
numFrames{11}=4000;
InputSize{11}=[480 720];

VideoFileSpec{12}='dynamicBackground/fountain01';
deltaFrame{12}=0;
numFrames{12}=1184;
InputSize{12}=[288 432];

VideoFileSpec{13}='dynamicBackground/fountain02';
deltaFrame{13}=0;
numFrames{13}=1499;
InputSize{13}=[288 432];

VideoFileSpec{14}='dynamicBackground/overpass';
deltaFrame{14}=0;
numFrames{14}=3000;
InputSize{14}=[240 320];

VideoFileSpec{15}='intermittentObjectMotion/abandonedBox';
deltaFrame{15}=0;
numFrames{15}=4500;
InputSize{15}=[288 432];

VideoFileSpec{16}='intermittentObjectMotion/parking';
deltaFrame{16}=0;
numFrames{16}=2500;
InputSize{16}=[240 320];

VideoFileSpec{17}='intermittentObjectMotion/sofa';
deltaFrame{17}=0;
numFrames{17}=2750;
InputSize{17}=[240 320];

VideoFileSpec{18}='intermittentObjectMotion/streetLight';
deltaFrame{18}=0;
numFrames{18}=3200;
InputSize{18}=[240 320];

VideoFileSpec{19}='intermittentObjectMotion/tramstop';
deltaFrame{19}=0;
numFrames{19}=3200;
InputSize{19}=[288 432];

VideoFileSpec{20}='intermittentObjectMotion/winterDriveway';
deltaFrame{20}=0;
numFrames{20}=2500;
InputSize{20}=[240 320];

VideoFileSpec{21}='shadow/backdoor';
deltaFrame{21}=0;
numFrames{21}=2000;
InputSize{21}=[240 320];

VideoFileSpec{22}='shadow/bungalows';
deltaFrame{22}=0;
numFrames{22}=1700;
InputSize{22}=[240 360];

VideoFileSpec{23}='shadow/busStation';
deltaFrame{23}=0;
numFrames{23}=1250;
InputSize{23}=[240 360];

VideoFileSpec{24}='shadow/copyMachine';
deltaFrame{24}=0;
numFrames{24}=3400;
InputSize{24}=[480 720];

VideoFileSpec{25}='shadow/cubicle';
deltaFrame{25}=0;
numFrames{25}=7400;
InputSize{25}=[240 352];

VideoFileSpec{26}='shadow/peopleInShade';
deltaFrame{26}=0;
numFrames{26}=1199;
InputSize{26}=[244 380];

VideoFileSpec{27}='thermal/corridor';
deltaFrame{27}=0;
numFrames{27}=5400;
InputSize{27}=[240 320];

VideoFileSpec{28}='thermal/diningRoom';
deltaFrame{28}=0;
numFrames{28}=3700;
InputSize{28}=[240 320];

VideoFileSpec{29}='thermal/lakeSide';
deltaFrame{29}=0;
numFrames{29}=6500;
InputSize{29}=[240 320];

VideoFileSpec{30}='thermal/library';
deltaFrame{30}=0;
numFrames{30}=4900;
InputSize{30}=[240 320];

VideoFileSpec{31}='thermal/park';
deltaFrame{31}=0;
numFrames{31}=600;
InputSize{31}=[288 352];


VideoFileSpec{32}='badWeather/blizzard';
deltaFrame{32}=0;
numFrames{32}=7000;
InputSize{32}=[480 720];

VideoFileSpec{33}='badWeather/skating';
deltaFrame{33}=0;
numFrames{33}=3900;
InputSize{33}=[360 540];

VideoFileSpec{34}='badWeather/snowFall';
numFrames{34}=6500;
deltaFrame{34}=0;
InputSize{34}=[480 720];

VideoFileSpec{35}='badWeather/wetSnow';
deltaFrame{35}=0;
numFrames{35}=3500;
InputSize{35}=[540 720];

VideoFileSpec{36}='lowFramerate/port_0_17fps';
deltaFrame{36}=0;
numFrames{36}=3000;
InputSize{36}=[480 640];

VideoFileSpec{37}='lowFramerate/tramCrossroad_1fps';
deltaFrame{37}=0;
numFrames{37}=900;
InputSize{37}=[350 640];

VideoFileSpec{38}='lowFramerate/tunnelExit_0_35fps';
deltaFrame{38}=0;
numFrames{38}=4000;
InputSize{38}=[440 700];

VideoFileSpec{39}='lowFramerate/turnpike_0_5fps';
deltaFrame{39}=0;
numFrames{39}=1500;
InputSize{39}=[240 320];

VideoFileSpec{40}='nightVideos/bridgeEntry';
deltaFrame{40}=0;
numFrames{40}=2500;
InputSize{40}=[430 630];

VideoFileSpec{41}='nightVideos/busyBoulvard';
deltaFrame{41}=0;
numFrames{41}=2760;
InputSize{41}=[364 640];

VideoFileSpec{42}='nightVideos/fluidHighway';
deltaFrame{42}=0;
numFrames{42}=1364;
InputSize{42}=[450 700];

VideoFileSpec{43}='nightVideos/streetCornerAtNight';
deltaFrame{43}=0;
numFrames{43}=5200;
InputSize{43}=[245 595];

VideoFileSpec{44}='nightVideos/tramStation';
deltaFrame{44}=0;
numFrames{44}=3000;
InputSize{44}=[295 480];

VideoFileSpec{45}='nightVideos/winterStreet';
deltaFrame{45}=0;
numFrames{45}=1785;
InputSize{45}=[420 624];

VideoFileSpec{46}='PTZ/continuousPan';
deltaFrame{46}=0;
numFrames{46}=1700;
InputSize{46}=[480 704];

VideoFileSpec{47}='PTZ/intermittentPan';
deltaFrame{47}=0;
numFrames{47}=3500;
InputSize{47}=[368 560];

VideoFileSpec{48}='PTZ/twoPositionPTZCam';
deltaFrame{48}=0;
numFrames{48}=2300;
InputSize{48}=[340 570];

VideoFileSpec{49}='PTZ/zoomInZoomOut';
deltaFrame{49}=0;
numFrames{49}=1130;
InputSize{49}=[240 320];

VideoFileSpec{50}='turbulence/turbulence0';
deltaFrame{50}=0;
numFrames{50}=5000;
InputSize{50}=[480 720];

VideoFileSpec{51}='turbulence/turbulence1';
deltaFrame{51}=0;
numFrames{51}=4000;
InputSize{51}=[480 720];

VideoFileSpec{52}='turbulence/turbulence2';
deltaFrame{52}=0;
numFrames{52}=4500;
InputSize{52}=[315 645];

VideoFileSpec{53}='turbulence/turbulence3';
deltaFrame{53}=0;
numFrames{53}=2200;
InputSize{53}=[486 720];

Method = [1 2 3]; % {mfbm, cl-vid, fsom}
TypeDownsampling = [1 2 3 4]; % {imresize ('nearest', 'bicubic', 'bilinear'), imfilter}
ResizeFactor = [0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125];
TypeUpsampling = [1 2]; % {imresize ('bicubic'), SR}


NumVideos = 31;
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

resultsSegmentation = [];
NdxResultsSegmentation = 1;
unexistingResultsSegmentation = [];
ndxUnexistingResultsSegmentation = 1;

resultsUpsampling = [];
NdxResultsUpsampling = 1;
unexistingResultsUpsampling = [];
ndxUnexistingResultsUpsampling = 1;

resultsStats=[];
NdxResultsStats = 1;
unexistingResultsStats=[];
ndxUnexistingResultsStats = 1;

for NdxVideo=1:NumVideos
    NdxTypeDownsampling = 0;
    NdxResizeFactor = 0;    
    NdxTypeUpsampling = 0;
    params.PathResultsSegmentationFile = strcat(params.MatlabProjectsDirectory,'resizeStudy/',sprintf('resultsSegmentation_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
    if exist(params.PathResultsSegmentationFile) == 0
        fprintf('resultsSegmentation_%d_%d_%d_%d_%d not found.\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
        unexistingResultsSegmentation(ndxUnexistingResultsSegmentation,1:5)=[NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling];
        ndxUnexistingResultsSegmentation = ndxUnexistingResultsSegmentation + 1;
        %continue;
    else
        load (params.PathResultsSegmentationFile);
        resultsSegmentation(NdxResultsSegmentation,1:6) = Results(1,:);
        NdxResultsSegmentation = NdxResultsSegmentation + 1;
    end

    
    params.PathResultsStatsFile = strcat(params.MatlabProjectsDirectory,'resizeStudy/',sprintf('resultsStats_%d_%d_%d_%d_%d.mat',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling));
    if exist(params.PathResultsStatsFile) == 0
        fprintf('resultsStats_%d_%d_%d_%d_%d not found.\n',NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling);
        unexistingResultsStats(ndxUnexistingResultsStats,1:5)=[NdxVideo,NdxMethod,NdxResizeFactor,NdxTypeDownsampling,NdxTypeUpsampling];
        ndxUnexistingResultsStats = ndxUnexistingResultsStats + 1;
        continue;
    end
    load (params.PathResultsStatsFile);
    resultsStats(NdxResultsStats,1:19) = Results(1,:);
    NdxResultsStats = NdxResultsStats + 1;
    
end

save(strcat(params.MatlabProjectsDirectory,'resizeStudy/','joinedResultsSegmentation_',selectedMethod,'_orig.mat'),'resultsSegmentation');
save(strcat(params.MatlabProjectsDirectory,'resizeStudy/','joinedResultsStats_',selectedMethod,'_orig.mat'),'resultsStats');