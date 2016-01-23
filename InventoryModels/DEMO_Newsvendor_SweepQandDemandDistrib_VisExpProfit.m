%% Purpose
% The newsvendor model concerns a single, one-time inventory replenishment.  This differs from EOQ,
% Base Stock, and the Qr models which concern recurring inventory replenishments.  Hopp & Spearman
% note that the newsvendor model can be extended to multi-replenishment scenarios, but that is
% beyond the scope of an undergraduate class.  Therefore, a time-stepping SimEvents simulation
% is not appropriate for this demo, and it's better suited to a Monte Carlo simulation in the MATLAB
% workspace.
%
% The following demo sweeps over order size Q, and generates a visualization for E[Profit] versus Q.
% It does this for various values of the demand distribution _type_, at the time of writing 
% exponential, uniform, triangular_symmetric, gamma, lognormal, and normal.  (Be aware that uniform,
% triangular, and normal may not be quite so because negative demand samples are truncated at zero.)
% A separate curve is generated for each distribution type, such that the E[Profit] curve's shape
% and also Q* can be compared as the demand distribution type (but not the mean or SCV) changes.
%
% Parameters which can be changed by a user include a range of demand distribution types, the common
% mean and SCV for each distribution, the product's unit cost, price, and salvage value, and a range
% of order quantities Q.
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


%% Check File Dependencies
f1 = 'NewsvendorMonteCarloSimulation';
HELPER_ValidateFileDependencies({f1});


%% Input Parameters
Demand_distribs = {'exponential', 'uniform', 'triangular_symmetric', 'gamma', 'lognormal', 'normal'};
%(uniform, triangular, and normal may not be quite so because negative demand samples are truncated at zero)
Demand_mean = 225;
Demand_SCV = 0.8;

Cost_unit = 8;
Price_unit = 18;
SalvageValue_unit = 0;

Q_min = 1;
Q_increment = 1;
Q_max = 500;
Q = Q_min : Q_increment : Q_max;  %Sweep over this

nReps = 20000;  %replications


%% Simulate
nQ = length(Q);
nDistribs = length(Demand_distribs);
ExpectedProfit = zeros(nQ, nDistribs);

for ii = 1 : nDistribs
    ExpectedProfit(:,ii) = NewsvendorMonteCarloSimulation( ...
        Demand_distribs{ii}, Demand_mean, Demand_SCV, ...
        Cost_unit, Price_unit, SalvageValue_unit, ...
        Q, nReps );
end


%% Visualize
figure, hold on, box off;

%Iterate over all SCVs
for jj = 1 : nDistribs
	%Plot a curve for a specific DemandSCV
	plot(Q, ExpectedProfit(:, jj))
	
	%Add a label identifying this curve's DemandSCV value
	[maxValue, maxIndex] = max(ExpectedProfit(:, jj));
	plot(Q(maxIndex), maxValue, 'k.', 'MarkerSize', 16);
	text(Q(maxIndex), maxValue, Demand_distribs{jj}, 'FontSize', 11, 'FontWeight', 'bold', ...
		'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Interpreter', 'none');
end
axis tight
xlabel('Order Quantity Q')
ylabel('E[Profit]')
title(['Newsvendor: Expected Profit  (Demand SCV is fixed at ' num2str(Demand_SCV) ')'], 'FontWeight', 'Normal')