function [  WIP_mean, CT_mean, TH_mean, ...
            FGI_avgLen, FGI_avgWait, FGI_samples, ...
            DemandBackorders_avgLen, DemandBackorders_avgWait, DemandBackorders_samples, ...
            FillRate ] = ...
    SimWrapper_ProdSys_MakeToStockPULL_CONWIP( ...
        DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_variance, ...
        ProcessingTime_distrib, ProcessingTime_mean, ProcessingTime_variance, ...
        TimeUntilFailure_distrib, TimeUntilFailure_mean, TimeUntilFailure_variance, ...
        TimeToRepair_distrib, TimeToRepair_mean, TimeToRepair_variance, ...
        CountUntilSetup_distrib, CountUntilSetup_mean, CountUntilSetup_variance, ...
        SetupTime_distrib, SetupTime_mean, SetupTime_variance, ...
        CONWIPamount, nDepartBeforeSimStop )
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
sysName = 'ProdSys_MakeToStockPULL_CONWIP';
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
	
	%Queue Capacity (initially saved as Inf; set it explicitly just in case a user changed it)
	set_param(maskedSubsystemPath, 'Capacity', num2str(Inf));
end


%% Set Model Parameters
%Demand Inter-Arrival Times
rngenIAPath = [sysName '/Random_DemandIATimes'];
%Invert mean & variance to distribution-specific parameters
[IADistribType, IADistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    DemandInterArrivalTime_distrib, DemandInterArrivalTime_mean, DemandInterArrivalTime_variance );
%Set the distribution type and parameters
HELPER_SetDistributionParameters(rngenIAPath, IADistribType, IADistribParams);

%CONWIP Amount
fgiPath = [sysName '/FinishedGoodsInventory'];
set_param(fgiPath, 'NumberOfEventsPerPeriod', num2str(CONWIPamount));


%% Simulate
compareToConstantPath = [sysName '/Compare To Constant'];
set_param(compareToConstantPath, 'const', num2str(nDepartBeforeSimStop));
simEndTime = 1e7;  %Hopefully won't run this long, because of the departure-count cutoff
set_param(sysName, 'StartTime', num2str(0), 'StopTime', num2str(simEndTime));
se_randomizeseeds(sysName, 'Mode', 'All');

w1ID = 'Simulink:blocks:DivideByZero';
w1 = warning('off', w1ID);
w2ID = 'Simulink:Engine:OutputNotConnected';
w2 = warning('off', w2ID);
simout = sim(sysName, 'SaveOutput', 'on');
% warning(w1); %Reset state
% warning(w2); %Reset state


%% Results
WIP_mean = simout.get('WIP_average').signals.values(end);
CT_mean = simout.get('CT_average').signals.values(end);
TH_mean = simout.get('TH_average').signals.values(end);
FGI_avgLen = simout.get('FGI_avgLen').signals.values(end);
FGI_avgWait = simout.get('FGI_avgWait').signals.values(end);
FGI_samples = {simout.get('FGI_samples').time, simout.get('FGI_samples').signals.values};
DemandBackorders_avgLen = simout.get('Backorders_avgLen').signals.values(end);
DemandBackorders_avgWait = simout.get('Backorders_avgWait').signals.values(end);
DemandBackorders_samples = {simout.get('Backorders_samples').time, simout.get('Backorders_samples').signals.values};

DemandWaitTimes = simout.get('DemandWaitTimes').signals.values;
nWaitTimeSamples = length(DemandWaitTimes);
nNonZeroWait = length(find(DemandWaitTimes));
nZeroWait = nWaitTimeSamples - nNonZeroWait;
FillRate = nZeroWait / nWaitTimeSamples;
