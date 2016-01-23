function [ WIP_mean, CT_mean, TH_mean, Util_means ] = SimWrapper_GGkWorkstation_MultipleInSeries( ...
	sysName, libName, wksLibObjName, ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance, ...
    ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_variances, ...
    QueueCapacityForEachWks, NumberOfServersForEachWks, nDepartBeforeSimStop )
% This function wraps a SimEvents discrete-event simulation model and enables it to be called like
% a MATLAB function.  Each call to this function returns results for one simulation replication.
% This SimWrapper is unusual in that it's not calling a pre-built simulation model, but rather
% building one dynamically using pre-defined library objects.
%
% The dynamically-built simulation model is of multiple G/G/k workstations in series, with the
% output of one being the input to the next.
%
% INPUTS:
% - InterarrivalTime_distrib, _mean, _variance:  string, scalar number, scalar number
% - ProcessingTime_distrib:  A cell array of strings, one for each workstation in series
% - ProcessingTime_means, _variances, kForEachWks:  Arrays of numbers with the same length as
% ProcessingTime_distrib
%
% OUTPUTS:
% - WIP_mean (Work-In-Process):  Time-averaged inventory within the entire system, e.g. within all
% G/G/k workstations in series.
% - CT_mean (Cycle Time):  Average time a job/ part/ entity spends in the entire system, e.g. within
% all G/G/k workstations in series.
% - TH_mean (Throughput):  Average output per unit time of the entire system, which is the
% throughput of the last G/G/k workstation in the series.
% - Util_mean:  A vector of utilizations, one for each G/G/k workstation in the series.  Each number
% in the vector represents the average utilization of the k machines/ servers/ processors at a
% single G/G/k workstation, defined as the summed time each is busy divided by k * total time.
%
%
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
f1 = [libName '.slx'];
f2 = 'HELPER_BuildMultipleWorkstationsInSeries';
HELPER_ValidateFileDependencies({f1, f2});


%% Validate Inputs
if iscell(ProcessingTime_distribs)  %In MATLAB, a cell array is a natural data structure for a collection of strings
    nWks = length(ProcessingTime_distribs);
else  %If one string instead of a collection of strings, infer nWks=1
    nWks = 1;
end
if length(ProcessingTime_means) ~= nWks ...
		|| length(ProcessingTime_variances) ~= nWks ...
        || length(NumberOfServersForEachWks) ~= nWks
    error('For each G/G/k workstation in the series, a processing time distribution, mean, variance, and number of servers are needed.');
end


%% Build Discrete-Event Simulation Model
HELPER_BuildMultipleWorkstationsInSeries( ...
	sysName, libName, wksLibObjName, nWks, ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance, ...
    ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_variances, ...
    QueueCapacityForEachWks, NumberOfServersForEachWks, nDepartBeforeSimStop );


%% Simulate
simEndTime = 1e7;  %Hopefully won't run this long because of the departure-count cutoff
set_param(sysName, 'StartTime', num2str(0), 'StopTime', num2str(simEndTime));
se_randomizeseeds(sysName, 'Mode', 'All');
simout = sim(sysName, 'SaveOutput', 'on');


%% Results
WIP_mean = 0;
CT_mean = 0;
Util_means = zeros(nWks, 1);

for jj = 1 : nWks
	%CT_average across multiple workstations is the sum of CT_average at each workstation.
	measureName = ['CT_average_' num2str(jj)];
	CT_mean_thisWks = simout.get(measureName).signals.values(end);
	CT_mean = CT_mean + CT_mean_thisWks;
	
	%Util_mean across multiple workstations is a vector of values, one per workstation.
	measureName = ['Util_average_' num2str(jj)];
	Util_means(jj) = simout.get(measureName).signals.values(end);
    
    %WIP_average across multiple workstations is the sum of WIP_average at each workstation.
	measureName = ['WIP_average_' num2str(jj)];
    WIP_mean_thisWks = simout.get(measureName).signals.values(end);
 	WIP_mean = WIP_mean + WIP_mean_thisWks;
end
%TH_average across multiple workstations is the TH_average at the end workstation.
measureName = ['TH_average_' num2str(nWks)];
TH_mean = simout.get(measureName).signals.values(end);