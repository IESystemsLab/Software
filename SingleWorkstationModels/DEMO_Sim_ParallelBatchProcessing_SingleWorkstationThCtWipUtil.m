%% Purpose
%This demo invokes the simulation model 'GGkWorkstation_MakeAndMoveBatches_Parallel' (through its
%wrapper function) with a single set of input parameters to return a single set of performance 
%measures.  Looping is employed for replications, and the performance measures returned
%are the averages across all replications.


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
makeBatchSize = 12;
moveBatchSize = 1;
nServers = 1;  %G/G/1

iaDistrib = 'exponential';
iaMean = 20;
iaVar = 20^2;  %code will ignore this value if 'exponential' b/c it's a one-parameter distribution

batchProcDistrib = 'exponential';
batchProcMean = 90;
batchProcVar = 90^2;  %code will ignore this value if 'exponential' b/c it's a one-parameter distribution

nReps = 10;
nDepartBeforeSimStop = 2500;


%% Simulate
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
U_reps = zeros(nReps, 1);

for ii = 1 : nReps
    [WIP_reps(ii), CT_reps(ii), TH_reps(ii), U_reps(ii)] = SimWrapper_GGkWorkstation_MakeAndMoveBatches_Parallel( ...
		iaDistrib, iaMean, iaVar, ...
		batchProcDistrib, batchProcMean, batchProcVar, ...
		makeBatchSize, moveBatchSize, nServers, nDepartBeforeSimStop );
end


%% Results
WIP_average = mean(WIP_reps)
CT_average = mean(CT_reps)
TH_average = mean(TH_reps)
U_average = mean(U_reps)