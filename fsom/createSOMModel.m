function Model = createSOMModel(frame)
% Model = createSOMModel(frame)
% The model structure is built from a frame of the analysed sequence

% R.M.Luque and Ezequiel Lopez-Rubio -- June 2011

NumImageRows = size(frame,1);
NumImageColumns = size(frame,2);
Model.NumImageRows=NumImageRows;
Model.NumImageColumns=NumImageColumns;

% Map Structure
Model.NumMapRows=1; % Number of rows of the map
Model.NumMapColumns=12; % Number of columns of the map

% Valid values are shown in the paper 
Model.ProbAPrioriUnif=0.1; % Probability of uniform distribution (by default is 0.1)
Model.NeighbourhoodRadius = 0.1; % radius of neighbourhood at the convergence point (by default is 0.1)
Model.NumPatterns = 100; % Patterns for the ordenation phase (by default is 100)
Model.MinimumVariance = 9; % minimum limit of the variance (by default is 9)
Model.MaximumVariance = 25; % maximum limit of the variance (by default is 25)
Model.MaximumArea = 10; % maximum area for spurious objects (by default is 10)
Model.CurrentFrame = 0; %Constant variable which indicates the current frame (at the begining 0)

% A range of valid values for the following parameters is indicated in
% the paper
Model.StepSize = 0.01; % Step size which regulates how quick the learning process is
Model.LearningRate = 0.01; % Rate which influences the learning topology

Model.Log = 'temp.txt'; % Name of the log file

% Allocating space for work variables
Model.Pi=Model.ProbAPrioriUnif*ones(NumImageRows,NumImageColumns); 
Model.Cov=zeros(4,NumImageRows,NumImageColumns); 
Model.Var=zeros(NumImageRows,NumImageColumns); 
Model.NeuroWin=zeros(NumImageRows,NumImageColumns); 
Model.imMask=zeros(NumImageRows,NumImageColumns);
Model.MaximumVariance = Model.MaximumVariance*ones(NumImageRows,NumImageColumns);





