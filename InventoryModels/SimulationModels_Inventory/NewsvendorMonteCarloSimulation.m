function [ ExpectedProfit, ProbLosingMoney, profitSamples ] = NewsvendorMonteCarloSimulation( ...
    Demand_distrib, Demand_mean, Demand_SCV, ...
    CostPerUnit, PricePerUnit, SalvageValuePerUnit, ...
    QPoints, nReplications )
% The newsvendor model only concerns a single, one-time inventory replenishment, as opposed to EOQ,
% Base Stock, and Qr which concern recurring inventory replenishments.  (The newsvendor model can be
% extended to multi-replenishment scenarios, but that is beyond the scope of an undergraduate class.)
% Therefore, a time-stepping simulation isn't appropriate for this demo.  Instead, this function
% performs a Monte Carlo simulation right in the MATLAB workspace.


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
f1 = 'HELPER_GetProbDistObj';
HELPER_ValidateFileDependencies({f1});


%% Compute
nQ = length(QPoints);
Qrepd = repmat(QPoints', 1, nReplications);

%Call a wrapper for MAKEDIST
[pd, truncateNegativeValues] = HELPER_GetProbDistObj(Demand_distrib, Demand_mean, Demand_SCV);

%Sample by calling RANDOM (Statistics Toolbox)
DemandSamples = random(pd, nQ, nReplications);
if truncateNegativeValues  %Note that truncating at zero *changes the distribution*
    DemandSamples = max(DemandSamples, zeros(nQ, nReplications));
end

%Deterministic cost computations
nSold = min(Qrepd, DemandSamples);
nOver = max(Qrepd - DemandSamples, zeros(nQ, nReplications));
%nUnder = max(DemandSamples - Qrepd, zeros(nK, nReps));

revenue = PricePerUnit * nSold;
unitCosts = CostPerUnit * Qrepd;
salvageRevenue = SalvageValuePerUnit * nOver;
%opportunityCosts = Cost_under * nUnder;


%% Outputs
profitSamples = revenue + salvageRevenue - unitCosts;  %- opportunityCosts;
ExpectedProfit = mean(profitSamples, 2);  %Average over the replications (columns)
ProbLosingMoney = sum(profitSamples < 0, 2) / nReplications;