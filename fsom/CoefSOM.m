function [Coef]=CoefSOM(NdxFrame,Model)
% [Coef]=CoefSOM(NdxFrame,Model)
% This function computes the coefficient map which is applied to each
% neuron to influence its neighbourhood

% R.M.Luque and Ezequiel Lopez-Rubio -- June 2011
      
NumMapRows = Model.NumMapRows;
NumMapColumns = Model.NumMapColumns;
LastFrame = Model.LastFrame;
NeighbourhoodRadius = Model.NeighbourhoodRadius;
NumPatterns = Model.NumPatterns;
ConvergenceLearningRate = Model.LearningRate;

if NdxFrame<NumPatterns   
    % Adaptation phase: lineal drop
    MaxRadius=(NumMapRows+NumMapColumns)/8;
    LearningRate=0.4*(1-NdxFrame/LastFrame);
    MyRadius=MaxRadius*(1-(NdxFrame-1)/LastFrame);
else
    % Convergence phase: constant
    LearningRate=ConvergenceLearningRate;
    MyRadius=NeighbourhoodRadius;
end

% Computation of the update coefficients for this frame 
% (learningRate * neighbourhood function)
Coef=zeros(NumMapRows,NumMapColumns,NumMapRows,NumMapColumns);
for NdxRow1=1:NumMapRows
    for NdxCol1=1:NumMapColumns
        Coord1=[NdxRow1 NdxCol1];
        for NdxRow2=1:NumMapRows
            for NdxCol2=1:NumMapColumns
                DistTopol=norm(Coord1-[NdxRow2 NdxCol2]);
                Coef(NdxRow1,NdxCol1,NdxRow2,NdxCol2)=...
                    LearningRate*exp(-(DistTopol/MyRadius)^2);
            end
        end            
    end
end


