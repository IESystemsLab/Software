%% Purpose
% The purpose of the following demo is to reproduce figure 9.6 in Hopp & Spearman (ed. 2).  The demo
% invokes the simulation model *GGkWorkstation_MakeAndMoveBatches_Parallel* (through its wrapper
% function) over a range of process batch sizes with _parallel_ batch processing.  Any of the
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


%% Input Parameters
processBatchSize = 64 : 3 : 127;  %Sweep over this
transferBatchSize = 1;
nServers = 1;

iaDistrib = 'exponential';
iaMean = 0.1;
iaVar = 0.1^2;  %code will ignore this value if 'exponential' because it's a one-parameter distribution

batchProcDistrib = 'exponential';
batchProcMean = 6;
batchProcVar = 6^2;  %code will ignore this value if 'exponential' because it's a one-parameter distribution

nReps = 20;  %replications (for each value of the swept variable)
nDepartBeforeSimStop = 30000;


%% Check File Dependencies
f1 = 'SimWrapper_GGkWorkstation_MakeAndMoveBatches_Parallel';
HELPER_ValidateFileDependencies({f1});


%% Simulate
nK = length(processBatchSize);
N = nK * nReps;
processBatchSize_repd2 = repmat(processBatchSize', 1, nReps);

WIP_average2 = zeros(nK, nReps);
CT_average2 = zeros(nK, nReps);
TH_average2 = zeros(nK, nReps);
U_average2 = zeros(nK, nReps);

parfor ii = 1 : N
    [   WIP_average2(ii), CT_average2(ii), TH_average2(ii), U_average2(ii)] = ...
    SimWrapper_GGkWorkstation_MakeAndMoveBatches_Parallel( ...
        iaDistrib, iaMean, iaVar, ...
		batchProcDistrib, batchProcMean, batchProcVar, ...
		processBatchSize_repd2 (ii), transferBatchSize, nServers, nDepartBeforeSimStop);
end


%% Flatten replications (average over all)
repDim = 2;
WIP_average = mean(WIP_average2, repDim);
CT_average = mean(CT_average2, repDim);
TH_average = mean(TH_average2, repDim);
U_average = mean(U_average2, repDim);


%% Visualize
figure, hold on, box off;
plot(processBatchSize, CT_average);
xlabel('Process Batch Size');
ylabel('Average Cycle Time');
title('Process Batching (Parallel Processing)', 'FontWeight', 'normal')
