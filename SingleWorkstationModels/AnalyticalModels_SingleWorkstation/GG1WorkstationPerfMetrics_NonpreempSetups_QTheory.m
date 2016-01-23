function [ WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean, Avail_mean ] = ...
	GG1WorkstationPerfMetrics_NonpreempSetups_QTheory( ...
		InterarrivalTime_mean, InterarrivalTime_variance, ...
		ProcessingTime_mean, ProcessingTime_variance, ...
		NumberOfJobsBetweenSetups_mean, ...
		SetupTime_mean, SetupTime_variance )
% INPUTS (new):
% - NumberOfJobsBetweenSetups_mean:  Hopp & Spearman assume that the number of jobs between setups
% is exponentially distributed, and therefore only the mean is required.
% - SetupTime_mean:  The average time required for a setup.
% - SetupTime_variance:  Variability in the time required for a setup.
% 
% OUTPUTS (new):
% - Avail_mean:  The long-term fraction of time that a workstation is not down for setup or repair.
% Hopp & Spearman only define availability for preemptive failures (which are time-based), and not
% for non-preemptive setups (which are count-based).  However, I'll approximate it and return it
% from this function since it can be computed when simulating a single workstation with non- 
% preemptive setups, and it may be helpful to have a theoretical result to compare the simulation
% output against.
%
% ATTRIBUTION:  Equations (8.7-8.9) in Hopp & Spearman, Factory Physics, 2000 (edition 2).
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
f1 = 'GG1WorkstationPerfMetrics_QTheory.m';
HELPER_ValidateFileDependencies({f1});


%% Effective processing mean & variance
EffProcTime_mean = ProcessingTime_mean + SetupTime_mean ./ NumberOfJobsBetweenSetups_mean;  %(8.7)
EffProcTime_var = ProcessingTime_variance + SetupTime_variance ./ NumberOfJobsBetweenSetups_mean + ...
    ((NumberOfJobsBetweenSetups_mean - 1) ./ NumberOfJobsBetweenSetups_mean.^2).*(SetupTime_mean.^2);  %(8.8)

%Availability is a time fraction.  Convert the average count between setups to an average uptime.
uptimeApprox = NumberOfJobsBetweenSetups_mean .* ProcessingTime_mean;
Avail_mean = uptimeApprox ./ (uptimeApprox + SetupTime_mean);


%% GG1 with effective processing parameters
[WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean] = GG1WorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, InterarrivalTime_variance, ...
    EffProcTime_mean, EffProcTime_var );