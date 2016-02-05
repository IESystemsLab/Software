function [ WIP_mean, CT_mean, TH_mean, Util_means ] = GGkWorkstationPerfMetrics_MultipleInSeries_QTheory( ...
    InterarrivalTime_mean, InterarrivalTime_variance, ...
	ProcessingTime_means, ProcessingTime_variances, ...
	NumberOfServersForEachWks )
% Use closed-form approximations from Hopp and Spearman (chapter 8) to compute performance metrics 
% for multiple G/G/k workstations in series, with the output of one being the input to the next.
%
% INPUTS:
% - InterarrivalTime_mean:  The mean of interarrival times (to the first workstation)
% - InterarrivalTime_variance:  The variance of interarrival times (to the first workstation)
% - ProcessingTime_means:  The mean of processing times (one entry per G/G/k workstation)
% - ProcessingTime_variances:  The variance of processing times (one entry per G/G/k workstation)
% - kForEachQueue:  The number of parallel machines/ servers/ processors (one entry per G/G/k workstation)
%
% OUTPUTS:
% - WIP_mean (Work-In-Process):  The average inventory between the input and output of the entire
%   system, e.g. across all G/G/k workstations in series.
% - CT_mean (Cycle Time):  The average time a job/ part/ entity spends in the entire system, e.g. 
%   across all G/G/k workstations in series.
% - TH_mean (Throughput):  The average output per unit time of the entire system, which is the
%   throughput of the last G/G/k workstation in the series.
% - Util_mean:  A vector of utilizations, one for each G/G/k workstation in the series.  Each number 
%   in the vector represents the average utilization of the k machines/ servers/ processors at a
%   single G/G/k workstation, defined as the summed time each is busy divided by k * total time.
%
% LICENSE:  3-clause "Revised" or "New" or "Modified" BSD License.
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
f1 = 'GGkWorkstationPerfMetrics_QTheory.m';
f2 = 'SCVofDepartProcessFromSingleWorkstation_QTheory.m';
HELPER_ValidateFileDependencies({f1, f2});


%% Validate Inputs
nQueues = length(ProcessingTime_means);
if length(ProcessingTime_variances) ~= nQueues || length(NumberOfServersForEachWks) ~= nQueues
    error('For each G/G/k workstation in the series, a processing time mean, variance, and k is needed.');
end


%% Iterate through the serial G/G/k queues
WIPmeans = zeros(nQueues, 1);
CTmeans = zeros(nQueues, 1);
THmeans = zeros(nQueues, 1);
Umeans = zeros(nQueues, 1);
SCVsDepartProc = zeros(nQueues, 1);
for i = 1 : nQueues
    if i == 1
        %First G/G/k queue => Interarrivals from inputs
        IAmean = InterarrivalTime_mean;
        IAvar = InterarrivalTime_variance;
    else
        %Subsequent G/G/k queues => Interarrivals from previous workstation's departures
        IAmean = 1/THmeans(i-1);  %TH is units/time, and IA is time/unit
        SCVarrival = SCVsDepartProc(i-1);
        IAvar = SCVarrival * (IAmean^2);  %Manipulate definition of SCV
    end
    
    %Compute perf metrics for this workstation
    Pmean = ProcessingTime_means(i);  %User-supplied
    Pvar = ProcessingTime_variances(i);  %User-supplied
    K = NumberOfServersForEachWks(i);  %User-supplied
	[WIPmeans(i), CTmeans(i), THmeans(i), ~, ~, Umeans(i)] = ...
		GGkWorkstationPerfMetrics_QTheory( IAmean, IAvar, Pmean, Pvar, K );
    
    %Characterize this workstation's departure process (= the next workstation's arrival process)
    scvIA = IAvar ./ (IAmean.^2);
    scvP = Pvar ./ (Pmean.^2);
    SCVsDepartProc(i) = SCVofDepartProcessFromSingleWorkstation_QTheory(scvIA, scvP, Umeans(i), K);
end


%% Return
WIP_mean = sum(WIPmeans);  %scalar
CT_mean = sum(CTmeans);  %scalar
TH_mean = THmeans(end);  %scalar
Util_means = Umeans;  %vector