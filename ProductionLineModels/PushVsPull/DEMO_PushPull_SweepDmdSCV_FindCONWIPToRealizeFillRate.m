%% Purpose
% The following demo was created to answer the question "What CONWIP amount is needed to realize a
% certain fill rate, and how does that change as demand interarrival time variability increases?"
% The demo invokes the simulation model *ProdSys_MakeToStockPULL_CONWIP* (through its wrapper function) over
% a range of demand interarrival time variability, as measured by SCV (squared coefficient of 
% variability, the variance divided by the mean^2).  For each demand SCV, the minimum CONWIP amount 
% to realize fill rate at or above a threshold is empirically determined, and the output visualizes 
% this number as a function of demand SCV.
%
% Parameters which can be changed by a user include demand interarrival times' distribution, mean, 
% and a range of a range of SCVs, processing times' distribution, mean, and variability at each 
% workstation, and a threshold for average fill rate.  The model uses the G/G/k workstation library 
% block which includes both preemptive failures and non-preemptive setups, and if desired values can
% be set for time-until-failure, repair time, count-until-setup, and setup time at each workstation.


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
DemandInterArrivalTime_distrib = 'gamma';
DemandInterArrivalTime_mean = 20;
DemandInterArrivalTime_SCV = 0.1 : 0.15 : 3;  %Sweep over this

ProcessingTime_distribs = {'gamma', 'gamma', 'gamma', 'gamma'};
AvgUtilEachWks = 0.95 * ones(1,4);
ProcessingTime_means = DemandInterArrivalTime_mean * AvgUtilEachWks;
ProcessingTime_SCVs = 1e-16 * ones(1,4);

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

CONWIPAmount = 1 : 1 : 100;  %Search over this
FillRateThreshold = 0.90;  %to find first FillRate which exceeds this

nReps = 6;  %replications
nSatDemandsBeforeSimStop = 25000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSys_MakeToStockPULL_CONWIP';
HELPER_ValidateFileDependencies({f1});


%% Simulate
%Pre-Processing
DemandInterArrivalTime_var = DemandInterArrivalTime_mean^2 * DemandInterArrivalTime_SCV;
ProcessingTime_vars = ProcessingTime_means.^2 .* ProcessingTime_SCVs;
TimeUntilFailure_vars = TimeUntilFailure_means.^2 .* TimeUntilFailure_SCVs;
TimeToRepair_vars = TimeToRepair_means.^2 .* TimeToRepair_SCVs;
CountUntilSetup_vars = CountUntilSetup_means.^2 .* CountUntilSetup_SCVs;
SetupTime_vars = SetupTime_means.^2 .* SetupTime_SCVs;
%Replication output storage
FillRate_reps = zeros(nReps, 1);
%Swept variable output storage
nSCVs = length(DemandInterArrivalTime_SCV);
nCONWIPs = length(CONWIPAmount);
minCONWIPToRealizeFillRateThreshold = zeros(nSCVs, 1);
minCONWIPFillRate = zeros(nSCVs, 1);
%Search variables
searchStartIndex = 4;  %Start with the number of workstations
nBacktrackIndices = 2;  %min CONWIP should be monotonically increasing, but search a little backwards too

% NOTE on the algorithm:  I considered parallelization of the outmost loop with PARFOR, but that 
% requires each iteration to be independent of all others.  I declined because I can do better with
% an algorithm which does depend on previous iterations - it relies on an assumption that as demand
% variability increases, the CONWIP amount to realize a fill rate threshold should be monotonically
% non-decreasing.

%Outer loop for sweep variable
for ii = 1 : nSCVs

	%Outer loop for search variable
	for jj = searchStartIndex : nCONWIPs
		
		%Inner loop for replications
		for kk = 1 : nReps
			[   WIP_reps, CT_reps, TH_reps, ...
				FGIAvgLen_reps, FGIAvgWait_reps, FGISamples, ...
				BackordersAvgLen_reps, BackordersAvgWait_reps, BackorderSamples, ...
				FillRate_reps(kk) ] = ...
			SimWrapper_ProdSys_MakeToStockPULL_CONWIP( ...
				DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_var(ii), ...
				ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_vars, ...
				TimeUntilFailure_distribs, TimeUntilFailure_means, TimeUntilFailure_vars, ...
				TimeToRepair_distribs, TimeToRepair_means, TimeToRepair_vars, ...
				CountUntilSetup_distribs, CountUntilSetup_means, CountUntilSetup_vars, ...
				SetupTime_distribs, SetupTime_means, SetupTime_vars, ...
				CONWIPAmount(jj), nSatDemandsBeforeSimStop );
		end
    
		%Average over all replications
		FillRate = mean(FillRate_reps);
		
		%jj is a search variable => Cut off the search as soon as FillRate exceeds FillRateThreshold
		if FillRate >= FillRateThreshold
			minCONWIPToRealizeFillRateThreshold(ii) = CONWIPAmount(jj);
			minCONWIPFillRate(ii) = FillRate;
			searchStartIndex = max(jj-nBacktrackIndices, 1);
			break;  %Move onto the next SCV
		elseif jj == nCONWIPs
			%If you get here, FillRate < FillRateThreshold for all CONWIPAmounts.  Take the max.
			minCONWIPToRealizeFillRateThreshold(ii) = CONWIPAmount(jj);
			minCONWIPFillRate(ii) = FillRate;	
		end
	end
end


%% Visualize
figure;
plot(DemandInterArrivalTime_SCV, minCONWIPToRealizeFillRateThreshold);
box off;
xlabel('Demand Inter-Arrival Time SCV');
ylabel('CONWIP Amount');
title(['CONWIP Amount For Average Fill Rate \geq ', num2str(FillRateThreshold), ...
	'.  \mu_{ia}=', num2str(DemandInterArrivalTime_mean), ', (\mu_{p}, SCV_{p}) = (' ...
	num2str(ProcessingTime_means(1)), ',', num2str(ProcessingTime_SCVs(1)), ')'], ...
	'FontWeight', 'normal');
