function [A, b, Volume]=GenerateRandomAffineTransform(Dimension,LowerMargin,UpperMargin)
% Generate a random affine transform
% Coded by Ezequiel Lopez-Rubio. October 2014.
% Inputs:
%   Dimension                   Dimension of the input space
%   LowerMargin                 Lower scale parameter theta_min
%   UpperMargin                 Upper scale parameter theta_max

% Generate a random translation uniformly
b=rand(Dimension,1);

% Generate a random rotation uniformly
[Q,R]=qr(randn(Dimension));
Q=Q*diag(sign(diag(R)));
if det(Q)<0
    Q(:,1)=-Q(:,1);
end

Range=UpperMargin-LowerMargin;

% Generate a random scaling matrix uniformly
Lambda=diag(exp(LowerMargin+Range*rand(Dimension,1)));

% Compute the transformation matrix and the bin volume
A=Q*Lambda;
Volume=1/prod(diag(Lambda));





