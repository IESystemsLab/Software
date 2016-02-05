%% Purpose
% The following demo makes side-by-side comparisons of the _push_ and _pull_ order release
% paradigms.  The demo invokes the simulation models *ProdSys_MakeToStockPUSH* and
% *ProdSys_MakeToStockPULL_CONWIP* (through their wrapper functions), the latter over a range of
% CONWIP amounts.  The output visualizes average work-in-process, cycle time, throughput, and demand 
% backorder level in the two paradigms.  The expected result is that, for a sufficient amount of CONWIP,
% the pull paradigm will out-perform the push paradigm.
%
% Another purpose of this demo is to visualize a scenario in which a pulling CONWIP system
% actually performs worse than a push system.  This is done by visualizing single-replication traces of
% the demand backorder level to see how each system recovers from disruptions.  The expected result is
% that increasing CONWIP level will ensure that a system _will recover at all_ and _will recover
% faster_ from disruptions.  While it may seem straightforward to avoid poorly-performing CONWIP
% scenarios by setting the CONWIP amount sufficiently high, recall that there is also an incentive to
% keep the CONWIP amount low to keep the finished goods inventory level low.  Another
% complication is that a non-stationary demand process may cause a static CONWIP level which is
% sufficiently high in the past to become too low over time.
%
% Parameters which can be changed by a user include demand interarrival times' 
% distribution, mean, and variability, processing times' distribution, mean, and variability at each
% workstation, and a range of CONWIP amounts.  The models use G/G/k workstation library blocks 
% which includes both preemptive failures and non-preemptive setups, and if desired values can be 
% set for time-until-failure, repair time, count-until-setup, and setup time at each workstation.
% In the make-to-stock push model, order interarrival times are set equal in distribution to demand 
% interarrival times; otherwise, the lack of feedback control will lead to a steadily-increasing
% mean shortage or surplus.


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
f1 = 'SimWrapper_ProdSys_MakeToStockPUSH';
f2 = 'SimWrapper_ProdSys_MakeToStockPULL_CONWIP';
HELPER_ValidateFileDependencies({f1, f2});


%% Input Parameters
DemandInterArrivalTime_distrib = 'gamma';
DemandInterArrivalTime_mean = 20;
DemandInterArrivalTime_SCV = 1;  %Gamma with SCV=1 == Exponential

ProcessingTime_distribs = {'gamma', 'gamma', 'gamma', 'gamma'};
AvgUtil = 0.8;
ProcessingTime_means = DemandInterArrivalTime_mean * AvgUtil * ones(1,4);
ProcessingTime_SCVs = [1 1 1 1];  %Gamma with SCV=1 == Exponential

TimeUntilFailure_distribs = {'normal', 'normal', 'normal', 'normal'};
TimeUntilFailure_means = [double(intmax) double(intmax) double(intmax) double(intmax)];
TimeUntilFailure_SCVs = [eps eps eps eps];

TimeToRepair_distribs = {'normal', 'normal', 'normal', 'normal'};
TimeToRepair_means = [eps eps eps eps];
TimeToRepair_SCVs = [eps eps eps eps];

CountUntilSetup_distribs = {'normal', 'normal', 'normal', 'normal'};
CountUntilSetup_means = [double(intmax) double(intmax) double(intmax) double(intmax)];
CountUntilSetup_SCVs = [eps eps eps eps];

SetupTime_distribs = {'normal', 'normal', 'normal', 'normal'};
SetupTime_means = [eps eps eps eps];
SetupTime_SCVs = [eps eps eps eps];

CONWIPAmount = 5 : 1 : 20;  %For the pull system, sweep over this

nReps = 6;  %replications
nSatDemandsBeforeSimStop = 30000;


%% Simulate:  Push
%Pre-Processing
DemandInterArrivalTime_var = DemandInterArrivalTime_mean^2 * DemandInterArrivalTime_SCV;
ProcessingTime_vars = ProcessingTime_means.^2 .* ProcessingTime_SCVs;
TimeUntilFailure_vars = TimeUntilFailure_means.^2 .* TimeUntilFailure_SCVs;
TimeToRepair_vars = TimeToRepair_means.^2 .* TimeToRepair_SCVs;
CountUntilSetup_vars = CountUntilSetup_means.^2 .* CountUntilSetup_SCVs;
SetupTime_vars = SetupTime_means.^2 .* SetupTime_SCVs;
%Replication output storage
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
DemandBackordersAvgLen_reps = zeros(nReps, 1);
DemandBackordersSamples_Push = cell(nReps, 1);

%Inner loop for replications
for jj = 1 : nReps
    [   WIP_reps(jj), CT_reps(jj), TH_reps(jj), ...
		FGI_avgLen, FGI_avgWait, FGI_samples, ...
        DemandBackordersAvgLen_reps(jj), DemandBackorders_avgWait, DemandBackordersSamples_Push{jj} ] = ...
	SimWrapper_ProdSys_MakeToStockPUSH( ...
		DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_var, ...  %Orders
        DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_var, ...  %Demands
        ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_vars, ...
        TimeUntilFailure_distribs, TimeUntilFailure_means, TimeUntilFailure_vars, ...
        TimeToRepair_distribs, TimeToRepair_means, TimeToRepair_vars, ...
        CountUntilSetup_distribs, CountUntilSetup_means, CountUntilSetup_vars, ...
        SetupTime_distribs, SetupTime_means, SetupTime_vars, ...
        nSatDemandsBeforeSimStop );
end

%Average over all replications
WIP_average_Push = mean(WIP_reps);
CT_average_Push = mean(CT_reps);
TH_average_Push = mean(TH_reps);
DemandBackordersAvgLen_Push = mean(DemandBackordersAvgLen_reps);


