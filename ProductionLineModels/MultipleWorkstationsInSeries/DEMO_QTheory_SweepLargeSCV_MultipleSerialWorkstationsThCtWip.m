%% Purpose
% The following demo uses the closed-form queueing theory approximations from Hopp & Spearman, 
% chapter 8, plus the linking equation to characterize a single workstation's departure process. 
% Multiple workstations are arranged in series, all with a low processing time variability, 
% _except one with very high variability_.  Of interest is how the relative position of the high-
% variability workstation (e.g. first, middle, last) affects the overall system performance measures
% of work-in-process, cycle time, and throughput.  The expected result is the farther upstream the 
% high-variability workstation resides, the more damaging it is on overall system performance 
% measures.
%
% Parameters which can be changed by a user include interarrival time mean & variability, processing
% time means (one subplot for each) and variability (both the small SCV value for all workstations
% except one, and the large SCV value for the one aberrant workstation), the number of workstations
% in series, and the number of servers at each workstation.


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
f2 = 'HELPER_VisualizationType4';
HELPER_ValidateFileDependencies({f1, f2});


%% Input Variables
InterarrivalTime_mean = 100;
InterarrivalTime_SCV = 1;

ProcessingTime_means = [5 35 65 95];  %Use Processing Time mean to vary utilization
procTimeSmallSCV = 0.01;  %Used at all workstations except one
procTimeLargeSCV = 10;  %Used at the one aberrant workstation

nWksInSeries = 20;
nServersAtEachWks = 1;


%% Output Variables
nUtilPts = length(ProcessingTime_means);
WIP_means = zeros(nWksInSeries, nUtilPts);
CT_means = zeros(nWksInSeries, nUtilPts);
TH_means = zeros(nWksInSeries, nUtilPts);
UtilAtEachWks = ProcessingTime_means ./ (InterarrivalTime_mean * nServersAtEachWks);


%% Compute
InterarrivalTime_var = InterarrivalTime_mean.^2 * InterarrivalTime_SCV;
ProcessingTime_SmallVars = ProcessingTime_means.^2 * procTimeSmallSCV;
ProcessingTime_LargeVars = ProcessingTime_means.^2 * procTimeLargeSCV;
kForEachWks = nServersAtEachWks * ones(nWksInSeries, 1);

for ii = 1 : nWksInSeries
	for jj = 1 : nUtilPts
		ProcessingTime_meanForAllWks = ProcessingTime_means(jj) * ones(nWksInSeries, 1);
		ProcessingTime_varForAllWks = ProcessingTime_SmallVars(jj) * ones(nWksInSeries, 1);  %All SCVp = 0.01
		ProcessingTime_varForAllWks(ii) = ProcessingTime_LargeVars(jj);  %Make one SCVp = 10
	
		[WIP_means(ii,jj), CT_means(ii,jj), TH_means(ii,jj)] = GGkWorkstationPerfMetrics_MultipleInSeries_QTheory( ...
			InterarrivalTime_mean, InterarrivalTime_var, ...
			ProcessingTime_meanForAllWks, ProcessingTime_varForAllWks, ...
			kForEachWks );
	end
end


%% Visualize
xvals = 1:nWksInSeries;
curveLabels = cell(nUtilPts, 1);
for kk = 1 : nUtilPts
	curveLabels{kk} = ['u=' num2str(UtilAtEachWks(kk)) ' at all workstations'];
end
sharedTitle = ['                         ' num2str(nWksInSeries) ...
	' Serial Wks w/ SCV_p=' num2str(procTimeSmallSCV) ', except one w/ SCV_p=' num2str(procTimeLargeSCV)];

%WIP
HELPER_VisualizationType4(xvals, 'Workstation # with SCV_p=10', ...
	WIP_means, 'Work-In-Process', ...
	curveLabels, sharedTitle);
	
%CT
HELPER_VisualizationType4(xvals, 'Workstation # with SCV_p=10', ...
	CT_means, 'Cycle Time', ...
	curveLabels, sharedTitle);

%TH
HELPER_VisualizationType4(xvals, 'Workstation # with SCV_p=10', ...
	TH_means, 'Throughput', ...
	curveLabels, sharedTitle);