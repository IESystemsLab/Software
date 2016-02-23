%% Purpose
% The following demo was created to answer the question _How high must the backorder cost be to
% realize a certain value of fill rate at R*?_  While it answers the question, it's unclear how much
% the answer depends on specific parameter values, so be careful drawing any general inferences.
% The demo invokes the simulation model 'ProdSystem_BaseStockAssumptionsAndCosts' (through its
% wrapper function) over a range of backorder costs B.  For each value the analytical R* is
% computed, and the output is a visualization of fill rate at R* for each value of backorder cost.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, replenishment lead times' distribution, mean, and variability, the product's
% production cost, inventory holding cost, and a range of backorder costs (as multiples of the
% inventory holding cost).
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

ReplenishLeadTime_distrib = 'gamma';
ReplenishLeadTimeYears_mean = 1/12;
ReplenishLeadTimeYears_variance = eps;

UnitProductionCost_C = 1;  %In Hopp & Spearman's base stock example this is 750, but to scale plots reduce it to 1.
UnitAnnualHoldingCost_H = 180;
FractionsOfH = 0.25 : 0.25 : 5;
UnitAnnualBackorderCost_B = FractionsOfH * UnitAnnualHoldingCost_H;  %Sweep over this

nReps = 10;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts';
f2 = 'Inventory_BaseStock_ComputeRStar';
HELPER_ValidateFileDependencies({f1, f2});


%% Simulate
FillRate_reps = zeros(nReps, 1);
nX = length(UnitAnnualBackorderCost_B);
RStar = zeros(nX, 1);
FillRate = zeros(nX, 1);

%Outer loop for sweep variable
for ii = 1 : nX
    
	%Find R*:  The initial plan was to find R* by optimizing numerically.  However, with
	%replications and repeating the process for each value of B, that's too many simulations and
	%takes forever.  Find R* using analytical results.
	RStar(ii) = Inventory_BaseStock_ComputeRStar( ReplenishLeadTimeYears_mean, ...
		DemandInterarrivalTime_Distrib, DemandUnitsPerYear_mean, DemandInterarrivalTime_SCV, ...
		UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B(ii) );
	
	%Inner loop for replications
	for jj = 1 : nReps
		[ FillRate_reps(jj) ] = ...
		SimWrapper_ProdSystem_BaseStockAssumptionsAndCosts( ...
			SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
			UnitProductionCost_C, UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B(ii), ...
			ReplenishLeadTime_distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
			RStar(ii), minDepartBeforeSimStop );
    end
    
	%Average over all replications
	FillRate(ii) = mean(FillRate_reps);
end


%% Visualize
figure, hold on, box off;
plot(FractionsOfH, FillRate, '.-', 'MarkerSize', 12)
for kk = 1 : nX
	text(FractionsOfH(kk), FillRate(kk), ['R*=' num2str(RStar(kk))], ...
		'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
end
xlabel('Unit Annual Backorder Cost B (as a fraction of Unit Annual Holding Cost H)');
ylabel('Fill Rate at R*')
title('Base Stock:  How high must backorder cost be to realize a certain fill rate at R*?', ...
	'FontWeight', 'Normal');
