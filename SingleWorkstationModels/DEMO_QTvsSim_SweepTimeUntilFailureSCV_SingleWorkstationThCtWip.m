%% Purpose
% Hopp and Spearman offer equations 8.4-8.6 (ed. 2) for _effective_ process time in the case of
% preemptive failures.  However, they derive these formulas by assuming that time-until-failure is 
% exponentially distributed (SCV=1).  Simulation allows arbitrary SCVs, so it can be tested how
% closed-form and simulation results compare when the exponential assumption is relaxed.
%
% Parameters which can be changed by a user include the distribution, mean, and variability of
% interarrival time, processing time, time-until-failure (for this a range of SCVs to sweep over),
% and time-to-repair.


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
distribIA = 'normal';
meanIA = 10;
varianceIA = eps;

distribProc = 'normal';
meanProc = 7.5;
varianceProc = eps;

%MTTF:  Hopp & Spearman's definition of MTTF assumes that the clock stops during repairs, and
%the simulation model was built to match that assumption.
distribFail = 'gamma'; 
MTTF = 200;
scvTTF = 0.1 : 0.1 : 2;  %Sweep over this

distribRepair = 'normal';
MTTR = 20;
varianceTTR = eps;

nReps = 15;  %replications
nDepartBeforeSimStop = 20000;


%% Check File Dependencies
f1 = 'GG1WorkstationPerfMetrics_PreempFailures_QTheory.m';
f2 = 'SimWrapper_GG1Workstation_RandomCalendarTimeUntilPreempFailure.m';
HELPER_ValidateFileDependencies({f1, f2});


%% Closed-Form
[WIP_mean_CF, CT_mean_CF, TH_mean_CF, WIPq_mean, CTq_mean, Util_mean_CF, Avail_mean_CF] = ...
	GG1WorkstationPerfMetrics_PreempFailures_QTheory( ...
		meanIA, varianceIA, ...
		meanProc, varianceProc, ...
		MTTF, ...
		MTTR, varianceTTR);


%% Simulation
varianceTTF = MTTF^2 .* scvTTF;
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
U_reps = zeros(nReps, 1);
A_reps = zeros(nReps, 1);
nSCV = length(scvTTF);
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
			SimWrapper_GG1Workstation_RandomCalendarTimeUntilPreempFailure( ...
				distribIA, meanIA, varianceIA, ...
				distribProc, meanProc, varianceProc, ...
				distribFail, MTTF, varianceTTF(ii), ...
				distribRepair, MTTR, varianceTTR, ...
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
plot(scvTTF, WIP_mean_SIM, 'b-', scvTTF, WIP_mean_CF*ones(length(scvTTF),1), 'k--');
ylabel('Work-In-Process');
title('            Time-To-Failure:  Analytical (SCV=1) versus Simulation', 'FontWeight', 'normal')
text(scvTTF(end), WIP_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvTTF(end), WIP_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');

%CT
subplot(2,2,2); hold on; box off;
plot(scvTTF, CT_mean_SIM, 'b-', scvTTF, CT_mean_CF*ones(length(scvTTF),1), 'k--');
ylabel('Cycle Time');
text(scvTTF(end), CT_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvTTF(end), CT_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');
xlabel('SCV of Time-Until-Failure');

%TH
subplot(2,2,3); hold on; box off;
plot(scvTTF, TH_mean_SIM, 'b-', scvTTF, TH_mean_CF*ones(length(scvTTF),1), 'k--');
ylabel('Throughput');
text(scvTTF(end), TH_mean_SIM(end), 'Simulation', 'HorizontalAlignment', 'right');
text(scvTTF(end), TH_mean_CF, 'Q Theory Formulas', 'HorizontalAlignment', 'right');
xlabel('SCV of Time-Until-Failure');
