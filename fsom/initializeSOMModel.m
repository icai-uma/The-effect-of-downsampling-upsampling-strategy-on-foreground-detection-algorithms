function Model = initializeSOMModel(Model,frames)
% Model = initializeSOMModel(Model,frames)
% This function initialises the parameters of the gaussians distribution
% for each neuron in the map according to the set of input frames 

% R.M.Luque and Ezequiel Lopez-Rubio -- June 2011

NumImageRows = Model.NumImageRows;
NumImageColumns = Model.NumImageColumns;
NumMapRows = Model.NumMapRows;
NumMapColumns = Model.NumMapColumns;

Patterns = mean(frames,4);

R=reshape(Patterns(:,:,1),[1 1 NumImageRows NumImageColumns]);
G=reshape(Patterns(:,:,2),[1 1 NumImageRows NumImageColumns]);
B=reshape(Patterns(:,:,3),[1 1 NumImageRows NumImageColumns]);

% Initilise the mean of the gaussian distribution for each neuron
Model.Mu=zeros(3,NumMapRows,NumMapColumns,NumImageRows,NumImageColumns);    
Model.Mu(1,:,:,:,:)=repmat(R,[NumMapRows NumMapColumns 1 1]);
Model.Mu(2,:,:,:,:)=repmat(G,[NumMapRows NumMapColumns 1 1]);
Model.Mu(3,:,:,:,:)=repmat(B,[NumMapRows NumMapColumns 1 1]);

% Initilise the variance of the gaussian distribution for each neuron
DifPatterns = zeros(size(frames,1),size(frames,2),3);
for i=1:size(frames,4)
    DifPatterns = DifPatterns + (Patterns-double(frames(:,:,:,i))).^2;
end

DifPatterns = (DifPatterns./size(frames,4));
DifPatterns = mean(DifPatterns,3);
DifPatterns=reshape(DifPatterns,[1 1 NumImageRows NumImageColumns]);

Model.Sigma2=zeros(NumMapRows,NumMapColumns,NumImageRows,NumImageColumns);      
Model.Sigma2 =repmat(DifPatterns,[NumMapRows NumMapColumns 1 1]);
    