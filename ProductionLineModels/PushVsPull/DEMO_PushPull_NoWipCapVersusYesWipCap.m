%% Purpose
% The following demo sweeps over the WIP Cap in a WIP-Capped production system.  The demo invokes 
% the simulation model *ProdSys_MakeToOrderPUSH_optionalWIPCap* (through its wrapper function) over
% a range of per-workstation queue capacities.  The whole system's WIP cap is the sum of each 
% workstation's queue capacity plus _k_ server slots.  The expected result is that Work-In-Process
% and Cycle Time will be controlled by the WIP Cap, as well as Throughput up to the system's
% capacity, and that the average dispatch backlog will increase as a decreasing WIP Cap reduces the
% system's capacity.
%
% Parameters which can be changed by a user include order interarrival times' distribution, mean, 
% and variability, processing times' distribution, mean, and variability at each workstation, and 
% the queue capacity at each workstation.  The model uses the G/G/k workstation library block which 
% includes both preemptive failures and non-preemptive setups, and if desired values can be set for 
% time-until-failure, repair time, count-until-setup, and setup time at each workstation.


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
OrderInterArrivalTime_distrib = 'gamma';
OrderInterArrivalTime_mean = 20;
OrderInterArrivalTime_SCV = 1;

ProcessingTime_distribs = {'gamma', 'gamma', 'gamma', 'gamma'};
AvgUtil = 0.98;
ProcessingTime_means = OrderInterArrivalTime_mean * AvgUtil * ones(1,4);
ProcessingTime_SCVs = [1 1 1 1];

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

EachWksCapacity = [Inf, 31 : -2 : 1];  %Sweep over this (with the same value at each workstation)

nReps = 10;  %replications
nDepartBeforeSimStop = 10000;


%% Check File Dependencies
f1 = 'SimWrapper_ProdSys_MakeToOrderPUSH_optionalWIPCap';
HELPER_ValidateFileDependencies({f1});


%% Simulate
%Pre-Processing
OrderInterArrivalTime_var = OrderInterArrivalTime_mean^2 * OrderInterArrivalTime_SCV;
ProcessingTime_vars = ProcessingTime_means.^2 .* ProcessingTime_SCVs;
TimeUntilFailure_vars = TimeUntilFailure_means.^2 .* TimeUntilFailure_SCVs;
TimeToRepair_vars = TimeToRepair_means.^2 .* TimeToRepair_SCVs;
CountUntilSetup_vars = CountUntilSetup_means.^2 .* CountUntilSetup_SCVs;
SetupTime_vars = SetupTime_means.^2 .* SetupTime_SCVs;
FourWorkstationCapacities = transpose(repmat(EachWksCapacity, 4, 1));
%Replication output storage
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
OrderBacklogAvgLen_reps = zeros(nReps, 1);
OrderBacklogAvgWait_reps = zeros(nReps, 1);
%Swept variable output storage
nWIPCaps = length(EachWksCapacity);
WIP_average = zeros(nWIPCaps, 1);
CT_average = zeros(nWIPCaps, 1);
TH_average = zeros(nWIPCaps, 1);
OrderBacklogAvgLen = zeros(nWIPCaps, 1);
OrderBacklogAvgWait = zeros(nWIPCaps, 1);

%Outer loop for sweep variable
for ii = 1 : nWIPCaps
    
    %Inner loop for replications
	for jj = 1 : nReps
        [   WIP_reps(jj), CT_reps(jj), TH_reps(jj), ...
			OrderBacklogAvgLen_reps(jj), OrderBacklogAvgWait_reps(jj) ] = ...
        SimWrapper_ProdSys_MakeToOrderPUSH_optionalWIPCap( ...
            OrderInterArrivalTime_distrib, OrderInterArrivalTime_mean, OrderInterArrivalTime_var, ...
            ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_vars, ...
            TimeUntilFailure_distribs, TimeUntilFailure_means, TimeUntilFailure_vars, ...
            TimeToRepair_distribs, TimeToRepair_means, TimeToRepair_vars, ...
            CountUntilSetup_distribs, CountUntilSetup_means, CountUntilSetup_vars, ...
            SetupTime_distribs, SetupTime_means, SetupTime_vars, ...
            FourWorkstationCapacities(ii,:), nDepartBeforeSimStop );
    end
    
    %Average over all replications
    WIP_average(ii) = mean(WIP_reps);
    CT_average(ii) = mean(CT_reps);
    TH_average(ii) = mean(TH_reps);
    OrderBacklogAvgLen(ii) = mean(OrderBacklogAvgLen_reps);
    OrderBacklogAvgWait(ii) = mean(OrderBacklogAvgWait_reps);
end


%% Results
WIPcaps = 4 * (EachWksCapacity+1);  %WIP includes queue capacity plus in-process => Add 1
xVals = 1 : nWIPCaps;
xTicks = 1 : 3 : nWIPCaps;
xTickLabels = cellstr(num2str(WIPcaps(xTicks)'));

figure;

subplot(2,2,1)
plot(xVals, WIP_average);
box off, axis tight;
set(gca, 'XTick', xTicks, 'XTickLabel', xTickLabels)
xlabel('Net WIP Cap');
ylabel('Average WIP');
title('              Production System with Per-Workstation WIP Caps', 'FontWeight', 'normal')

subplot(2,2,2)
plot(xVals, CT_average);
box off, axis tight;
set(gca, 'XTick', xTicks, 'XTickLabel', xTickLabels)
xlabel('Net WIP Cap');
ylabel('Average CT');

subplot(2,2,3)
plot(xVals, TH_average);
box off, axis tight;
set(gca, 'XTick', xTicks, 'XTickLabel', xTickLabels)
xlabel('Net WIP Cap');
ylabel('Average TH');

subplot(2,2,4)
plot(xVals, OrderBacklogAvgLen);
box off, axis tight;
set(gca, 'XTick', xTicks, 'XTickLabel', xTickLabels)
xlabel('Net WIP Cap');
ylabel('Dispatch Backlog: Avg Len');
