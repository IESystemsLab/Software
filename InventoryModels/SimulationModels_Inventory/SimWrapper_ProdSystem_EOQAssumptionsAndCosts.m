function [	TotalCost_PerSatDmd, SetupCost_PerSatDmd, ProductionCost_PerSatDmd, InventoryCost_PerSatDmd, ...
			AnnualCost_Total, AnnualCost_Setup, AnnualCost_Production, AnnualCost_Inventory ] = ...
		SimWrapper_ProdSystem_EOQAssumptionsAndCosts( ...
			SimTimeUnit, DemandUnitsPerYear_mean, DemandInterarrivalTime_Distrib, DemandInterarrivalTime_SCV, ...
			UnitProductionCost_C, LotSetupCost_A, UnitAnnualHoldingCost_H, ...
			LotSize_Q, minDepartBeforeSimStop )
% This function wraps a SimEvents discrete-event simulation model and enables it to be called like
% a MATLAB function.  Each call to this function returns results for one simulation replication.
% Here is how timing is handled:  A user can specify an arbitrary mininum number of demands to be
% satisfied before simulation stop, and you'll get the maximum of either that or a full year's
% worth.  In addition, randomization is introduced to smooth out sawtooth effects, which follow from
% patterns in where the timing of 365 days falls in the regular replenish-and-consume cycle.
%
%
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
sysName = 'ProdSystem_EOQAssumptionsAndCosts';
f1 = [sysName '.slx'];
f2 = 'HELPER_DistribParamsFromMeanAndVar.m';
f3 = 'HELPER_SetDistributionParameters.m';
HELPER_ValidateFileDependencies({f1, f2, f3});


%% Open Discrete-Event Simulation Model
open_system(sysName);  %Open and make the model window visible
%load_system(sysName);  %Load into memory without making the model window visible


%% Time
if strcmpi(SimTimeUnit, 'years')
    timeScaling = 1;
elseif strcmpi(SimTimeUnit, 'months')
    timeScaling = 12;
elseif strcmpi(SimTimeUnit, 'weeks')
    timeScaling = 365/7;
elseif strcmpi(SimTimeUnit, 'days')
    timeScaling = 365;
elseif strcmpi(SimTimeUnit, 'hours')
    timeScaling = 365*24;
elseif strcmpi(SimTimeUnit, 'minutes')
    timeScaling = 365*24*60;
elseif strcmpi(SimTimeUnit, 'seconds')
    timeScaling = 365*24*60*60;
else
	error(['The time unit "' SimTimeUnit '" is not recognized.  Supported time units include {years, months, weeks, days, hours, minutes, seconds}']);
end

DemandUnitsPerTime = DemandUnitsPerYear_mean / timeScaling;
DemandInterarrivalTime_mean = 1 / DemandUnitsPerTime;
DemandInterarrivalTime_variance = DemandInterarrivalTime_mean^2 * DemandInterarrivalTime_SCV;

UnitHoldingCost_H = UnitAnnualHoldingCost_H / timeScaling;


%% Set Demand Inter-Arrival Distribution
rngenIAPath = [sysName '/RandomNumbers_DemandIATimes'];
%Invert mean & variance to distribution-specific parameters
[IADistribType, IADistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    DemandInterarrivalTime_Distrib, DemandInterarrivalTime_mean, DemandInterarrivalTime_variance );
%Set the distribution type and parameters
HELPER_SetDistributionParameters(rngenIAPath, IADistribType, IADistribParams);


%% Set Cost Constants
pathC = [sysName '/UnitProductionCost_C'];
set_param(pathC, 'Value', num2str(UnitProductionCost_C));
pathA = [sysName '/LotSetupCost_A'];
set_param(pathA, 'Value', num2str(LotSetupCost_A));
pathH = [sysName '/UnitHoldingCost_H'];
set_param(pathH, 'Value', num2str(UnitHoldingCost_H));


%% Set Lot Size Q  (In an EOQ optimization, this is the decision variable)
pathQ = [sysName '/LotSize_Q'];
set_param(pathQ, 'Value', num2str(LotSize_Q));


%% Simulate
%Introduce an arbitrary mininum number for demands, because low annual demands lead to a simulation 
%too short for good averages.  Also, introduce randomization to smooth out sawtooth effects, which
%follow from patterns in where the timing of 365 days falls in the regular replenish-and-consume cycle.
minNumberDemands = minDepartBeforeSimStop + round(0.2 * minDepartBeforeSimStop * rand);
actualNumberDemands = DemandUnitsPerYear_mean + round(DemandUnitsPerYear_mean*rand);
stopNumberDemands = max(minNumberDemands, actualNumberDemands);
pathND = [sysName '/SatisfiedDemandCounter'];
set_param(pathND, 'const', num2str(stopNumberDemands));

veryLargeSimEndTime = 1e8;
set_param(sysName, 'StartTime', num2str(0), 'StopTime', num2str(veryLargeSimEndTime));
se_randomizeseeds(sysName, 'Mode', 'All');
simout = sim(sysName, 'SaveOutput', 'on');


%% Results (per satisfied demand)
TotalCost_PerSatDmd = simout.get('GrossCost_PerSatDmd').signals.values(end);
InventoryCost_PerSatDmd = simout.get('GrossInventoryCost_PerSatDmd').signals.values(end);
ProductionCost_PerSatDmd = simout.get('GrossProductionCost_PerSatDmd').signals.values(end);
SetupCost_PerSatDmd = simout.get('GrossSetupCost_PerSatDmd').signals.values(end);


%% Results (per year)
simEndTime = simout.get('GrossProductionCost_PerSatDmd').time(end);
simEndTimeYears = simEndTime / timeScaling;

AnnualCost_Total = simout.get('GrossCost').signals.values(end) / simEndTimeYears;
AnnualCost_Inventory = simout.get('GrossInventoryCost').signals.values(end) / simEndTimeYears;
AnnualCost_Production = simout.get('GrossProductionCost').signals.values(end) / simEndTimeYears;
AnnualCost_Setup = simout.get('GrossSetupCost').signals.values(end) / simEndTimeYears;