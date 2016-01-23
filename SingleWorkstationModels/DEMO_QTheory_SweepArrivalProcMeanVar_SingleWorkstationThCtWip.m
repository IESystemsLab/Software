%% Purpose
% The following demo uses the closed-form queueing theory approximations from Hopp & Spearman, 
% chapter 8, to examine how the performance measures work-in-process, cycle time, and throughput 
% respond for a single workstation as various things change - the mean and variance of queue inter-
% arrival times, the mean and variance of server processing times, and the number of servers/ 
% machines/ processors _k_.  Several interesting things can be visualized in the results, including 
% Little's Law, the response of the system to increasing utilization, and the response of the system
% to increasing variability in interarrival or processing times.
%
% Parameters which can be changed by a user include interarrival time mean, interarrival time 
% variance, processing time mean, and processing time variance.


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
f1 = 'GGkWorkstationPerfMetrics_QTheory.m';
f2 = 'HELPER_VisualizationType1.m';
HELPER_ValidateFileDependencies({f1, f2});


%% Variables
%Small numbers are chosen to scale the resulting visualizations
%(to make WIP, CT, and TH coexist nicely on the same plot)
InterarrivalTime_mean = 2;
InterarrivalTime_var = 4;  %SCVia = 1
ProcessingTime_mean = 1;
ProcessingTime_var = 1;  %SCVp = 1


%% Inter-Arrival Times:  Change the mean
InterarrivalTime_means = 1.02: 0.02: 1.5;  %For k=1, utilization from 98% to 67%
InterarrivalTime_vars = InterarrivalTime_var * ones(1, length(InterarrivalTime_means));
figure;
for k = 1 : 2  %Make subplots for different numbers of servers/ machines/ processors 'k'
    %Compute performance measures
	[WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean] = GGkWorkstationPerfMetrics_QTheory( ...
        InterarrivalTime_means, InterarrivalTime_vars, ...
        ProcessingTime_mean, ProcessingTime_var, ...
        k );
	%Plot the results
    HELPER_VisualizationType1(Util_mean, 'Mean Utilization of Servers', ...
        WIP_mean, 'WIP', ...
        CT_mean, 'CT', ...
        TH_mean, 'TH', ...
        k, 'Change Interarrival Time Mean');
end


%% Processing Times:  Change the mean
ProcessingTime_means = 1.5: 0.02: 1.98;  %For k=1, utilization from 75% to 99%
ProcessingTime_vars = ProcessingTime_var * ones(1, length(ProcessingTime_means));
figure;
for k = 1 : 2  %Make subplots for different numbers of servers/ machines/ processors 'k'
    %Compute performance measures
	[WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean] = GGkWorkstationPerfMetrics_QTheory( ...
        InterarrivalTime_mean, InterarrivalTime_var, ...
        ProcessingTime_means, ProcessingTime_vars, ...
        k );
	%Plot the results
    HELPER_VisualizationType1(Util_mean, 'Mean Utilization of Servers', ...
        WIP_mean, 'WIP', ...
        CT_mean, 'CT', ...
        TH_mean, 'TH', ...
        k, 'Change Processing Time Mean');
end


%% Inter-Arrival Times:  Change the variance
InterarrivalTime_vars2 = 0.4: 0.4: 4;  %SCVia = 0.1: 0.1: 2
InterarrivalTime_means2 = InterarrivalTime_mean * ones(1, length(InterarrivalTime_vars2));
SCVia = InterarrivalTime_vars2 ./ (InterarrivalTime_mean^2);
figure;
for k = 1 : 2  %Make subplots for different numbers of servers/ machines/ processors 'k'
    %Compute performance measures
	[WIP_mean, CT_mean, TH_mean] = GGkWorkstationPerfMetrics_QTheory( ...
        InterarrivalTime_means2, InterarrivalTime_vars2, ...
        ProcessingTime_mean, ProcessingTime_var, ...
        k );
	%Plot the results
    HELPER_VisualizationType1(SCVia, 'SCV of Inter-Arrival Times', ...
        WIP_mean, 'WIP', ...
        CT_mean, 'CT', ...
        TH_mean, 'TH', ...
        k, 'Change Interarrival Time Variance');
end


%% Processing Times:  Change the variance
ProcessingTime_vars2 = 0.1: 0.1: 2;  %SCVp = 0.1: 0.1: 2
ProcessingTime_means2 = ProcessingTime_mean * ones(1, length(ProcessingTime_vars2));
SCVp = ProcessingTime_vars2 ./ (ProcessingTime_mean^2);
figure;
for k = 1 : 2  %Make subplots for different numbers of servers/ machines/ processors 'k'
    %Compute performance measures
	[WIP_mean, CT_mean, TH_mean] = GGkWorkstationPerfMetrics_QTheory( ...
        InterarrivalTime_mean, InterarrivalTime_var, ...
        ProcessingTime_means2, ProcessingTime_vars2, ...
        k );
	%Plot the results
    HELPER_VisualizationType1(SCVp, 'SCV of Processing Times', ...
        WIP_mean, 'WIP', ...
        CT_mean, 'CT', ...
        TH_mean, 'TH', ...
        k, 'Change Processing Time Variance');
end