%% Purpose
% The following demo sweeps over demand interarrival time variability, as measured by SCV (squared
% coefficient of variability, the variance divided by the mean^2).  The demo invokes the simulation
% model 'ProdSystem_BaseStockAssumptionsAndCosts' (through its wrapper function) over a range of
% demand interarrival time SCVs.  One output is a visualization of costs incurred (total, inventory
% holding, backorder, and production) as demand interarrival time SCV increases.  A second output is
% a visualization of fill rate as demand interarrival time SCV increases.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and a range of SCVs, replenishment lead times' distribution, mean, and variability, the product's
% production cost, inventory holding cost, and backorder cost, and base stock level R.
%
% UPDATE:  v1 fixes R, and v2 uses the analytical optimum R* for the given parameters (which is a
% function of demand distribution during replenishment lead time, and so changes with demand
% interarrival time SCV).  Depending on the parameters chosen, you may actually see R* _decrease_ as
% demand interarrival time SCV increases, a counterintuitive possibility Hopp & Spearman mention in
% a footnote on page 87 (ed. 2).
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
DemandInterarrivalTime_SCV = 0.1 : 0.1 : 2;  %Sweep over this

ReplenishLeadTime_Distrib = 'normal';
ReplenishLeadTimeYears_mean = 1/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;  %In Hopp & Spearman's base stock example this is 750, but to scale plots I'll reduce it to 1.
UnitAnnualHoldingCost_H = 180;
UnitAnnualBackorderCost_B = 300;

nReps = 12;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2400;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts';
f2 = 'Inventory_BaseStock_ComputeRStar';
HELPER_ValidateFileDependencies({f1, f2});


%% Simulate
FillRate_reps = zeros(nReps, 1);
CostPerSatDmd_Total_reps = zeros(nReps, 1);
CostPerSatDmd_Inventory_reps = zeros(nReps, 1);
CostPerSatDmd_Backorder_reps = zeros(nReps, 1);
CostPerSatDmd_Production_reps = zeros(nReps, 1);
nBackorders_reps = cell(nReps, 1);
nSCV = length(DemandInterarrivalTime_SCV);
RStar = zeros(nSCV, 1);
FillRate = zeros(nSCV, 1);
CostPerSatDmd_Total = zeros(nSCV, 1);
CostPerSatDmd_Inventory = zeros(nSCV, 1);
CostPerSatDmd_Backorder = zeros(nSCV, 1);
CostPerSatDmd_Production = zeros(nSCV, 1);
nBackorders = cell(nSCV, 1);

%Outer loop for sweep variable
for ii = 1 : nSCV
	
	%Find R* (analytically) for the given value of demand SCV
	%(If computing R* analytically, then the demand distribution type matters.  For H=180, B=300, Dmean=120, Dscv=1, L=1/12,
	% R*={10, 9, 13, 14} for the demand distributions {gamma/ exponential, lognormal, triangular, uniform})
	RStar(ii) = Inventory_BaseStock_ComputeRStar( ReplenishLeadTimeYears_mean, ...
		DemandInterarrivalTime_Distrib, DemandUnitsPerYear_mean, DemandInterarrivalTime_SCV(ii), ...
		UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B );
	
	%Inner loop for replications
	for jj = 1 : nReps
		[	FillRate_reps(jj), nBackorders_reps{jj}, ...
			CostPerSatDmd_Total_reps(jj), CostPerSatDmd_Inventory_reps(jj), CostPerSatDmd_Backorder_reps(jj), CostPerSatDmd_Production_reps(jj) ] = ...
		SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts( ...
			SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV(ii), ...
            UnitProductionCost_C, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
            ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
			RStar(ii), minDepartBeforeSimStop );
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
CDF_Xvals = DemandInterarrivalTime_SCV;
xvalsLabel = 'Demand Inter-Arrival Time SCV';
textLabels = {'SCV_D', 'R*'};
labelValues = {DemandInterarrivalTime_SCV, RStar};
sharedTitle = 'System with BASE STOCK assumptions and costs';
HELPER_VisualizationType6( ...
	CostPerSatDmd_Total, CostPerSatDmd_Inventory, CostPerSatDmd_Backorder, CostPerSatDmd_Production, ...
	FillRate, nBackorders, ...
	CDF_Xvals, xvalsLabel, '', sharedTitle, ...
	textLabels, labelValues );


%% More Details
% v1 fixes R, whereas v2 dynamically computes R* for each permutation of parameters.  When using 
% either the 'gamma' or 'lognormal' demand distribution, however, something unusual might appear in
% the second generated figure - R* may decreasing as demand variability increases.  That seems to
% disagree with intuition, although intuition is a bit muddied because the same fill rate is not
% required as demand variability increases.  To understand and validate, dig a little deeper into
% the (analytical) computation of R* by visualizing the demand distribution's CDF:
DemandUnitsPerLeadTime_mean = DemandUnitsPerYear_mean * ReplenishLeadTimeYears_mean;
criticalRatio = UnitAnnualBackorderCost_B / (UnitAnnualBackorderCost_B + UnitAnnualHoldingCost_H);
xlim = 20;
labelIndex = 500;
CDF_Xvals = 0.01 : 0.01 : xlim;

figure, box off, hold on;
for kk = 1 : nSCV
    pd = HELPER_GetProbDistObj(DemandInterarrivalTime_Distrib, DemandUnitsPerLeadTime_mean, DemandInterarrivalTime_SCV(kk));
    CDF_Yvals = cdf(pd, CDF_Xvals);
    plot(CDF_Xvals, CDF_Yvals);
    text(CDF_Xvals(labelIndex), CDF_Yvals(labelIndex), ['SCV_D=' num2str(DemandInterarrivalTime_SCV(kk))], ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end
%Add a horizontal line at the critical ratio
line([0 xlim], [criticalRatio criticalRatio], 'color', 'k');
title('CDF of demand during replenishment lead time', 'FontWeight', 'normal');
text(0.5, 0.98, ...
    {'If gamma or lognormal, notice how R*' ...
    'can decrease as demand SCV increases,' ...
    'depending on the critical ratio.'}, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
