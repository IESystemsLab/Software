%% Purpose
% The purpose of the following demo is to reproduce figure 2.2 in Hopp & Spearman (pg. 51 in ed. 2),
% except for the Qr inventory model instead of the EOQ model.  However, that task is inherently difficult 
% because while the expected cost curves for EOQ or Base Stock have only one independent variable (lot
% size Q for EOQ, base stock level R for Base Stock), the Qr model has two, both Q and R. Therefore,
% the output will be 3-D surfaces rather than 2-D curves.  The demo invokes the simulation model 
% 'ProdSystem_QrAssumptionsAndCosts' (through its wrapper function) over a range of lot sizes Q and
% reorder points R.  The output is visualizations of average costs incurred for each value of (Q, R)
% - total costs, lot setup costs, inventory holding costs, backorder costs, and production costs.
% An additional visualization shows fill rate (the fraction of demand filled without backorder and
% delay) for each value of (Q, R).
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, replenishment lead times' distribution, mean, and variability, the product's
% production cost, lot setup cost, inventory holding cost, and backorder cost, and a range of lot
% sizes Q and reorder points R.
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


%% Input Parameters
DemandUnitsPerYear_mean = 140;
DemandInterarrivalTime_Distrib = 'gamma';
DemandInterarrivalTime_SCV = 1;

ReplenishLeadTime_Distrib = 'gamma';
ReplenishLeadTimeYears_mean = 1.5/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;
LotSetupCost_A = 50;
UnitAnnualHoldingCost_H = 30;
UnitAnnualBackorderCost_B = 100;

LotSize_Q = 2 : 2 : 50;  %Sweep over this
ReorderPoint_R = 2 : 2 : 50;  %Sweep over this

nReps = 3;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_QrAssumptionsAndCosts';
f2 = 'Inventory_BaseStock_ComputeRStar';
f3 = 'Inventory_EOQ_ComputeQStar';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Analytical Optimum
QStar = Inventory_EOQ_ComputeQStar( DemandUnitsPerYear_mean, LotSetupCost_A, UnitAnnualHoldingCost_H );
RStar = Inventory_BaseStock_ComputeRStar( ReplenishLeadTimeYears_mean, ...
    DemandInterarrivalTime_Distrib, DemandUnitsPerYear_mean, DemandInterarrivalTime_SCV, ...
    UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B );


%% Simulate
FillRate_reps = zeros(nReps, 1);
CostPerSatDmd_Total_reps = zeros(nReps, 1);
CostPerSatDmd_Inventory_reps = zeros(nReps, 1);
CostPerSatDmd_Backorder_reps = zeros(nReps, 1);
CostPerSatDmd_Production_reps = zeros(nReps, 1);
CostPerSatDmd_Setup_reps = zeros(nReps, 1);
nQ = length(LotSize_Q);
nR = length(ReorderPoint_R);
FillRate = zeros(nQ, nR);
CostPerSatDmd_Total = zeros(nQ, nR);
CostPerSatDmd_Inventory = zeros(nQ, nR);
CostPerSatDmd_Backorder = zeros(nQ, nR);
CostPerSatDmd_Production = zeros(nQ, nR);
CostPerSatDmd_Setup = zeros(nQ, nR);

%Outer loop for sweep variable
for ii = 1 : nQ
    
	%Outer loop for sweep variable
	for jj = 1 : nR
		
		%Inner loop for replications
		for kk = 1 : nReps
			[	FillRate_reps(kk), nBackorders, CostPerSatDmd_Total_reps(kk), ...
				CostPerSatDmd_Inventory_reps(kk), CostPerSatDmd_Backorder_reps(kk), CostPerSatDmd_Production_reps(kk), CostPerSatDmd_Setup_reps(kk) ] = ...
			SimWrapper_ProdSystem_QrAssumptionsAndCosts( ...
				SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
				UnitProductionCost_C, LotSetupCost_A, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
				ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
				LotSize_Q(ii), ReorderPoint_R(jj), minDepartBeforeSimStop );
		end
		
		%Average over all replications
		FillRate(ii,jj) = mean(FillRate_reps);
		CostPerSatDmd_Total(ii,jj) = mean(CostPerSatDmd_Total_reps);
		CostPerSatDmd_Inventory(ii,jj) = mean(CostPerSatDmd_Inventory_reps);
		CostPerSatDmd_Backorder(ii,jj) = mean(CostPerSatDmd_Backorder_reps);
		CostPerSatDmd_Production(ii,jj) = mean(CostPerSatDmd_Production_reps);
		CostPerSatDmd_Setup(ii,jj) = mean(CostPerSatDmd_Setup_reps);
	end
end


%% Empirical Optimum
[colMinValues, colMinIndexes] = min(CostPerSatDmd_Total);
[smallestColValue, smallestColIndex] = min(colMinValues);
RStarSim = ReorderPoint_R(smallestColIndex);
QStarSim = LotSize_Q(colMinIndexes(smallestColIndex));


%% Visualize Costs versus R, Fill Rate versus R
Qrepd = repmat(LotSize_Q', 1, nR);
Rrepd = repmat(ReorderPoint_R, nQ, 1);

figure;
surf(Qrepd, Rrepd, CostPerSatDmd_Total);
xlabel('Lot Size Q');
ylabel('Reorder Point R');
zlabel('Total Cost (per satisfied demand)');
title({'Production System with Qr Assumptions.', ...
    ['(Analytical Q*=' num2str(QStar) ', R*=' num2str(RStar) '.  Simulation Q*=' num2str(QStarSim) ', R*=' num2str(RStarSim) '.)']}, ...
    'FontWeight', 'Normal');

figure;
surf(Qrepd, Rrepd, FillRate);
xlabel('Lot Size Q');
ylabel('Reorder Point R');
zlabel('Fill Rate (fraction of demand filled without delay)');
title({'Production System with Qr Assumptions.', ...
    ['(Analytical Q*=' num2str(QStar) ', R*=' num2str(RStar) '.  Simulation Q*=' num2str(QStarSim) ', R*=' num2str(RStarSim) '.)']}, ...
    'FontWeight', 'Normal');

f3 = figure;
figScaling = 1.6;
p3 = get(f3, 'Position');
set(f3, 'Position', [p3(1)-(figScaling-1)*p3(3), p3(2)-(figScaling-1)*p3(4), p3(3)*figScaling, p3(4)*figScaling]);
CostSurfaces = {CostPerSatDmd_Inventory, CostPerSatDmd_Backorder, CostPerSatDmd_Production, CostPerSatDmd_Setup};
SurfaceNames = {'Inventory', 'Backorder', 'Production', 'Setup'};
for jj = 1 : 4
    subplot(2,2,jj)
    surf(Qrepd2, Rrepd2, CostSurfaces{jj});
    xlabel('Lot Size Q');
    ylabel('Reorder Point R');
    zlabel([SurfaceNames{jj} ' Cost (per sat dmd)']);
end
