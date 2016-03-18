%% Purpose
% Hopp and Spearman offer equations 8.7-8.9 (ed. 2) for _effective_ process time in the case of
% non-preemptive setups.  However, they derive these formulas by assuming that count-between-setups
% is moderately variable (e.g. the mean and standard deviation are equal, a discrete analog of the
% exponential distribution).  Simulation allows arbitrary SCVs, so it can be tested how closed-form
% and simulation results compare when the exponential assumption is relaxed.
%
% Parameters which can be changed by a user include the distribution, mean, and variability of
% interarrival time, processing time, count-until-setup (for this a range of SCVs to sweep over),
% and setup time.


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


%% Random process parameters
%Inter-arrival times
distribIATime = 'normal';
meanIATime = 10;
varianceIATime = eps;

%Processing times
distribProcTime = 'normal';
meanProcTime = 7.5;
varianceProcTime = eps;

%Inter-setup counts
distribISCount = 'gamma';
meanISCount = 20;
scvISCount = 0.1 : 0.1 : 2;  %Sweep over this

%Setup times
distribSetupTime = 'normal';
meanSetupTime = 20;
varianceSetupTime = eps;

nReps = 15;  %replications
nDepartBeforeSimStop = 20000;


%% Check File Dependencies
f1 = 'GG1WorkstationPerfMetrics_NonpreempSetups_QTheory.m';
f2 = 'SimWrapper_GG1Workstation_RandomCountUntilNonpreempSetup.m';
HELPER_ValidateFileDependencies({f1, f2});


%% Closed-Form
[WIP_mean_CF, CT_mean_CF, TH_mean_CF, WIPq_mean, CTq_mean, Util_mean_CF, Avail_mean_CF] = ...
	GG1WorkstationPerfMetrics_NonpreempSetups_QTheory( ...
		meanIATime, varianceIATime, ...
		meanProcTime, varianceProcTime, ...
		meanISCount, ...
		meanSetupTime, varianceSetupTime );


%% Simulation
varianceISCount = meanISCount^2 .* scvISCount;
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
U_reps = zeros(nReps, 1);
A_reps = zeros(nReps, 1);
nSCV = length(scvISCount);
WIP_mean_SIM = zeros(nSCV,1);
CT_mean_SIM = zeros(nSCV,1);
TH_mean_SIM = zeros(nSCV,1);
Util_mean_SIM = zeros(nSCV,1);
Avail_mean_SIM = zeros(nSCV,1);

%Outer loop for sweep variable
for ii = 1 : nSCV
    
	%Inner loop for replications
	for jj = 1 : nReps
		[WIP_reps(jj), CT_reps(jj), TH_reps(jj), U_reps(jj), A_reps(jj)] = ...
			SimWrapper_GG1Workstation_RandomCountUntilNonpreempSetup( ...
				distribIATime, meanIATime, varianceIATime, ...
				distribProcTime, meanProcTime, varianceProcTime, ...
				distribISCount, meanISCount, varianceISCount(ii), ...
				distribSetupTime, meanSetupTime, varianceSetupTime, ...
				Inf, nDepartBeforeSimStop );
    end
    
	%Average over all replications
	WIP_mean_SIM(ii) = mean(WIP_reps);
	CT_mean_SIM(ii) = mean(CT_reps);
	TH_mean_SIM(ii) = mean(TH_reps);
	Util_mean_SIM(ii) = mean(U_reps);
	Avail_mean_SIM(ii) = mean(A_reps);
end


%% Visualize
figure;

%WIP
subplot(2,2,1); hold on; box off;
plot(scvISCount, WIP_mean_SIM, 'b-', scvISCount, WIP_mean_CF*ones(length(scvISCount),1), 'k--');
ylabel('Work-In-Process');
title('            Count-Until-Setup:  Analytical (SCV=1) versus Simulation', 'FontWeight', 'normal')
text(scvISCount(end), WIP_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvISCount(end), WIP_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');

%CT
subplot(2,2,2); hold on; box off;
plot(scvISCount, CT_mean_SIM, 'b-', scvISCount, CT_mean_CF*ones(length(scvISCount),1), 'k--');
ylabel('Cycle Time');
text(scvISCount(end), CT_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvISCount(end), CT_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');
xlabel('SCV of Count-Until-Setup');

%TH
subplot(2,2,3); hold on; box off;
plot(scvISCount, TH_mean_SIM, 'b-', scvISCount, TH_mean_CF*ones(length(scvISCount),1), 'k--');
ylabel('Throughput');
text(scvISCount(end), TH_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvISCount(end), TH_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');
xlabel('SCV of Count-Until-Setup');
