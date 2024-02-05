function [SuperResImage]=MFTSuperresAuto(InputImage,ZoomFactor,OutputSize)
% Obtain a superresolution version of an image by the Median Filter
% Transform
% Automated parameter selection version
% Inputs:
%   InputImage=RGB image in double format, values in the range [0,1]
%   ZoomFactor=The superresolution factor. Must be an integer larger than 1.
%   OutputSize=The size of the output image (only used for fractional zoom
%   factors)
% Note: set the lowermargin, uppermargin and nummedianfilter parameters
% by hand according to the chosen zoomfactor.

NumMedianFilters=100;
switch ZoomFactor
    case 2
        LowerMargin=-2;
        UpperMargin=-0.5;
    case 3
        LowerMargin=-2.5;
        UpperMargin=-1;  
    case 4
        LowerMargin=-2.75;
        UpperMargin=-1.5;
    case 5
        LowerMargin=-2.75;
        UpperMargin=-1.5;
	case 6
        LowerMargin=-2.75;
        UpperMargin=-1.5;
    case 7
        LowerMargin=-2.75;
        UpperMargin=-1.5;
    case 8
        LowerMargin=-2.75;
        UpperMargin=-1.5;
    otherwise
        if ZoomFactor<3
            % This is for zoom factor 2.5
            LowerMargin=-2.25;
            UpperMargin=-0.75;
        else
            if ZoomFactor<4
                % This is for zoom factor 3.5 
                LowerMargin=0.5*(-2.5-2.75);
                UpperMargin=-1.25;
            end
        end
end
        

if nargin==2
    SuperResImage=zeros(size(InputImage,1)*ZoomFactor,size(InputImage,2)*ZoomFactor,3);
else
    SuperResImage=zeros(OutputSize(1),OutputSize(2),3);
end

[X,Y]=ndgrid(1:ZoomFactor:ZoomFactor*size(InputImage,1),1:ZoomFactor:ZoomFactor*size(InputImage,2));
TrainSamples=zeros(2,numel(X));
TrainSamples(1,:)=X(:);
TrainSamples(2,:)=Y(:);
[X,Y]=ndgrid(1:size(SuperResImage,1),1:size(SuperResImage,2));
TestSamples=zeros(2,numel(X));
TestSamples(1,:)=X(:);
TestSamples(2,:)=Y(:);

for NdxChannel=1:size(InputImage,3)
    TrainFuncValues=reshape(InputImage(:,:,NdxChannel),[1 size(InputImage,1)*size(InputImage,2)]);
    Model=MedianFilterTransform(TrainSamples,TrainFuncValues,NumMedianFilters,LowerMargin,UpperMargin);
    SuperResImage(:,:,NdxChannel)=reshape(TestMFTMEX(Model,TestSamples),[size(SuperResImage,1) size(SuperResImage,2) 1]);
end
    


