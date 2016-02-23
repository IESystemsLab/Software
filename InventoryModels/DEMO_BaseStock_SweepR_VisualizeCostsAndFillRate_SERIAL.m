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


%% Input Parameters
DemandUnitsPerYear_mean = 120;
DemandInterarrivalTime_Distrib = 'gamma';
DemandInterarrivalTime_SCV = 1;

ReplenishLeadTime_Distrib = 'gamma';
ReplenishLeadTimeYears_mean = 1/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;  %In Hopp & Spearman's base stock example this is 750, but to scale plots I'll reduce it to 1.
UnitAnnualHoldingCost_H = 180;
UnitAnnualBackorderCost_B = 300;

BaseStockLevel_R = 5 : 1 : 20;  %Sweep over this

nReps = 10;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts';
HELPER_ValidateFileDependencies({f1});


%% Simulate
FillRate_reps = zeros(nReps, 1);
CostPerSatDmd_Total_reps = zeros(nReps, 1);
CostPerSatDmd_Inventory_reps = zeros(nReps, 1);
CostPerSatDmd_Backorder_reps = zeros(nReps, 1);
CostPerSatDmd_Production_reps = zeros(nReps, 1);
nBackorders_reps = cell(nReps, 1);
nR = length(BaseStockLevel_R);
FillRate = zeros(nR, 1);
CostPerSatDmd_Total = zeros(nR, 1);
CostPerSatDmd_Inventory = zeros(nR, 1);
CostPerSatDmd_Backorder = zeros(nR, 1);
CostPerSatDmd_Production = zeros(nR, 1);
nBackorders = cell(nR, 1);

%Outer loop for sweep variable
for ii = 1 : nR
	
	%Inner loop for replications
	for jj = 1 : nReps
		[	FillRate_reps(jj), nBackorders_reps{jj}, ...
			CostPerSatDmd_Total_reps(jj), CostPerSatDmd_Inventory_reps(jj), CostPerSatDmd_Backorder_reps(jj), CostPerSatDmd_Production_reps(jj) ] = ...
		SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts( ...
			SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
            UnitProductionCost_C, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
            ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
			BaseStockLevel_R(ii), minDepartBeforeSimStop );
	end
	
	%Average over all replications
	FillRate(ii) = mean(FillRate_reps);
	CostPerSatDmd_Total(ii) = mean(CostPerSatDmd_Total_reps);
    CostPerSatDmd_Inventory(ii) = mean(CostPerSatDmd_Inventory_reps);
	CostPerSatDmd_Backorder(ii) = mean(CostPerSatDmd_Backorder_reps);
	CostPerSatDmd_Production(ii) = mean(CostPerSatDmd_Production_reps);
	nBackorders{ii} = cell2mat(nBackorders_reps);
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
