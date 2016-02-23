%% Purpose
% The newsvendor model concerns a single, one-time inventory replenishment.  This differs from EOQ,
% Base Stock, and the Qr models which concern recurring inventory replenishments.  Hopp & Spearman
% note that the newsvendor model can be extended to multi-replenishment scenarios, but that is
% beyond the scope of an undergraduate class.  Therefore, a time-stepping SimEvents simulation
% is not appropriate for this demo, and it's better suited to a Monte Carlo simulation in the MATLAB
% workspace.
%
% The following demo fixes Q and computes many samples of profit (sales revenue plus salvage revenue 
% minus production costs) using a Monte-Carlo simulation.  Instead of returning a metric such as
% _expected_ profit, however, this demo returns visualizations of the empirical profit distribution 
% (its PDF and CDF).  One interesting statistic which can be visualized in the CDF plot is the 
% (empirical) probability that profit is negative, meaning production costs exceed the sum of sales
% and salvage revenue, such that the choice of Q results in losing money.
%
% Parameters which can be changed by a user include demand's distribution, mean, and variability,
% the product's unit cost, price, and salvage value, and Q.
%
% Newsvendor _system_ assumptions:
%
% * Products are separable with no shared interactions.  This enables single-product analysis.
% * Inventory cannot be carried across planning periods.  Future time periods are independent of the
% current decision, which is why the classical newsvendor problem is static and involves only a
% single, one-time inventory replenishment.
% * Demand is random.  At the time of writing, both the analytical and the simulation model require
% that demand can be modeled with a known probability distribution (as opposed to, for example, a
% non-parametric description).
% * Deliveries are made in advance of demand, such that all stock is available to meet demand.
%
% Newsvendor _cost_ assumptions:
%
% * Each unit ordered incurs a fixed production cost (cost/unit)
% * Hopp & Spearman's formulation (section 2.4.1, ed.2) is stated in terms of costs of ordering-too-
% little and ordering-too-much, and assumes that they are linear (e.g. proportional to the amount by
% which demand exceeds supply or supply exceeds demand).  The formulation implemented is equivalent,
% but requires a different statement of these costs:
% * Each unit has a fixed sale cost (cost/unit)
% * Each unit has a fixed salvage cost if left over after all demand satisfied (cost/unit)


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
Demand_distrib = 'gamma';
Demand_mean = 225;
Demand_SCV = (250^2)/(225^2);

Cost_unit = 8;
Price_unit = 18;
SalvageValue_unit = 0;

Q = 300;

nReps = 50000;  %replications


%% Check File Dependencies
f1 = 'NewsvendorMonteCarloSimulation';
HELPER_ValidateFileDependencies({f1});


%% Simulate
[ ExpectedProfit, ProbLosingMoney, profitSamples ] = NewsvendorMonteCarloSimulation( ...
    Demand_distrib, Demand_mean, Demand_SCV, ...
    Cost_unit, Price_unit, SalvageValue_unit, ...
    Q, nReps );


%% Visualize
f1 = figure;
if isempty(which('histogram'))
	hist(profitSamples);  %Before R2015a
else
	histogram(profitSamples);  %R2015a and beyond
end
box off
xlabel('Profit Value');
ylabel(['Number of replications in a bin (out of ' num2str(nReps) ')']);
title(['Empirical PDF  (DemandMean= ', num2str(Demand_mean), ', DemandSCV= ' sprintf('%4.2f', Demand_SCV) ', Q= ' num2str(Q) ')'], ...
    'FontWeight', 'Normal');

f2 = figure;
cdfplot(profitSamples)
xlabel('Profit Value');
ylabel('Pr[ A random sample of Profit is <= x ]');
title(['Empirical CDF  (DemandMean= ', num2str(Demand_mean), ', DemandSCV= ' sprintf('%4.2f', Demand_SCV) ', Q= ' num2str(Q) ')'], ...
    'FontWeight', 'Normal');
