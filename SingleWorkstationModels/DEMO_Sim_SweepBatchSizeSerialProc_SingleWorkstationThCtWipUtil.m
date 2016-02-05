%% Purpose
% The purpose of the following demo is to reproduce figure 9.5 in Hopp & Spearman (ed. 2).  The demo
% invokes the simulation model *GGkWorkstation_MakeAndMoveBatches_SerialWithSetups* (through its
% wrapper function) over a range of process batch sizes with _serial_ batch processing and setups
% between batches.  Any of the performance measures [WIP, CT, TH, UTIL] can be plotted against batch
% size; Hopp & Spearman's figure 9.5 shows cycle time, so that is what is generated at the time of writing.
%
% Parameters which can be changed by a user include a range of process batch sizes to sweep over, a
% transfer batch size (which enables choosing with or without lot splitting), the distribution,
% mean, and variability of interarrival time and processing time (serial processing = for each
% entity in a batch), and a deterministic setup time between batches.


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
f1 = 'SimWrapper_GG1Workstation_MakeAndMoveBatches_SerialWithSetups';
HELPER_ValidateFileDependencies({f1});


%% Input Parameters
makeBatchSize = 3 : 1 : 12;

%moveBatchSize = makeBatchSize;  %If NO lot splitting
moveBatchSize = ones(1, length(makeBatchSize));  %If YES lot splitting

iaDistrib = 'exponential';
iaMean = 60;
iaVar = 60^2;  %code will ignore this value b/c exponential is a one-paramater distribution

procDistrib = 'exponential';
procMean = 16;
procVar = 16^2;  %code will ignore this value b/c exponential is a one-paramater distribution

setupTime = 120;  %Hopp & Spearman (sec 9.4.2 in ed2) have this as deterministic

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
		[WIP_reps(jj), CT_reps(jj), TH_reps(jj), U_reps(jj)] = SimWrapper_GG1Workstation_MakeAndMoveBatches_SerialWithSetups( ...
			iaDistrib, iaMean, iaVar, ...
			procDistrib, procMean, procVar, ...
			setupTime, ...
			makeBatchSize(ii), moveBatchSize(ii), nDepartBeforeSimStop );
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
title('Process Batching with Serial Batch Processing and Setups Between Batches', 'FontWeight', 'normal')
