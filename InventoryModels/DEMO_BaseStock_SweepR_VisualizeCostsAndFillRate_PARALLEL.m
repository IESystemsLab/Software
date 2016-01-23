%% Purpose
% The purpose of the following demo is to reproduce figure 2.2 in Hopp & Spearman (ed. 2), except
% for the Base Stock inventory model instead of the EOQ model.  The demo invokes the simulation
% model 'ProdSystem_BaseStockAssumptionsAndCosts' (through its wrapper function) over a range of
% base stock levels R.  The output is a visualization of average costs incurred for each value of R
% - total cost, inventory holding cost, backorder cost, and production cost.  Additional
% visualizations include fill rate (the fraction of demand filled without backorder and delay)
% as a function of R, statistics about the distribution of backorder level as a function of R, and
% an alternative visualization plotting costs against fill rate for each value of R, given that fill
% rate targets are often analysis _inputs_ rather than _outputs_.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, replenishment lead times' distribution, mean, and variability, the product's unit
% production cost, inventory holding cost, and backorder cost, and a range of base stock levels R.
%
% UPDATE:  The _PARALLEL_ version of this demo supercedes the _SERIAL_ version.  It should produce
% exactly the same results, just much faster.  It introduces parallelization by replacing several 
% nested FOR loops with a single PARFOR loop, which by default will start and use as many background
% MATLAB sessions as your processor has cores.
%
% Base Stock _system_ assumptions:
%
% * Products are separable with no shared interactions.  This enables single-product analysis.
% * Demands occur one at a time, and there are no batch orders.  This assumption is built into the
% simulation model because (to the best of my knowledge) a Time-Based Entity Generator does not
% support batch generation of entities.  If desired, demand inter-arrival times can be made
% deterministic by choosing the normal distribution with stdev=eps, as close to zero as possible in
% MATLAB.
% * Demand which is not filled immediately is backordered, and there are no lost sales.
% * A replenishment order is placed every time a demand occurs.
% * Production and delivery of replenishment orders are NOT instantaneous, but rather require a
% fixed and known replenishment lead time.  The "fixed and known" assumption is relaxed in the
% simulation model - replenishment lead times can be random, or made deterministic by choosing the
% normal distribution with stdev=eps, which is as close to zero as possible.
% * *Inventory Position* is defined as on-hand inventory, plus open orders (not yet filled due to
% replenishment lead time), minus backorders.  The inventory position should always equal the base
% stock level R.
%
% Base Stock _cost_ assumptions:
%
% * Each unit ordered incurs a fixed production cost (cost/unit)
% * Each unit in inventory incurs a time-dependent holding cost (cost/unit-time)
% * Each demand backordered incurs a time-dependent backorder cost (cost/unit-time)
% * There is NOT any fixed cost associated with a replenishment order, nor any constraint on the
% number of replenishment orders that can be placed in any time window.


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
f1 = 'SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts';
HELPER_ValidateFileDependencies({f1});


%% Input Parameters
DemandUnitsPerYear_mean = 120;
DemandInterarrivalTime_Distrib = 'gamma';
DemandInterarrivalTime_SCV = 1;

ReplenishLeadTime_Distrib = 'gamma';
ReplenishLeadTimeYears_mean = 1/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;  %In Hopp & Spearman's Base Stock example this is 750, but to scale plots I'll reduce it to 1.
UnitAnnualHoldingCost_H = 180;
UnitAnnualBackorderCost_B = 300;

BaseStockLevel_R = 5 : 1 : 20;  %Sweep over this

nReps = 10;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Simulate
nR = length(BaseStockLevel_R);
N = nR * nReps;
Rrepd2 = repmat(BaseStockLevel_R', 1, nReps);

FillRate2 = zeros(nR, nReps);
CostPerSatDmd_Total2 = zeros(nR, nReps);
CostPerSatDmd_Inventory2 = zeros(nR, nReps);
CostPerSatDmd_Backorder2 = zeros(nR, nReps);
CostPerSatDmd_Production2 = zeros(nR, nReps);
nBackorders2 = cell(nR, nReps);

parfor ii = 1 : N
    %What makes this challenging:  I need to collapse two FOR loops (for ii=1:nR, for jj=1:nReps)
    %into a single PARFOR loop.  This means that I must use a single index to iterate over values of
    %R and replications.  To do this, rely on MATLAB behavior that when single-indexing into a
    %multi-dimensional array, the 1st dimension is rows and the 2nd dimension is columns.
	% 1st dim (rows):  Sweep R
	% 2nd dim (columns):  replications (for the same values of Q and R)
    [	FillRate2(ii), nBackorders2{ii}, ...
		CostPerSatDmd_Total2(ii), CostPerSatDmd_Inventory2(ii), CostPerSatDmd_Backorder2(ii), CostPerSatDmd_Production2(ii) ] = ...
	SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts( ...
		SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
    	UnitProductionCost_C, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
        ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
		Rrepd2(ii), minDepartBeforeSimStop );
end


%% Flatten replications (average over all)
repDim = 2;
FillRate = mean(FillRate2, repDim);
CostPerSatDmd_Total = mean(CostPerSatDmd_Total2, repDim);
CostPerSatDmd_Inventory = mean(CostPerSatDmd_Inventory2, repDim);
CostPerSatDmd_Backorder = mean(CostPerSatDmd_Backorder2, repDim);
CostPerSatDmd_Production = mean(CostPerSatDmd_Production2, repDim);
%The handling of backorder samples is a bit arcane, but shape this way because HELPER_VisualizationType6
%is already written and this is what it expects.
nBackorders = cell(nR, 1);
nBackorders2T = nBackorders2';
for jj = 1 : nR
    nBackorders{jj} = cell2mat(nBackorders2T(:,jj));
end


%% Visualize
xvals = BaseStockLevel_R;
xvalsLabel = 'Base Stock Level R';
textLabel = 'R';
sharedTitle = 'System with BASE STOCK assumptions and costs';
HELPER_VisualizationType6( ...
	CostPerSatDmd_Total, CostPerSatDmd_Inventory, CostPerSatDmd_Backorder, CostPerSatDmd_Production, ...
	FillRate, nBackorders, ...
	xvals, xvalsLabel, textLabel, sharedTitle );