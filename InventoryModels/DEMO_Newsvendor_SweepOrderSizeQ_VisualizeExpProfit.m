%% Purpose
% The newsvendor model concerns a single, one-time inventory replenishment.  This differs from EOQ,
% Base Stock, and the Qr models which concern recurring inventory replenishments.  Hopp & Spearman
% note that the newsvendor model can be extended to multi-replenishment scenarios, but that is
% beyond the scope of an undergraduate class.  Therefore, a time-stepping SimEvents simulation
% is not appropriate for this demo, and it's better suited to a Monte Carlo simulation in the MATLAB
% workspace.
%
% The following demo sweeps over order size Q.  Visualizations are generated for E[Profit] versus Q 
% and also E[Profit]'s sensitivity around (empirical) Q*.  Because E[Profit] may not be the most
% helpful performance metric for newsvendor's one-time decision, an additional visualization is
% generated which pairs E[Profit] with Pr[Profit<0] for each Q.
%
% Parameters which can be changed by a user include demand's distribution, mean, and variability,
% the product's unit cost, price, and salvage value, and a range of order quantities Q.
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
Demand_distrib = 'gamma';
%Interesting: Q* changes as the distrib changes (try 'normal' vs 'gamma' or 'lognormal')
%Be aware that 'normal' isn't quite because negative demand samples are truncated at zero.
Demand_mean = 225;
Demand_SCV = (250^2)/(225^2);

Cost_unit = 8;
Price_unit = 18;
SalvageValue_unit = 0;

Q_min = 1;
Q_increment = 1;
Q_max = 450;
Q = Q_min : Q_increment : Q_max;  %Sweep over this

nReps = 50000;  %replications

% Demand_distrib = 'normal';
% Demand_mean = 20000;
% Demand_SCV = (7000^2)/(20000^2);
% 
% Cost_unit = 300;
% Price_unit = 900;
% SalvageValue_unit = 0;
% 
% Q_min = 15000;
% Q_increment = 100;
% Q_max = 30000;


%% Simulate
[ ExpectedProfit, ProbLosingMoney ] = NewsvendorMonteCarloSimulation( ...
    Demand_distrib, Demand_mean, Demand_SCV, ...
    Cost_unit, Price_unit, SalvageValue_unit, ...
    Q, nReps );


%% Empirical Optimum
[ExpectedProfitAtQStar, QStarIndex] = max(ExpectedProfit);
QStar = Q(QStarIndex);


%% Visualize:  Expected Profit vs Q
figure, hold on, box off;
plot(Q, ExpectedProfit)
xlabel('Order Quantity Q')
ylabel('E[Profit] = E[revenue + salvageRevenue - unitCosts]')
title('Newsvendor:  Expected Profit', 'FontWeight', 'Normal')


%% Visualize:  Profit Sensitivity near Q*
profitRatioCutoff = 0.90;
ExpectedProfitRatio = ExpectedProfit / ExpectedProfitAtQStar;
expProfitIndices = find(ExpectedProfitRatio > profitRatioCutoff);

figure, hold on, box off;
plot(Q(expProfitIndices), ExpectedProfitRatio(expProfitIndices))
xlabel('Order Quantity Q')
ylabel('E[Profit] at Q / E[Profit] at Q*')
title(['Newsvendor:  Expected Profit Sensitivity around (empirical) Q*=' num2str(QStar)], 'FontWeight', 'Normal')


%% Visualize:  Pr[ Profit < 0 ]
figure, hold on, box off;
plot(ProbLosingMoney, ExpectedProfit)
xlabel('Pr[Profit < 0]')
ylabel('E[Profit]')
title('Newsvendor:  Visualize E[Profit] and Pr[Profit < 0] for each Q', 'FontWeight', 'Normal')

nLabels = 12;
nQ = length(Q);
sampleIncrement = round(nQ / nLabels);
Qindices = 1 : sampleIncrement : nQ;
for ii = 1 : length(Qindices)
    QIndex = Qindices(ii);
    text(ProbLosingMoney(QIndex), ExpectedProfit(QIndex), ['Q=' num2str(Q(QIndex))], ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
end