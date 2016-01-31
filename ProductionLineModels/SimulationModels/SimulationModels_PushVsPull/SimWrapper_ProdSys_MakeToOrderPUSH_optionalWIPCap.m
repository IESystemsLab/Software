function [	WIP_mean, CT_mean, TH_mean, ...
			DispatchBacklog_avgLen, DispatchBacklog_avgWait, DispatchBacklog_samples ] = ...
    SimWrapper_ProdSys_MakeToOrderPUSH_optionalWIPCap( ...
        DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_variance, ...
        ProcessingTime_distrib, ProcessingTime_mean, ProcessingTime_variance, ...
        TimeUntilFailure_distrib, TimeUntilFailure_mean, TimeUntilFailure_variance, ...
        TimeToRepair_distrib, TimeToRepair_mean, TimeToRepair_variance, ...
        CountUntilSetup_distrib, CountUntilSetup_mean, CountUntilSetup_variance, ...
        SetupTime_distrib, SetupTime_mean, SetupTime_variance, ...
        FourWorkstationCapacities, nDepartBeforeSimStop )
% This function wraps a SimEvents discrete-event simulation model and enables it to be called like
% a MATLAB function.  Each call to this function returns results for one simulation replication.
%
% INPUTS:  Anything for a G/G/1 workstation must be a four-element vector.
%
% OUTPUTS:  _samples are two-element cell arrays of {times, values}


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
sysName = 'ProdSys_MakeToOrderPUSH_optionalWIPCap';
f1 = [sysName '.slx'];
f2 = 'HELPER_DistribParamsFromMeanAndVar.m';
f3 = 'HELPER_SetDistributionParameters.m';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Open SimEvents Discrete-Event Simulation Model
%open_system(sysName);  %Open and make the model window visible
load_system(sysName);  %Load into memory without making the model window visible


%% Set Workstation Parameters
wksName = 'GG1Workstation_FailuresAndSetups';  %Model-specific
nWks = 4;  %Model-specific
for ii = 1 : nWks
	rngenPath_ProcTime = [sysName '/' wksName num2str(ii) '/RandomNumbers_ProcessingTimes'];
	rngenPath_TTF = [sysName '/' wksName num2str(ii) '/RandomNumbers_TimeUntilFailure'];
	rngenPath_TTR = [sysName '/' wksName num2str(ii) '/RandomNumbers_TimeToRepair'];
	rngenPath_CountUntilSetup = [sysName '/' wksName num2str(ii) '/RandomNumbers_CountUntilSetup'];
	rngenPath_SetupTime = [sysName '/' wksName num2str(ii) '/RandomNumbers_SetupTimes'];
	maskedSubsystemPath = [sysName '/' wksName num2str(ii) '/' wksName];
	
	%Processing Time
	[ProcDistribType, ProcDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		ProcessingTime_distrib{ii}, ProcessingTime_mean(ii), ProcessingTime_variance(ii) );
	HELPER_SetDistributionParameters(rngenPath_ProcTime, ProcDistribType, ProcDistribParams);
	
	%Time-Until-Failure
	[FailDistribType, FailDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		TimeUntilFailure_distrib{ii}, TimeUntilFailure_mean(ii), TimeUntilFailure_variance(ii) );
	HELPER_SetDistributionParameters(rngenPath_TTF, FailDistribType, FailDistribParams);
	
	%Time-To-Repair
	[RepairDistribType, RepairDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		TimeToRepair_distrib{ii}, TimeToRepair_mean(ii), TimeToRepair_variance(ii) );
	HELPER_SetDistributionParameters(rngenPath_TTR, RepairDistribType, RepairDistribParams);
	
	%Count-Until-Setup
	[ISDistribType, ISDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		CountUntilSetup_distrib{ii}, CountUntilSetup_mean(ii), CountUntilSetup_variance(ii) );
	HELPER_SetDistributionParameters(rngenPath_CountUntilSetup, ISDistribType, ISDistribParams);
	
	%Setup Time
	[SetupDistribType, SetupDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		SetupTime_distrib{ii}, SetupTime_mean(ii), SetupTime_variance(ii) );
	HELPER_SetDistributionParameters(rngenPath_SetupTime, SetupDistribType, SetupDistribParams);
	
	%Queue Capacity
	set_param(maskedSubsystemPath, 'Capacity', num2str(FourWorkstationCapacities(ii)));
end


%% Set Model Parameters
%Order Inter-Arrival Times
rngenIAPath = [sysName '/Random_OrderIATimes'];
%Invert mean & variance to distribution-specific parameters
[IADistribType, IADistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_variance );
%Set the distribution type and parameters
HELPER_SetDistributionParameters(rngenIAPath, IADistribType, IADistribParams);


%% Simulate
compareToConstantPath = [sysName '/Compare To Constant'];
set_param(compareToConstantPath, 'const', num2str(nDepartBeforeSimStop));
simEndTime = 1e7;  %Hopefully won't run this long, because of the departure-count cutoff
set_param(sysName, 'StartTime', num2str(0), 'StopTime', num2str(simEndTime));
se_randomizeseeds(sysName, 'Mode', 'All');
simout = sim(sysName, 'SaveOutput', 'on');


%% Results
WIP_mean = simout.get('WIP_average').signals.values(end);
CT_mean = simout.get('CT_average').signals.values(end);
TH_mean = simout.get('TH_average').signals.values(end);
DispatchBacklog_avgLen = simout.get('DispatchBacklog_avgLen').signals.values(end);
DispatchBacklog_avgWait = simout.get('DispatchBacklog_avgWait').signals.values(end);
DispatchBacklog_samples = {simout.get('DispatchBacklog_samples').time, simout.get('DispatchBacklog_samples').signals.values};