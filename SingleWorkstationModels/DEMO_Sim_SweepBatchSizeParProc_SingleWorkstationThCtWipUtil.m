%% Purpose
% The purpose of the following demo is to reproduce figure 9.6 in Hopp & Spearman (ed. 2).  The demo
% invokes the simulation model 'GGkWorkstation_MakeAndMoveBatches_Parallel' (through its wrapper
% function) over a range of process batch sizes with *parallel* batch processing.  Any of the
% performance measures [WIP, CT, TH, UTIL] can be plotted against batch size; Hopp & Spearman's
% figure 9.6 shows cycle time, so that is what is generated at the time of writing.
%
% Parameters which can be changed by a user include a range of process batch sizes to sweep over, a
% transfer batch size, the distribution, mean, and variability of interarrival time and processing
% time (parallel processing = for the whole batch), and the number of servers.


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
f1 = 'SimWrapper_GGkWorkstation_MakeAndMoveBatches_Parallel';
HELPER_ValidateFileDependencies({f1});


%% Input Parameters
makeBatchSize = [5 : 1 : 15, 20 : 5 : 60];
moveBatchSize = 1;
nServers = 1;  %G/G/1

iaDistrib = 'exponential';
iaMean = 20;
iaVar = 20^2;  %code will ignore this value b/c exponential is a one-parameter distribution

batchProcDistrib = 'exponential';
batchProcMean = 90;
batchProcVar = 90^2;  %code will ignore this value b/c exponential is a one-parameter distribution

nReps = 8;  %replications
nDepartBeforeSimStop = 4000;


%% Simulate
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
U_reps = zeros(nReps, 1);
nK = length(makeBatchSize);
WIP_average = zeros(nK, 1);
CT_average = zeros(nK, 1);
TH_average = zeros(nK, 1);
U_average = zeros(nK, 1);

%Outer loop for sweep variable
for ii = 1 : nK
    
    %Inner loop for replications
	for jj = 1 : nReps
		[WIP_reps(jj), CT_reps(jj), TH_reps(jj), U_reps(jj)] = SimWrapper_GGkWorkstation_MakeAndMoveBatches_Parallel( ...
			iaDistrib, iaMean, iaVar, ...
			batchProcDistrib, batchProcMean, batchProcVar, ...
			makeBatchSize(ii), moveBatchSize, nServers, nDepartBeforeSimStop);
    end
    
    %Average over all replications
	WIP_average(ii) = mean(WIP_reps);
	CT_average(ii) = mean(CT_reps);
	TH_average(ii) = mean(TH_reps);
	U_average(ii) = mean(U_reps);
end


%% Visualize
figure, hold on, box off;
plot(makeBatchSize, CT_average);
xlabel('Process Batch Size');
ylabel('Average Cycle Time');
title('Process Batching with Parallel Batch Processing', 'FontWeight', 'normal')