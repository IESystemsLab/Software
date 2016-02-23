%% Purpose
% The purpose of the following demo is to reproduce figure 2.2 in Hopp & Spearman (ed. 2).  The demo
% invokes the simulation model 'ProdSystem_EOQAssumptionsAndCosts' (through its wrapper function)
% over a range of lot sizes Q.  The output is a visualization of average costs incurred for each
% value of Q - total costs, inventory holding costs, lot setup costs, and production costs.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, the product's production cost, inventory holding cost, and lot setup cost,
% and a range of lot sizes Q.
%
% EOQ _system_ assumptions:
%
% * Products are separable with no shared interactions.  This enables single-product analysis.
% * Demand is deterministic with a constant rate over time.  This assumption is relaxed in the
% simulation model; demand can be random, or made deterministic by choosing the normal distribution
% with stdev=eps, which is as close to zero as possible.
% * When inventory drops to zero, a lot of size Q is immediately reordered.
% * Production and delivery of a lot are instantaneous.
%
% EOQ cost assumptions:
%
% * Each unit ordered incurs a fixed production cost (cost/unit)
% * Each lot of Q units ordered incurs a fixed setup cost (cost/lot)
% * Each unit in inventory incurs a time-dependent holding cost (cost/unit-time)


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
DemandUnitsPerYear_mean = 1000;
DemandInterarrivalTime_Distrib = 'normal';
DemandInterarrivalTime_SCV = eps;

UnitProductionCost_C = 1;  %In Hopp & Spearman's EOQ example this is 500, but to make figure 2.2 (edition 2) they reduce it to 1.
LotSetupCost_A = 500;  
UnitAnnualHoldingCost_H = 35;

LotSize_Q = 30 : 5 : 250;  %Sweep over this

nReps = 3;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_EOQAssumptionsAndCosts';
HELPER_ValidateFileDependencies({f1});


%% Storage Variables for Simulation Results
CostPerSatDmd_Total_reps = zeros(nReps, 1);
CostPerSatDmd_Setup_reps = zeros(nReps, 1);
CostPerSatDmd_Production_reps = zeros(nReps, 1);
CostPerSatDmd_Inventory_reps = zeros(nReps, 1);
nK = length(LotSize_Q);
CostPerSatDmd_Total = zeros(nK, 1);
CostPerSatDmd_Setup = zeros(nK, 1);
CostPerSatDmd_Production = zeros(nK, 1);
CostPerSatDmd_Inventory = zeros(nK, 1);


%% Simulate

%Outer loop for sweep variable
for ii = 1 : nK

	%Inner loop for replications
	for jj = 1 : nReps
		[ CostPerSatDmd_Total_reps(jj), CostPerSatDmd_Setup_reps(jj), CostPerSatDmd_Production_reps(jj), CostPerSatDmd_Inventory_reps(jj) ] = ...
			SimWrapper_ProdSystem_EOQAssumptionsAndCosts( ...
				SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
				UnitProductionCost_C, LotSetupCost_A, UnitAnnualHoldingCost_H, ...
				LotSize_Q(ii), minDepartBeforeSimStop );
    end
    
	%Average over all replications
	CostPerSatDmd_Total(ii) = mean(CostPerSatDmd_Total_reps);
	CostPerSatDmd_Setup(ii) = mean(CostPerSatDmd_Setup_reps);
	CostPerSatDmd_Production(ii) = mean(CostPerSatDmd_Production_reps);
	CostPerSatDmd_Inventory(ii) = mean(CostPerSatDmd_Inventory_reps);
end


%% Visualize
xvals = LotSize_Q;
xvalsLabel = 'Lot Size Q';
figure, hold on, box off;

plot(xvals, CostPerSatDmd_Total, 'k');
text(xvals(1), CostPerSatDmd_Total(1), 'Total Cost', ...
	'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'k');

plot(xvals, CostPerSatDmd_Inventory, 'r--');
text(xvals(1), CostPerSatDmd_Inventory(1), 'Inventory Cost', ...
	'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'r');

plot(xvals, CostPerSatDmd_Setup, 'g--');
text(xvals(1), CostPerSatDmd_Setup(1), 'Setup Cost', ...
	'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'g');

plot(xvals, CostPerSatDmd_Production, 'b--');
text(xvals(1), CostPerSatDmd_Production(1), 'Production Cost', ...
	'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'b');

xlabel(xvalsLabel);
ylabel('Costs (per satisfied demand)');
title('System with EOQ assumptions and costs');
