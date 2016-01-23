function [ distribTypeInMLSyntax, params ] = HELPER_DistribParamsFromMeanAndVar( distribType, distribMean, distribVariance )
% This is a key helper function.  For a user's choice of distribution type, it attempts to invert
% mean and variance to distribution-specific parameters (which is not always possible).  This is
% invaluable in comparing queueing theory approximations and simulation results, because most 
% queueing theory approximations presented in Hopp & Spearman rely on mean and variance *with no
% assumptions about distribution type*.  Simulation, however, requires explicit choices for
% distribution types whenever random numbers are generated.
%
% The inversion generally only works for two-parameter distributions, because that results in two
% parameters in two unknowns.  One consequence of this is that exponential won't work because it's a
% one-parameter distribution; you can arbitrarily choose the mean or the variance but not both,
% because the mean must equal the square root of the variance.  Similarly, restricting assumptions 
% must be made for three- and four-parameter distributions (triangular, beta) to reduce the number
% of free parameters to two.
%
% The full list of distribution possibilities are documented for the SimEvents "Event Based Random
% Number" block at:
% web(fullfile(docroot, 'simevents/ref/eventbasedrandomnumber.html'))
%
% Of that list, only a subset are implemented here.
%
% INPUT:  Supply a distribution type, mean, and variance (as scalars, because this function is not vectorized).
%
% OUTPUT:  A structure with parameter names and values *which are specific to a SimEvents
% Event-Based Random Number Generator block*.


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


%% Validate Inputs
if (length(distribMean) > 1 || length(distribVariance) > 1)
    error('This function is not vectorized.  Vectorization could be done using an inner FOR loop, but it is left to the user to do that outside this function.');
end

if (distribVariance <= 0)  %|| distribMean <= 0
    error('Variance should be a positive number.');
end


%% Switch on Distribution Type
%String matching is undesirable; help a little by making it case-insensitive
distribType = lower(distribType);

if strcmp(distribType, 'exponential')
    %Support [0, inf)
    %Parameter 'meanExp' > 0, which for exponential is also the standard deviation
    warning('Exponential is a single-parameter distribution; you can independently set the mean or the variance but not both.  Proceeding with the user-supplied mean, and ignoring the user-supplied variance.');
    params = struct('meanExp', distribMean);
	
elseif strcmp(distribType, 'uniform')
    %Support [a, b]
    %Params 'minUnif', 'maxUnif'
    distribStdev = sqrt(distribVariance);
    scaledStdev = sqrt(12)/2 * distribStdev;
    a = distribMean - scaledStdev;
    b = distribMean + scaledStdev;
    params = struct('maxUnif', b, 'minUnif', a);
    
elseif strcmp(distribType, 'uniform_nonneg')
    %(This version works the same as the previous until a=0)
    distribStdev = sqrt(distribVariance);
    scaledStdev = sqrt(12)/2 * distribStdev;
    a = distribMean - scaledStdev;
    b = distribMean + scaledStdev;
    if a < 0
        error('Cannot realize a nonnegative uniform random variable with that mean and variance.');
    end
    params = struct('maxUnif', b, 'minUnif', a);
    
elseif strcmp(distribType, 'triangular_symmetric')
    %Support [a, b]
    %Params 'minTri', 'maxTri', 'modeTri'
    distribStdev = sqrt(distribVariance);
    scaledStdev = sqrt(24)/2 * distribStdev;
    a = distribMean - scaledStdev;
    b = distribMean + scaledStdev;
    c = (a+b)/2;  %symmetric
    params = struct('maxTri', b, 'minTri', a, 'modeTri', c);
    
elseif strcmp(distribType, 'triangular_symmetric_nonneg')
    %(This version works the same as the previous until a=0, then it fixes a=0 and becomes non-symmetric)
    distribStdev = sqrt(distribVariance);
    scaledStdev = sqrt(24)/2 * distribStdev;
    a = distribMean - scaledStdev;
    b = distribMean + scaledStdev;
    c = (a+b)/2;  %symmetric
    if a < 0
        %Switch models
        a = 0;
        criticalTerm = 24*distribVariance - 3*distribMean^2;
        sqrtCriticalTerm = sqrt(criticalTerm);
        if criticalTerm >= 0 && 3*distribMean >= sqrtCriticalTerm  %e.g. 2*sigma^2 <= mu^2 <= 8*sigma^2
            b = 0.5*(3*distribMean + sqrtCriticalTerm);
            c = 0.5*(3*distribMean - sqrtCriticalTerm);
        else
            error('Cannot realize a nonnegative triangular random variable with that mean and variance.');
        end
    end
    params = struct('maxTri', b, 'minTri', a, 'modeTri', c);
    
elseif strcmp(distribType, 'gamma')
    %Support (0, Inf) => 'thresholdGam'==0
    %Params 'thresholdGam', 'scaleGam', 'shapeGam'
    L = 0;
    a = distribMean^2 / distribVariance;  %shape
    b = distribVariance / distribMean;  %scale
    params = struct('thresholdGam', L, 'shapeGam', a, 'scaleGam', b);
    
elseif strcmp(distribType, 'gaussian') || strcmp(distribType, 'normal')
    distribType = 'gaussian';
    %Support (-Inf, Inf)
    %Params 'meanNorm', 'stdNorm'
    distribStdev = sqrt(distribVariance);
    params = struct('meanNorm', distribMean, 'stdNorm', distribStdev);
    
elseif strcmp(distribType, 'lognormal')
    %Support (0, Inf) => 'thresholdLogn'==0
    %Params 'thresholdLogn', 'scaleLogn', 'shapeLogn'
    L = 0;
    sigSq = log(distribVariance*exp(-2*log(distribMean)) + 1);
    sig = sqrt(sigSq);
    mu = log(distribMean) - sigSq/2;
    params = struct('thresholdLogn', L, 'scaleLogn', mu, 'shapeLogn', sig);
    
elseif strcmp(distribType, 'log-logistic')
    %Support [0, Inf)
    %Params 'thresholdLogl', 'scaleLogl'
    
    %TO-DO:  Reconcile params and density in EventBasedRandomNumber doc versus Wikipedia.
    
elseif strcmp(distribType, 'beta_halftooneandonehalfmean')
    %Support (L, U)
    %Params 'minBeta', 'maxBeta', 'shape1Beta', 'shape2Beta'
    L = distribMean * 0.5;  %arbitrary
    U = distribMean * 1.5;  %arbitrary
    mu = (distribMean - L) / (U - L);
    sigSq = distribVariance / (U - L)^2;
    sharedTerm = mu*(1-mu)/sigSq - 1;
    alpha = mu * sharedTerm;
    beta = (1-mu) * sharedTerm;
    params = struct('maxBeta', U, 'minBeta', L, 'shape1Beta', alpha, 'shape2Beta', beta);
    
elseif strcmp(distribType, 'weibull')
    %Support [0, Inf)
    %Parameters 'shapeWbl' > 0 and 'scaleWbl' > 0
    
    %TO-DO:  This requires inverting the gamma function?
    
else
    error(['The distribution type ' distribType ' is not implemented.']);
end


%% The output 'distribTypeInMLSyntax' is a MATLAB-specific string
distribTypeInMLSyntax = strsplit(distribType, '_');  %Returns a cell array of strings
distribTypeInMLSyntax = distribTypeInMLSyntax{1};