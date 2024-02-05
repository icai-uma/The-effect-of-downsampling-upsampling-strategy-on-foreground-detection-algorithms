% Demo code for the paper
% Foreground Detection in Video Sequences with Probabilistic
% Self-Organising Maps
% International Journal of Neural Systems. ISSN: 0129-0657. DOI: 10.1142/S012906571100281X  
% Coded by R.M.Luque and Ezequiel Lopez-Rubio -- June 2011 

% Load the video to analyse
disp('Loading the input sequence...');
videoName='turbulence/turbulence3/turbulence3.avi'; %%%%%%%%%%%%modificar para cada video!!!!
sName = sprintf('../../../../proyectos_matlab/Videos/%s',videoName);
%fInfo=aviinfo(sName);
%d=aviread(sName,1);
d=VideoReader(sName);
NumFrames = 2200; %%%%%%%%%%%%modificar para cada video!!!!


% Create the structures of the stochastic approximation model
disp('Creating the structures of the probabilistic self organising network model...');
FirstFrame=readFrame(d);
model = createSOMModel(FirstFrame);
%model.LastFrame = fInfo.NumFrames;
model.LastFrame = NumFrames;
    
% Allocate scape for the set of images to initialise the model 
images = zeros(size(FirstFrame,1),size(FirstFrame,2),size(FirstFrame,3),model.NumPatterns);
images(:,:,:,1) = uint8(FirstFrame);

% Store the frames
for i=2:model.NumPatterns
    %d=aviread(sName,i);
    NextFrame=readFrame(d);
    images(:,:,:,i) = uint8(NextFrame);
end
images = uint8(images);

disp('Initialising the model...');
% Initialize the model using a set of frames
model = initializeSOMModel(model,images); 

%d=aviread(sName);
d=VideoReader(sName);
figure(1)
disp('Analysing the model...');
i=1;
while hasFrame(d)
    NextFrame=readFrame(d);
    tic;
    Coef=CoefSOM(i,model);
    model=TurboSOMMEX(model,double(NextFrame),Coef);
    toc;
    imMask = double(model.imMask >= 0.5);
    
    % Fill holes (size 1) y remove objects with minimum area
    imMask = bwmorph(imMask,'majority');
    imMask = removeSpuriousObjects(imMask, model.MaximumArea);
    
    subplot(1,2,1),imshow(NextFrame);
    title(['Frame nº ' num2str(i)]);
    subplot(1,2,2),imshow(imMask);
    %imwrite(imMask,(sprintf(strcat('results','/seg%06d.jpg'),i)));
    imwrite(imMask,(sprintf(strcat('../../../../proyectos_matlab/Videos/ImagenesSegmentadas/FSOM/temp','/seg%06d.jpg'),i)));%%%%%%%%%%%%modificar para cada video!!!!
    pause(0.01);
    i=i+1;
end
disp('End of the process');

