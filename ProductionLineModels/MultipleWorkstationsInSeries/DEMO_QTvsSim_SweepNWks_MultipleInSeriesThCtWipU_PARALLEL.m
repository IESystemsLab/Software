%% Purpose
% The following demo compares queueing theory approximations and discrete-event simulation.  It 
% evaluates the performance measures work-in-process, cycle time, and throughput for multiple 
% workstations in series in two different ways: (1) Using closed-form queueing theory approximations
% from Hopp & Spearman, including the linking equation to characterize each workstation's departure 
% process, and (2) Using discrete-event simulation.
%
% Analytical approximations and simulation are compared for an increasing number of workstations in
% series (two, then three, then four, ...).  Evaluation is also over a range of utilizations (with
% each workstation having the same value), because the linking equation is a function of utilization
% and the goal is to evaluate the linking equation's fidelity.
%
% Parameters which can be changed by a user include interarrival time distribution, mean, and
% variability, processing time distribution, means (one subplot for each), and variability, the type
% of single workstations assembled in series (plain vanilla, with preemptive failures, with non-
% preemptive setups, with batching), and each workstation's queue capacity and number of servers.
%
% UPDATE:  The _PARALLEL_ version of this demo supercedes the _SERIAL_ version.  It should produce
% exactly the same results, just much faster.  It introduces parallelization by replacing several 
% nested FOR loops with a single PARFOR loop, which by default will start and use as many background
% MATLAB sessions as your processor has cores.


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
f1 = 'GGkWorkstationPerfMetrics_MultipleInSeries_QTheory.m';
f2 = 'SimWrapper_GGkWorkstation_MultipleInSeries.m';
f3 = 'HELPER_VisualizationType5.m';
libName = 'SingleWorkstationModelLibrary';
HELPER_ValidateFileDependencies({f1, f2, f3, libName});


%% Input Variables
InterarrivalTime_distrib = 'gamma';
InterarrivalTime_mean = 100;
InterarrivalTime_SCV = 0.1;

nWksInSeries = 1 : 1 : 15;  %Sweep over this

%Each serial workstation will have the same processing time values
ProcessingTime_distrib = 'gamma';
ProcessingTime_means = [0.1 1 99 99.9];  %Sweep over this (to vary utilization)
ProcessingTime_SCV = 0.1;

QueueCapacity = Inf;
NumberOfServers = 1;

nReps = 3;  %replications
nDepartBeforeSimStop = 2000;

% A name for the SimEvents model to create.  CAREFUL: If a model with this name already exists, then
% all content will be erased!
sysName = 'MultipleWorkstations_nInSeries';
% libName is defined and checked above.  Which block to use in the single workstation model library?
% (At time of writing, it also contains library objects with preemptive failures, non-preemptive setups, and batching)
wksLibObjName = 'GGkWorkstation';


%% Simulate
InterarrivalTime_variance = InterarrivalTime_mean.^2 * InterarrivalTime_SCV;
ProcessingTime_variances = ProcessingTime_means.^2 * ProcessingTime_SCV;
UtilMeans = ProcessingTime_means ./ (InterarrivalTime_mean * NumberOfServers);

