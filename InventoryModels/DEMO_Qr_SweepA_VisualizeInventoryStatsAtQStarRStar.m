%% Purpose
% The purpose of the following demo is to observe the effect of increasing lot setup cost A relative
% to a fixed inventory holding cost H.  The demo invokes the simulation model 'ProdSystem_QrAssumptionsAndCosts'
% (through its wrapper function) over a range of lot setup costs A.  For each value the analytical
% (Q*, R*) is computed, and the output is a visualization of average inventory statistics (number of 
% replenishments per year, lot size Q*, and on-hand inventory level) as lot setup cost increases.
% An expected result is that as A increases relative to H then Q* will increase, the number of 
% replenishments will decrease, and on-hand inventory will increase.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean,
% and variability, replenishment lead times' distribution, mean, and variability, the product's
% production cost, inventory holding cost, backorder cost, and a range of lot setup costs (as
% multiples of the inventory holding cost).
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
UnitAnnualHoldingCost_H = 100;
FractionsOfH = 0.5 : 0.5 : 5;
LotSetupCost_A = FractionsOfH * UnitAnnualHoldingCost_H;  %Sweep over this
UnitAnnualBackorderCost_B = 100;

nReps = 4;  %replications
SimTimeUnit = 'hours';  %Choices: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'
minDepartBeforeSimStop = 2200;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSystem_QrAssumptionsAndCosts';
f2 = 'Inventory_BaseStock_ComputeRStar';
f3 = 'Inventory_EOQ_ComputeQStar';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Analytical Optimum
% QStar = sqrt(2AD/H), so it changes with A
RStar = Inventory_BaseStock_ComputeRStar( ReplenishLeadTimeYears_mean, ...
    DemandInterarrivalTime_Distrib, DemandUnitsPerYear_mean, DemandInterarrivalTime_SCV, ...
    UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B );


%% Simulate
AnnualCost_Inventory_reps = zeros(nReps, 1);
AnnualCost_Setup_reps = zeros(nReps, 1);
nA = length(LotSetupCost_A);
avgInventoryLevel = zeros(nA, 1);
nProductionLotsPerYear = zeros(nA, 1);
QStar = zeros(nA, 1);

%Outer loop for sweep variable
for ii = 1 : nA
    
    %Analytical Optimum
    QStar(ii) = Inventory_EOQ_ComputeQStar( DemandUnitsPerYear_mean, LotSetupCost_A(ii), UnitAnnualHoldingCost_H );
    
    %Inner loop for replications
    for kk = 1 : nReps
        [	FillRate_reps, nBackorders_reps, ...
            TotalCost_PerSatDmd, InventoryCost_PerSatDmd, BackorderCost_PerSatDmd, ProductionCost_PerSatDmd, SetupCost_PerSatDmd, ...
            AnnualCost_Total, AnnualCost_Inventory_reps(kk), AnnualCost_Backorder, AnnualCost_Production, AnnualCost_Setup_reps(kk) ] = ...
        SimWrapper_ProdSystem_QrAssumptionsAndCosts( ...
            SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
            UnitProductionCost_C, LotSetupCost_A(ii), UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B, ...
            ReplenishLeadTime_Distrib, ReplenishLeadTimeYears_mean, ReplenishLeadTimeYears_variance, ...
            QStar(ii), RStar, minDepartBeforeSimStop );
    end
    
    %Average over all replications
    avgInventoryLevel(ii) = mean(AnnualCost_Inventory_reps) / UnitAnnualHoldingCost_H;
    nProductionLotsPerYear(ii) = mean(AnnualCost_Setup_reps) / LotSetupCost_A(ii);
end


%% Visualize
figure, hold on, box off;
plot(FractionsOfH, avgInventoryLevel);
plot(FractionsOfH, nProductionLotsPerYear);
for jj = 1 : nA
	text(FractionsOfH(jj), nProductionLotsPerYear(jj), {['Q*=', num2str(QStar(jj))], ['R*=', num2str(RStar)]}, ...
		'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
end
text(FractionsOfH(end), avgInventoryLevel(end), 'Average Inventory Level', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
text(FractionsOfH(1), nProductionLotsPerYear(1), 'Number of Replenishments Per Year', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
xlabel('Lot Setup Cost A (as a fraction of Inventory Holding Cost H)')
title('Production System with Qr Assumptions', 'FontWeight', 'Normal');