%% Simulate:  Pull
%Swept variable output storage
nCONWIPAmounts = length(CONWIPAmount);
WIP_average_Pull = zeros(nCONWIPAmounts, 1);
CT_average_Pull = zeros(nCONWIPAmounts, 1);
TH_average_Pull = zeros(nCONWIPAmounts, 1);
DemandBackordersAvgLen_Pull = zeros(nCONWIPAmounts, 1);
DemandBackordersSamples_Pull = cell(nCONWIPAmounts, 1);

%Outer loop for sweep variable
for ii = 1 : nCONWIPAmounts
    
    %Inner loop for replications
	for jj = 1 : nReps
        [   WIP_reps(jj), CT_reps(jj), TH_reps(jj), ...
            FGIAvgLen, FGIAvgWait, FGISamples, ...
            DemandBackordersAvgLen_reps(jj), DemandBackorders_avgWait, DemandBackorders_samples, ...
            FillRate ] = ...
        SimWrapper_ProdSys_MakeToStockPULL_CONWIP( ...
            DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_var, ...
            ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_vars, ...
            TimeUntilFailure_distribs, TimeUntilFailure_means, TimeUntilFailure_vars, ...
            TimeToRepair_distribs, TimeToRepair_means, TimeToRepair_vars, ...
            CountUntilSetup_distribs, CountUntilSetup_means, CountUntilSetup_vars, ...
            SetupTime_distribs, SetupTime_means, SetupTime_vars, ...
            CONWIPAmount(ii), nSatDemandsBeforeSimStop );
	end
	
    %Average over all replications
    WIP_average_Pull(ii) = mean(WIP_reps);
    CT_average_Pull(ii) = mean(CT_reps);
    TH_average_Pull(ii) = mean(TH_reps);
    DemandBackordersAvgLen_Pull(ii) = mean(DemandBackordersAvgLen_reps);
	DemandBackordersSamples_Pull{ii} = DemandBackorders_samples;  %A time history from the final replication
end


%% Visualize
xVals = CONWIPAmount;
lineX = [CONWIPAmount(1), CONWIPAmount(end)];

figure;
subplot(2,2,1), hold on, box off;
lineY = [WIP_average_Push, WIP_average_Push];
line(lineX, lineY, 'color', 'k');
text(xVals(end), WIP_average_Push, 'Push', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
plot(xVals, WIP_average_Pull);
text(xVals(end), WIP_average_Pull(end), 'Pull', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
xlabel('CONWIP Amount');
ylabel('Average WIP');

subplot(2,2,2), hold on, box off;
lineY = [CT_average_Push, CT_average_Push];
line(lineX, lineY, 'color', 'k');
text(xVals(end), CT_average_Push, 'Push', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
plot(xVals, CT_average_Pull);
text(xVals(end), CT_average_Pull(end), 'Pull', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
xlabel('CONWIP Amount');
ylabel('Average CT');

subplot(2,2,3), hold on, box off;
lineY = [TH_average_Push, TH_average_Push];
line(lineX, lineY, 'color', 'k');
text(xVals(1), TH_average_Push, 'Push', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
plot(xVals, TH_average_Pull);
text(xVals(1), TH_average_Pull(1), 'Pull', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
xlabel('CONWIP Amount');
ylabel('Average TH');

subplot(2,2,4), hold on, box off;
lineY = [DemandBackordersAvgLen_Push, DemandBackordersAvgLen_Push];
line(lineX, lineY, 'color', 'k');
text(xVals(1), DemandBackordersAvgLen_Push, 'Push', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
plot(xVals, DemandBackordersAvgLen_Pull);
text(xVals(1), DemandBackordersAvgLen_Pull(1), 'Pull', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
xlabel('CONWIP Amount');
ylabel('Avg Length of Demand Backorders');


f2 = figure;
figHorizScaling = 1.6;
p2 = get(f2, 'Position');
set(f2, 'Position', [p2(1)-(figHorizScaling-1)*p2(3), p2(2), p2(3)*figHorizScaling, p2(4)]);
for kk = 1 : min(nReps, 8)  %8 is arbitrary
	subplot(2,4,kk);
	timesAndValues = DemandBackordersSamples_Push{kk};
	times = timesAndValues{1};
	values = timesAndValues{2};
	plot(times, values)
	title(['Rep ' num2str(kk)], 'FontWeight', 'normal');
	box off, axis tight;
	if kk > 4
		xlabel('Simulation Time Units');
	end
	if kk==1 || kk==5
		ylabel('PUSH Demand Backorders');
	end
end


f3 = figure;
figScaling = 1.6;
p3 = get(f3, 'Position');
set(f3, 'Position', [p3(1)-(figScaling-1)*p3(3), p3(2)-(figScaling-1)*p3(4), p3(3)*figScaling, p3(4)*figScaling]);
for kk = 1 : nCONWIPAmounts
	amount = CONWIPAmount(kk);
	subplot(4,4,kk);
	timesAndValues = DemandBackordersSamples_Pull{kk};
	times = timesAndValues{1};
	values = timesAndValues{2};
	plot(times, values);
	title(['CONWIP=' num2str(amount) ', Rep ' num2str(nReps)], 'FontWeight', 'normal');
	box off, axis tight;
	if kk==5 || kk==13
		ylabel('PULL Demand Backorders');
	end
	if kk>=13
		xlabel('Simulation Time Units');
	end
% 	if kk == 2
% 		title([	'                                          ', ...
% 				'PULL: One-replication traces of the Demand Backorder Level'], 'FontWeight', 'normal');
% 	end
end
