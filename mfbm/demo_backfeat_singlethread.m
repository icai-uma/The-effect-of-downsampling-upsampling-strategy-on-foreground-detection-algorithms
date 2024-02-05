
clear all
tic
SelectedFeatures{1}=[19 20 22];
SelectedFeatures{2}=[3 20 21 22];
SelectedFeatures{3}=[4 19 20 21];
SelectedFeatures{4}=[5 19 20 22];
SelectedFeatures{5}=[5 19 21 22];
SelectedFeatures{6}=[19 20 21 22];
SelectedFeatures{7}=[4 19 20 21 22];
SelectedFeatures{8}=[5 6 19 20 22];
SelectedFeatures{9}=[5 19 20 21 22];
SelectedFeatures{10}=[6 19 20 21 22];
SelectedFeatures{11}=[1 2 3];

epsilon=[0.0001 0.0005 0.001 0.005 0.01];

% Video to be processed

VideoFileSpec{1}='../../../../proyectos_matlab/Videos/baseline/highway/input/in%06d.jpg';
deltaFrame{1}=0;
numFrames{1}=1700;

VideoFileSpec{2}='../../../../proyectos_matlab/Videos/baseline/pedestrians/input/in%06d.jpg';
deltaFrame{2}=0;
numFrames{2}=1099;

VideoFileSpec{3}='../../../../proyectos_matlab/Videos/baseline/office/input/in%06d.jpg';
deltaFrame{3}=0;
numFrames{3}=2050;

VideoFileSpec{4}='../../../../proyectos_matlab/Videos/baseline/PETS2006/input/in%06d.jpg';
deltaFrame{4}=0;
numFrames{4}=1200;

VideoFileSpec{5}='../../../../proyectos_matlab/Videos/dynamicBackground/canoe/input/in%06d.jpg';
deltaFrame{5}=0;
numFrames{5}=1189;

VideoFileSpec{6}='../../../../proyectos_matlab/Videos/dynamicBackground/fountain02/input/in%06d.jpg';
deltaFrame{6}=0;
numFrames{6}=1499;

VideoFileSpec{7}='../../../../proyectos_matlab/Videos/dynamicBackground/fall/input/in%06d.jpg';
deltaFrame{7}=0;
numFrames{7}=4000;

VideoFileSpec{8}='../../../../proyectos_matlab/Videos/intermittentObjectMotion/sofa/input/in%06d.jpg';
deltaFrame{8}=0;
numFrames{8}=2750;



% VideoFileSpec{2}='Videos/LevelCrossing/f%07d.bmp';
% deltaFrame{2}=0;
% numFrames{2}=500;
% 
% VideoFileSpec{3}='Videos/Video2/f%07d.bmp';
% deltaFrame{3}=0;
% numFrames{3}=749;

NdxVideo=8;

NdxFeatureSort=11;
NdxEpsilon=4;

AutomatedTestBMsinglethread(SelectedFeatures{NdxFeatureSort},VideoFileSpec{NdxVideo},deltaFrame{NdxVideo},numFrames{NdxVideo},epsilon(NdxEpsilon));

toc
