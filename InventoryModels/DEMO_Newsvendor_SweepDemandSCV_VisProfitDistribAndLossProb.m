%% Purpose
% The newsvendor model concerns a single, one-time inventory replenishment.  This differs from EOQ,
% Base Stock, and the Qr models which concern recurring inventory replenishments.  Hopp & Spearman
% note that the newsvendor model can be extended to multi-replenishment scenarios, but that is
% beyond the scope of an undergraduate class.  Therefore, a time-stepping SimEvents simulation
% is not appropriate for this demo, and it's better suited to a Monte Carlo simulation in the MATLAB
% workspace.
%
% The following demo sweeps over demand variability, as measured by SCV (squared coefficient of
% variability, the variance divided by the mean^2).  For each value the analytical Q* is computed,
% and then many samples of profit (sales plus salvage revenue minus purchase/ production costs) 
% are computed using a Monte-Carlo simulation.  Two visualizations are generated, showing (1) The 
% distribution of profit at (analytical) Q* as demand SCV increases, and (2) A pairing of E[Profit]
% with Pr[Profit<0] at (analytical) Q* as demand SCV increases.
%
% Parameters which can be changed by a user include demand's distribution and mean, a range of
% demand SCVs, and the product's unit cost, price, and salvage value.
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
Demand_distrib = 'normal';  %If applicable, negative samples are truncated at zero
%Interesting:  Try 'normal' vs 'gamma', and watch the Q* trend reverse!  Hopp & Spearman consider this in a footnote.
Demand_mean = 225;
Demand_SCV = [1e-4, 0.01, 0.05, 0.1, 0.2, 0.4, 0.8, 2, 4];  %Sweep over this

Cost_unit = 8;
Price_unit = 18;
SalvageValue_unit = 0;

nReps = 20000;  %replications


%% Check File Dependencies
f1 = 'NewsvendorMonteCarloSimulation';
f2 = 'Inventory_Newsvendor_ComputeQStar';
HELPER_ValidateFileDependencies({f1, f2});


%% Simulate
Cost_orderTooLittle = Price_unit - Cost_unit;
Cost_orderTooMuch = Cost_unit - SalvageValue_unit;

nSCVs = length(Demand_SCV);
QStar = zeros(nSCVs, 1);
ExpectedProfitAtQStar = zeros(nSCVs, 1);
ProbLosingMoneyAtQStar = zeros(nSCVs, 1);
ProfitSamplesAtQStar = zeros(nSCVs, nReps);

for ii = 1 : nSCVs
	%Find (analytical) Q* for the given value of demand SCV
	QStar(ii) = Inventory_Newsvendor_ComputeQStar( ...
		Demand_distrib, Demand_mean, Demand_SCV(ii), ...
		Cost_orderTooLittle, Cost_orderTooMuch );
	
	%Simulate
	[ ExpectedProfitAtQStar(ii,:), ProbLosingMoneyAtQStar(ii,:), ProfitSamplesAtQStar(ii,:) ] = NewsvendorMonteCarloSimulation( ...
        Demand_distrib, Demand_mean, Demand_SCV(ii), ...
        Cost_unit, Price_unit, SalvageValue_unit, ...
        QStar(ii), nReps );
end	


%% Visualize:  Distribution (via boxplot) of Profit at Q* for each Demand SCV
figure;
boxplot(ProfitSamplesAtQStar');  %Statistics Toolbox
hold on, box off
plot(ExpectedProfitAtQStar, 'k.', 'MarkerSize', 14)
for jj = 1 : nSCVs
    text(jj, ExpectedProfitAtQStar(jj), {'Q*=', num2str(QStar(jj))}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
end
set(gca, 'XTick', 1:nSCVs);
set(gca, 'XTickLabel', num2str(Demand_SCV'));
xlabel('Demand SCV');
ylabel(['Profit distribution at analytical Q*  (' num2str(nReps) ' reps per SCV)']);
title({'Newsvendor: Profit Distribution at Q* as Demand SCV Increases', ...
	'(Boxplot: black dot is mean, red line is median, box edges are 25th and 75th percentiles)'}, ...
    'FontWeight', 'Normal');


%% Visualize:  E[Profit] and Pr[Profit<0] for the Q* corresponding to each Demand SCV
figure, hold on, box off;
plot(ProbLosingMoneyAtQStar, ExpectedProfitAtQStar, '.-', 'MarkerSize', 12)
xlabel('Pr[Profit < 0]')
ylabel('E[Profit]')
title('Newsvendor: E[Profit] and Pr[Profit < 0] at Q* as Demand SCV Increases', 'FontWeight', 'Normal')

for jj = 1 : nSCVs
    text(ProbLosingMoneyAtQStar(jj), ExpectedProfitAtQStar(jj), ...
        ['SCV_D=' num2str(Demand_SCV(jj)) ', Q*=', num2str(QStar(jj))], ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
