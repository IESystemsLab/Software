%% Purpose
% The following demo compares queueing theory approximations and discrete-event simulation.  It 
% evaluates the performance measures work-in-process, cycle time, and throughput using closed-form
% queueing theory approximations from Hopp & Spearman, chapter 8, and then tests the quality of
% those approximations by comparing with discrete-event simulation results.  Utilization is swept
% over, and at the time of writing focus is on high utilizations, because that is where deviations 
% (if any) are expected.
%
% Parameters which can be changed by a user include interarrival time distribution, mean, and
% variability, processing time means & variability (proc time means are used to vary utilization,
% and the demo is configured to generate a separate curve for each processing time distribution),
% the single workstation's queue capacity, and its number of servers.


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
f1 = 'GG1WorkstationPerfMetrics_QTheory.m';
f2 = 'SimWrapper_GGkWorkstation.m';
f3 = 'HELPER_VisualizationType2.m';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Input Variables
InterarrivalTime_distrib = 'gamma';
InterarrivalTime_mean = 60;
InterarrivalTime_var = 60^2;  %SCVia = 1

%The next variable lists distribution types for which we can currently invert backwards from mean
%and variance to distribution-specific parameters.  More distribution types are possible, they're
%just harder and not implemented at the time of writing.
ProcessingTime_DistribRange = {'Uniform', 'Triangular_Symmetric', 'Gamma', 'Normal', 'Lognormal', 'Beta_HalfToOneAndOneHalfMean'};

% Vary utilization using Processing Time means
ProcessingTime_MeanRange = [55: 0.5: 58, 58.5: 0.2: 59.3, 59.5: 0.1: 59.8];
%Keep variance small because some of the distribution types can go negative ... to eliminate any
%risk of a negative sample, use a non-negative distribution.
ProcessingTime_var = 60;  %SCVp ~ 0.0167.

QueueCapacity = Inf;
NumberOfServers = 1;

nReps = 5;  %replications
nDepartBeforeSimStop = 2000;


%% Simulate
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
nDistribs = length(ProcessingTime_DistribRange);
nMeans = length(ProcessingTime_MeanRange);
WIPmeans = zeros(nDistribs+1, nMeans);  %+1 row to store the queueing theory result
CTmeans = zeros(nDistribs+1, nMeans);
THmeans = zeros(nDistribs+1, nMeans);

%Outer loop for sweep variable
for jj = 1 : nMeans
    
    %Outer loop for sweep variable
	for ii = 1 : nDistribs
        
		%Inner loop for replications
		for kk = 1 : nReps
			[WIP_reps(kk), CT_reps(kk), TH_reps(kk)] = SimWrapper_GGkWorkstation( ...
				InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_var, ...
				ProcessingTime_DistribRange{ii}, ProcessingTime_MeanRange(jj), ProcessingTime_var, ...
				QueueCapacity, NumberOfServers, nDepartBeforeSimStop );
        end
        
        %Average over all replications
		WIPmeans(ii,jj) = mean(WIP_reps);
		CTmeans(ii,jj) = mean(CT_reps);
		THmeans(ii,jj) = mean(TH_reps);
    end
    
	%Analytical approximation
	[WIPmeans(end,jj), CTmeans(end,jj), THmeans(end,jj)] = GG1WorkstationPerfMetrics_QTheory( ...
		InterarrivalTime_mean, InterarrivalTime_var, ...
		ProcessingTime_MeanRange(jj), ProcessingTime_var );
end


%% Visualize Results
Util_means = ProcessingTime_MeanRange ./ (InterarrivalTime_mean * NumberOfServers);
linespecs = {'r-','g--','b:','c-.','m-','k--','y:'};

%WIP
HELPER_VisualizationType2(Util_means, 'Utilization', ...
	WIPmeans, 'Work-In-Process', ...
	linespecs, ProcessingTime_DistribRange);

%CT
HELPER_VisualizationType2(Util_means, 'Utilization', ...
	CTmeans, 'Cycle Time', ...
	linespecs, ProcessingTime_DistribRange);

%TH
HELPER_VisualizationType2(Util_means, 'Utilization', ...
	THmeans, 'Throughput', ...
	linespecs, ProcessingTime_DistribRange);