nWks = length(nWksInSeries);
nUtilPts = length(UtilMeans);
N = nWks * nUtilPts * nReps;
nWksInSeries_repd3 = repmat(nWksInSeries', 1, nUtilPts, nReps);
ProcessingTimeMeans_repd3 = repmat(ProcessingTime_means, nWks, 1, nReps);
ProcessingTimeVars_repd3 = repmat(ProcessingTime_variances, nWks, 1, nReps);

WIP_means_SIM3 = zeros(nWks, nUtilPts, nReps);
CT_means_SIM3 = zeros(nWks, nUtilPts, nReps);
TH_means_SIM3 = zeros(nWks, nUtilPts, nReps);

parfor ii = 1 : N
    %What makes this challenging:  I need to collapse three FOR loops (for ii=1:nWks, for
    %jj=1:nUtilPts, for kk=1:nReps) into a single PARFOR loop.  This means that I must use a single
    %index to iterate over values of nWksInSeries, proc time mean & var, and replications.  To do
    %this, rely on MATLAB behavior that when single-indexing into a multi-dimensional array, the 1st
    %dimension is rows, the 2nd dimension is columns, and the 3rd dimension is frames.
	% 1st dim (rows):  Sweep nWks
	% 2nd dim (columns):  Sweep nUtilPts (each with a different processing time mean & var)
	% 3rd dim (frames):  replications (for the same values of nWks, procTimeMean, procTimeVar)
    ProcTime_distribForEachWks = repmat({ProcessingTime_distrib}, nWksInSeries_repd3(ii), 1);
    ProcTime_meanForEachWks = repmat(ProcessingTimeMeans_repd3(ii), nWksInSeries_repd3(ii), 1);
	ProcTime_varForEachWks = repmat(ProcessingTimeVars_repd3(ii), nWksInSeries_repd3(ii), 1);
	QueueCapacityForEachWks = repmat(QueueCapacity, nWksInSeries_repd3(ii), 1);
	NumberOfServersForEachWks = repmat(NumberOfServers, nWksInSeries_repd3(ii), 1);
	
    [ WIP_means_SIM3(ii), CT_means_SIM3(ii), TH_means_SIM3(ii) ] = ...
	SimWrapper_GGkWorkstation_MultipleInSeries( ...
		sysName, libName, wksLibObjName, ...
		InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance, ...
		ProcTime_distribForEachWks, ProcTime_meanForEachWks, ProcTime_varForEachWks, ...
		QueueCapacityForEachWks, NumberOfServersForEachWks, nDepartBeforeSimStop );
end


%% Flatten replications (average over all)
repDim = 3;
WIP_means_SIM = mean(WIP_means_SIM3, repDim);
CT_means_SIM = mean(CT_means_SIM3, repDim);
TH_means_SIM = mean(TH_means_SIM3, repDim);
		
        
%% Analytical approximation (Which is fast, so separate it from parallel simulations)
WIP_means_CF = zeros(nWks, nUtilPts);
CT_means_CF = zeros(nWks, nUtilPts);
TH_means_CF = zeros(nWks, nUtilPts);

for ii = 1 : nWks
    NumberOfServersForEachWks = repmat(NumberOfServers, nWksInSeries(ii), 1);
	for jj = 1 : nUtilPts
        ProcTime_meanForEachWks = repmat(ProcessingTime_means(jj), nWksInSeries(ii), 1);
		ProcTime_varForEachWks = repmat(ProcessingTime_variances(jj), nWksInSeries(ii), 1);
        
        [WIP_means_CF(ii,jj), CT_means_CF(ii,jj), TH_means_CF(ii,jj) ] = ...
			GGkWorkstationPerfMetrics_MultipleInSeries_QTheory( ...
				InterarrivalTime_mean, InterarrivalTime_variance, ...
				ProcTime_meanForEachWks, ProcTime_varForEachWks, ...
				NumberOfServersForEachWks );
	end
end


%% Visualize
subplotTitles = cell(nUtilPts, 1);
for kk = 1 : nUtilPts
    subplotTitles{kk} = ['u=' num2str(UtilMeans(kk)) ' at all workstations'];
end

%WIP
HELPER_VisualizationType5(nWksInSeries, 'Number of Queues in Series', ...
    WIP_means_CF, 'QTheory Approx', WIP_means_SIM, 'Simulation', ...
    'Work-In-Process', subplotTitles);

%CT
HELPER_VisualizationType5(nWksInSeries, 'Number of Queues in Series', ...
    CT_means_CF, 'QTheory Approx', CT_means_SIM, 'Simulation', ...
    'Cycle Time', subplotTitles);

%TH
HELPER_VisualizationType5(nWksInSeries, 'Number of Queues in Series', ...
    TH_means_CF, 'QTheory Approx', TH_means_SIM, 'Simulation', ...
    'Throughput', subplotTitles);