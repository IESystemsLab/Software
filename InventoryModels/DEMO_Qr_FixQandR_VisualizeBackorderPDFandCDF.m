%% Purpose
% The following demo fixes Q, R, and all other parameters, collects many samples of the backorder
% level across multiple replications, and returns visualizations of the backorder level's empirical
% distribution (its PDF and CDF).
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, replenishment lead times' distribution, mean, and variability, the product's
% production cost, lot setup cost, inventory holding cost, and backorder cost, and the lot size Q
% and reorder point R.
%
% Qr _system_ assumptions:
%
% * Products are separable with no shared interactions.  This enables single-product analysis.
% * Demands occur one at a time, and there are no batch demands.  This assumption is built into the
% simulation model because (to the best of my knowledge) a Time-Based Entity Generator does not
% support batch generation of entities.  If desired, demand inter-arrival times can be made
% deterministic by choosing the normal distribution with stdev=eps, which is as close to zero as
% possible.
% * Demand which is not filled immediately is backordered, and there are no lost sales.
% * *Inventory Position* is defined as on-hand inventory, plus open orders (not yet filled due to
% replenishment lead time), minus backorders.  The inventory position in the QR model should
% oscillate between R and Q+R.
% * A replenishment order for a lot of size Q is placed immediately whenever the inventory position
% decreases to R.  Because replenishment orders are placed immediately, the inventory position
% should never spend time at level R, but upon decreasing to R then jump immediately to Q+R.
% * Production and delivery of replenishment orders are NOT instantaneous, but rather require a
% fixed and known replenishment lead time.  The "fixed and known" assumption is relaxed in the
% simulation model - replenishment lead times can be random, or made deterministic by choosing the
% normal distribution with stdev=eps, which is as close to zero as possible.
%
% Qr _cost_ assumptions:
%
% * Each unit ordered incurs a fixed production cost (cost/unit)
% * Each lot of Q units ordered incurs a fixed setup cost (cost/lot).  An alternative described in
% Hopp & Spearman is to constrain the maximum number of replenishment orders per time window, but
% this alternative is not implemented in the simulation model 'ProdSystem_QrAssumptionsAndCosts'.
% * Each unit in inventory incurs a time-dependent holding cost (cost/unit-time)
% * Each demand backordered incurs a time-dependent backorder cost (cost/unit-time)


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
f1 = 'SimWrapper_ProdSystem_QrAssumptionsAndCosts';
HELPER_ValidateFileDependencies({f1});


%% Input Parameters
DemandUnitsPerYear_mean = 140;
DemandInterarrivalTime_Distrib = 'gamma';
DemandInterarrivalTime_SCV = 1;

ReplenishLeadTime_Distrib = 'gamma';
ReplenishLeadTimeYears_mean = 1.5/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;
LotSetupCost_A = 15;
UnitAnnualHoldingCost_H = 30;
UnitAnnualBackorderCost_B = 100;

LotSize_Q = 10;
ReorderPoint_R = 12;

nReps = 10;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Simulate
nBackorders_reps = cell(nReps, 1);

%Inner loop for replications
for ii = 1 : nReps
    [ FillRate, nBackorders_reps{ii} ] = ...
	SimWrapper_ProdSystem_QrAssumptionsAndCosts( ...
        SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
        UnitProductionCost_C, LotSetupCost_A, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
        ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
		LotSize_Q, ReorderPoint_R, minDepartBeforeSimStop );
end
%Flatten all replications into a single matrix
nBackorders = cell2mat(nBackorders_reps);


%% Visualize
f1 = figure;
hist(nBackorders, max(nBackorders)+1);  %Before R2015a
%histogram(nBackorders, max(nBackorders)+1);  %R2015a and beyond
box off
xlabel('Backorder Level');
ylabel(['Number of samples in a bin (out of ' num2str(length(nBackorders)) ' samples)']);
title(['Empirical PDF of Backorder Level  (LotSize Q=' num2str(LotSize_Q) ', ReorderPoint R=' num2str(ReorderPoint_R) ')'], 'FontWeight', 'Normal');

f2 = figure;
cdfplot(nBackorders);
xlabel('Backorder Level');
ylabel('Fraction of Time with <= Backorder Level');
title(['Empirical CDF of Backorder Level  (LotSize Q=' num2str(LotSize_Q) ', ReorderPoint R=' num2str(ReorderPoint_R) ')'], 'FontWeight', 'Normal');