function [ QStar ] = Inventory_Newsvendor_ComputeQStar( ...
	Demand_distrib, Demand_mean, Demand_SCV, ...
	Cost_orderTooLittle, Cost_orderTooMuch )
% For the Newsvendor inventory model, this function computes an optimal order quantity Q.  The
% formula implemented for the optimal solution is derived in Hopp & Spearman section 2.4.1 (ed. 2).
% At the time of writing, supported demand distribution types include exponential, uniform, 
% triangular_symmetric, gamma, lognormal, and normal.
%
% Two inputs need explanation:
% - Cost_orderTooLittle is what Hopp & Spearman call "cost per unit of shortage".  It's the cost of
% incurred when demand exceeds supply, a.k.a. the lost profit from a missed sale, a.k.a. opportunity
% cost.  It is usually computed as sale price minus production or purchase cost.
%
% - Cost_orderTooMuch is what Hopp & Spearman call "cost per unit left over after demand is
% realized".  It's the cost incurred when supply exceeds demand, a.k.a. the lost amount from
% ordering excess units.  It is usually computed as production or purchase cost minus salvage price.
%
% It is the user's burden to consider if lost opportunity should be treated equally to lost cash.


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
criticalRatio = Cost_orderTooLittle / (Cost_orderTooMuch + Cost_orderTooLittle);
pd = HELPER_GetProbDistObj(Demand_distrib, Demand_mean, Demand_SCV);
QStar = icdf(pd, criticalRatio);
QStar = round(QStar);