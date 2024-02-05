function [Model]=MedianFilterTransform(Samples,FuncValues,NumMedianFilters,LowerMargin,UpperMargin)
% Discrete Median Filter Transform
% Coded by Ezequiel Lopez-Rubio. October 2014.
% Inputs:
%   Samples         DxN matrix with N training samples of dimension D
%   FuncValues      1xN matrix with N function values
%   NumFilters      Number of filters parameter H
%   LowerMargin     Lower scale parameter theta_min
%   UpperMargin     Upper scale parameter theta_max
% Outputs:
%   Model           Resulting MFT model

% Get input sizes
[Dimension,NumSamples]=size(Samples);

% Swap margins if they are not correct
if UpperMargin<LowerMargin
    Auxiliary=LowerMargin;
    LowerMargin=UpperMargin;
    UpperMargin=Auxiliary;
end

% Initialize model
Model.LowerMargin=LowerMargin;
Model.UpperMargin=UpperMargin;
Model.Dimension=Dimension;
Model.NumSamples=NumSamples;
Model.NumMedianFilters=NumMedianFilters;
Model.A=zeros(Dimension,Dimension,NumMedianFilters);
Model.b=zeros(Dimension,NumMedianFilters);
Model.VolumeBin=zeros(1,NumMedianFilters);

% Compute the median filters
for NdxHistogram=1:NumMedianFilters
    [A,b,Volume]=GenerateRandomAffineTransform(Dimension,LowerMargin,UpperMargin);
    Model.MedianFilter{NdxHistogram}=ComputeMediansMEX(Samples,FuncValues,A,b);    
    Model.A(:,:,NdxHistogram)=A;
    Model.b(:,NdxHistogram)=b;
    Model.VolumeBin(NdxHistogram)=Volume;
end
