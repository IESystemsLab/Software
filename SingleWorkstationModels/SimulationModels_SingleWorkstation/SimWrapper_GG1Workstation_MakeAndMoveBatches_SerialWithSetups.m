function [ WIP_mean, CT_mean, TH_mean, Util_mean ] = SimWrapper_GG1Workstation_MakeAndMoveBatches_SerialWithSetups( ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance, ...
    ProcessingTime_distrib, ProcessingTime_mean, ProcessingTime_variance, ...
	SetupTime_constant, ...
	ProcessBatchSize, TransferBatchSize, nDepartBeforeSimStop )
%This function wraps a SimEvents discrete-event simulation model and enables it to be called like
%a MATLAB function.  Each call to this function returns results for one simulation replication.
%
%The wrapped discrete-event simulation model concerns a single G/G/k workstation with make (a.k.a. 
%process) batches and move (a.k.a. transfer) batching.  The model implements *serial* batch
%processing, meaning that processing time is for each element in a make batch.  The move batch size
%controls what Hopp & Spearman call "lot splitting" - are individual parts are sent downstream as
%soon as processed, or are they held until the entire batch has finished processing?  Also, the
%model implements a (deterministic-time) setup between each make batch.


%%
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
sysName = 'GG1Workstation_MakeAndMoveBatches_SerialWithSetups';
f1 = [sysName '.slx'];
f2 = 'HELPER_DistribParamsFromMeanAndVar.m';
f3 = 'HELPER_SetDistributionParameters.m';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Open SimEvents Discrete-Event Simulation Model
open_system(sysName);  %Open and make the model window visible
%load_system(sysName);  %Load into memory without making the model window visible


%% Set Inter-Arrival Time Distribution
rngenIAPath = [sysName '/RandomNumbers_InterArrivalTimes'];
%Invert mean & variance to distribution-specific parameters
[IADistribType, IADistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance );
%Set the distribution type and parameters
HELPER_SetDistributionParameters(rngenIAPath, IADistribType, IADistribParams);


%% Set Processing Time Distribution
rngenPPath = [sysName '/' sysName '/RandomNumbers_ProcessingTimes'];
%Invert mean & variance to distribution-specific parameters
[ProcDistribType, ProcDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    ProcessingTime_distrib, ProcessingTime_mean, ProcessingTime_variance );
%Set the distribution type and parameters
HELPER_SetDistributionParameters(rngenPPath, ProcDistribType, ProcDistribParams);


%% Set Setup Time
constantSPath = [sysName '/' sysName '/Constant_SetupTime'];
set_param(constantSPath, 'Value', num2str(SetupTime_constant));


%% Set ProcessBatchSize and TransferBatchSize
maskedSubsystemPath = [sysName '/' sysName '/' sysName];
set_param(maskedSubsystemPath, 'MakeBatchSize', num2str(ProcessBatchSize));
set_param(maskedSubsystemPath, 'MoveBatchSize', num2str(TransferBatchSize));


%% Simulate
compareToConstantPath = [sysName '/Compare To Constant'];
set_param(compareToConstantPath, 'const', num2str(nDepartBeforeSimStop));
simEndTime = 1e7;  %Hopefully won't run this long because of the departure-count cutoff
set_param(sysName, 'StartTime', num2str(0), 'StopTime', num2str(simEndTime));
se_randomizeseeds(sysName, 'Mode', 'All');
simout = sim(sysName, 'SaveOutput', 'on');


%% Results
WIP_mean = simout.get('WIP_average').signals.values(end);
CT_mean = simout.get('CT_average').signals.values(end);
TH_mean = simout.get('TH_average').signals.values(end);
Util_mean = simout.get('Util_average').signals.values(end);