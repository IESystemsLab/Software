function [ pd, truncateNegativeValues ] = HELPER_GetProbDistObj( Demand_distrib, Demand_mean, Demand_SCV )
% This function goes hand-in-hand with HELPER_DistribParamsFromMeanAndVar.
%
% HELPER_DistribParamsFromMeanAndVar returns distribution-specific parameters to realize a 
% particular mean and variance, in a struct which is formatted for a SimEvents Event-Based Random
% Number Generator block.
%
% However, that struct isn't helpful for inventory models because a one-decision inventory model
% like Newsvendor isn't well suited to a SimEvents time-stepping simulation, and is better suited to
% a Monte Carlo simulation right in the MATLAB workspace.  Therefore, this function reformats the 
% output of HELPER_DistribParamsFromMeanAndVar for use with the Statistics Toolbox' RANDOM function.
%
% Non-negative distributions which this function currently supports (e.g. which can be inverted from
% mean & variance to distribution-specific parameters):
% { exponential,  uniform_nonneg,  triangular_symmetric_nonneg,  gamma,  lognormal }
% Possibly-negative distributions which this function currently supports:
% { normal }


%% LICENSE:  3-clause "Revised" or "New" or "Modified" BSD License
% Copyright (c) 2015, Georgia Institute of Technology.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of the Georgia Institute of Technology nor the
%       names of its contributors may be used to endorse or promote products
%       derived from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE GEORGIA INSTITUTE OF TECHNOLOGY BE LIABLE FOR 
% ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


%% Check File Dependencies
f1 = 'HELPER_DistribParamsFromMeanAndVar.m';
HELPER_ValidateFileDependencies({f1});


%% Validate Inputs
if iscell(Demand_distrib) || length(Demand_mean) > 1 || length(Demand_SCV) > 1
	error('At present, this function is not vectorized in any of the demand distribution''s type, mean, or SCV.');
end


%% Get Distribution-Specific Parameters formatted for a SimEvents Event-Based Random Number Generator block
Demand_variance = Demand_mean^2 * Demand_SCV;
[distribTypeInMLSyntax, distribParams] = HELPER_DistribParamsFromMeanAndVar( Demand_distrib, Demand_mean, Demand_variance );


%% Reformat for use with the Statistics Toolbox' RANDOM function
truncateNegativeValues = 0;

%Non-negative distributions
if strcmp(distribTypeInMLSyntax, 'exponential')
    pd = makedist(distribTypeInMLSyntax, 'mu', distribParams.meanExp);    
elseif strcmp(distribTypeInMLSyntax, 'uniform')
    pd = makedist(distribTypeInMLSyntax, 'lower', distribParams.minUnif, 'upper', distribParams.maxUnif);    
elseif strcmp(distribTypeInMLSyntax, 'triangular')
    pd = makedist(distribTypeInMLSyntax, 'a', distribParams.minTri, 'b', distribParams.modeTri, 'c', distribParams.maxTri);   
elseif strcmp(distribTypeInMLSyntax, 'gamma')
    pd = makedist(distribTypeInMLSyntax, 'a', distribParams.shapeGam, 'b', distribParams.scaleGam);
elseif strcmp(distribTypeInMLSyntax, 'lognormal')
    pd = makedist(distribTypeInMLSyntax, 'mu', distribParams.scaleLogn, 'sigma', distribParams.shapeLogn);

%General distributions
elseif strcmp(distribTypeInMLSyntax, 'gaussian')
    distribTypeInMLSyntax = 'normal';  %MAKEDIST doesn't recognize 'gaussian'
    pd = makedist(distribTypeInMLSyntax, 'mu', distribParams.meanNorm, 'sigma', distribParams.stdNorm);
    truncateNegativeValues = 1;
end