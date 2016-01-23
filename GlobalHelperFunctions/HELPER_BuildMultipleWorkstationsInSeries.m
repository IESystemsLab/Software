function [] = HELPER_BuildMultipleWorkstationsInSeries(sysName, libName, wksLibObjName, nWks, ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance, ...
    ProcessingTime_distribs, ProcessingTime_means, ProcessingTime_variances, ...
    QueueCapacityForEachWks, NumberOfServersForEachWks, nDepartBeforeSimStop )
% This is a helper function which builds a discrete-event simulation model dynamically using
% pre-defined library objects.
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
f1 = 'HELPER_DistribParamsFromMeanAndVar.m';
f2 = 'HELPER_SetDistributionParameters.m';
HELPER_ValidateFileDependencies({f1, f2});


%% Open a Blank Discrete-Event Simulation Model
try
    new_system(sysName);
    open_system(sysName);
catch
    open_system(sysName);
    Simulink.BlockDiagram.deleteContents(sysName);
end


%% Load Library of Workstation Objects
load_system(libName);


%% Create Source
sourcePath = [sysName '/Source'];
sourceHandle = add_block('built-in/TimeBasedEntityGenerator', sourcePath);
sourceXY = [50 310];
sourceWH = [90 60];
set_param(sourceHandle, 'Position', [sourceXY(1), sourceXY(2), sourceXY(1)+sourceWH(1), sourceXY(2)+sourceWH(2)]);  %[left top right bottom]
set_param(sourceHandle, 'GenerateEntitiesUpon', 'Intergeneration time from port t', 'GenerateEntityAtSimulationStart', 'off');
phOut = get_param(sourceHandle, 'PortHandles');
lastGroupRConnPos = get_param(phOut.RConn, 'Position');

% RandomNumbers_InterArrivals
rngenIAPath = [sysName '/RandomNumbers_InterArrivals'];
rngenIAHandle = add_block('built-in/EventBasedRandomNumber', rngenIAPath);
rngenXY = [50 200];
rngenWH = [80 60];
set_param(rngenIAHandle, 'Orientation', 'left');
set_param(rngenIAHandle, 'Position', [rngenXY(1), rngenXY(2), rngenXY(1)+rngenWH(1), rngenXY(2)+rngenWH(2)]);  %[left top right bottom]
%Set the inter-arrival time distribution {type, mean, variance}
[IADistribType, IADistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
    InterarrivalTime_distrib, InterarrivalTime_mean, InterarrivalTime_variance );
HELPER_SetDistributionParameters(rngenIAHandle, IADistribType, IADistribParams);

% Connector
phOut = get_param(rngenIAHandle, 'PortHandles');
phOutPos = get_param(phOut.Outport, 'Position');
ph = get_param(sourceHandle, 'PortHandles');
phInPos = get_param(ph.Inport, 'Position');
add_line(sysName, [phOutPos; phInPos]);


%% Add Workstation Library Object
%signalNames = {'nArrivals', 'nDepartures', 'ProcTime_samples', 'CT_samples', 'WIPq_avg', 'CTq_samples', 'uServers_avg'};
signalNames = {'WIP_samples', 'WIP_average', 'CT_samples', 'CT_average', 'TH_samples', 'TH_average', 'Util_average'};
signalOutputPortNumbers = 1 : length(signalNames);
igSpace = 310;
twSpace = 60;
for ii = 1 : nWks
    %SingleWorkstation
    wksPath = [sysName '/' 'GGkWorkstation' num2str(ii)];
    wksHandle = add_block([libName '/' wksLibObjName], wksPath);
    wksXY = [200+igSpace*(ii-1) 232];  %Oddly specific, but makes things align nicely
    wksWH = [125 225];
    set_param(wksHandle, 'Position', [wksXY(1), wksXY(2), wksXY(1)+wksWH(1), wksXY(2)+wksWH(2)]);  %[left top right bottom]
    set_param(wksHandle, 'LinkStatus', 'inactive');  %Disable model library link to enable editing
    
    %Configure the processing time distribution {type, mean, variance}
    wksEBRNPath = [wksPath '/RandomNumbers_ProcessingTimes'];
    if nWks == 1 && ~iscell(ProcessingTime_distribs)  %If nWks==1, accommodate a string or cell array
        ProcessingTime_distrib = ProcessingTime_distribs;
    else
        ProcessingTime_distrib = ProcessingTime_distribs{ii};
    end
    [ProcDistribType, ProcDistribParams] = HELPER_DistribParamsFromMeanAndVar( ...
		ProcessingTime_distrib, ProcessingTime_means(ii), ProcessingTime_variances(ii) );
	HELPER_SetDistributionParameters(wksEBRNPath, ProcDistribType, ProcDistribParams);
    
    %Configure queue capacity and number of servers
    wksMaskedSubsystemPath = [wksPath '/' wksLibObjName];
	try
		set_param(wksMaskedSubsystemPath, 'Capacity', num2str(QueueCapacityForEachWks(ii)));
	catch
		%Only four of the six workstation blocks expose this property as a mask parameter.  The two
		%that don't include batching, in which the queue is distributed over several blocks.
	end
	try
		set_param(wksMaskedSubsystemPath, 'NumberOfServers', num2str(NumberOfServersForEachWks(ii)));
	catch
		%Only two of the six workstation blocks expose this property as a mask parameter; the other
		%four are G/G/1, not G/G/k.
	end
	
    
    %Wire up certain measurements for output
    wksPhOut = get_param(wksHandle, 'PortHandles');
    for jj = 1 : length(signalNames)
        %DiscreteEventSignalToWorkspace
        sigToWksPath = [sysName '/ToWorkspace' '_' signalNames{jj} '_' num2str(ii)];
        sigToWksHandle = add_block('built-in/ToWorkspace', sigToWksPath);
        sigToWksXY = [375+igSpace*(ii-1) 10+twSpace*(jj-1)];
        sigToWksWH = [80 40];
        set_param(sigToWksHandle, 'Position', [sigToWksXY(1), sigToWksXY(2), sigToWksXY(1)+sigToWksWH(1), sigToWksXY(2)+sigToWksWH(2)]);
        set_param(sigToWksHandle, 'VariableName', [signalNames{jj} '_' num2str(ii)]);
        set_param(sigToWksHandle, 'MaxDataPoints', 'Inf');
        set_param(sigToWksHandle, 'SaveFormat', 'Structure With Time');
        set_param(sigToWksHandle, 'SampleTime', num2str(-1));
        
        %Connector
        phOutPos = get_param(wksPhOut.Outport(signalOutputPortNumbers(jj)), 'Position');
        ph = get_param(sigToWksHandle, 'PortHandles');
        phInPos = get_param(ph.Inport, 'Position');
        add_line(sysName, [phOutPos; phInPos]);
    end
    
    %Connector
    ph = get_param(wksHandle, 'PortHandles');
    phInPos = get_param(ph.LConn, 'Position');
    add_line(sysName, [lastGroupRConnPos; phInPos]);
    lastGroupRConnPos = get_param(ph.RConn, 'Position');  %Leave this for the loop's next iteration
end


%% Create Sink
sinkPath = [sysName '/Sink'];
sinkHandle = add_block('built-in/EntitySink', sinkPath);
sinkXY = [200+igSpace*nWks 310];
sinkLW = [90 60];
set_param(sinkHandle, 'Position', [sinkXY(1), sinkXY(2), sinkXY(1)+sinkLW(1), sinkXY(2)+sinkLW(2)]);  %[left top right bottom]
set_param(sinkHandle, 'StatNumberArrived', 'on');

%Connector
ph = get_param(sinkHandle, 'PortHandles');
phInPos = get_param(ph.LConn, 'Position');
add_line(sysName, [lastGroupRConnPos; phInPos]);

% EventToTimedSignal
e2tsPath = [sysName '/EventToTimedSignal'];
e2tsHandle = add_block('built-in/EventToTimedSignal', e2tsPath);
e2tsXY = [200+igSpace*nWks+135 320];
e2tsLW = [30 30];
set_param(e2tsHandle, 'Position', [e2tsXY(1), e2tsXY(2), e2tsXY(1)+e2tsLW(1), e2tsXY(2)+e2tsLW(2)]);  %[left top right bottom]

%Connector
phOutPos = get_param(ph.Outport, 'Position');  %ph is for Sink
ph = get_param(e2tsHandle, 'PortHandles');
phInPos = get_param(ph.Inport, 'Position');  %ph is for EventToTimedSignal
add_line(sysName, [phOutPos; phInPos]);

% Compare
geqPath = [sysName '/RelationalOperator'];
geqHandle = add_block('built-in/RelationalOperator', geqPath);
geqXY = [200+igSpace*nWks+225 310];
geqLW = [30 30];
set_param(geqHandle, 'Position', [geqXY(1), geqXY(2), geqXY(1)+geqLW(1), geqXY(2)+geqLW(2)]);  %[left top right bottom]
set_param(geqHandle, 'Operator', '>=');
set_param(geqHandle, 'InputSameDT', 'off');
set_param(geqHandle, 'OutDataTypeStr', 'boolean');

%Connector
phOutPos = get_param(ph.Outport, 'Position');  %ph is for EventToTimedSignal
ph = get_param(geqHandle, 'PortHandles');
phInPos = get_param(ph.Inport(1), 'Position');  %ph is for RelationalOperator
add_line(sysName, [phOutPos; phInPos]);

% ToConstant
cnstPath = [sysName '/Constant'];
cnstHandle = add_block('built-in/Constant', cnstPath);
cnstXY = [200+igSpace*nWks+225 360];
cnstLW = [30 30];
set_param(cnstHandle, 'Position', [cnstXY(1), cnstXY(2), cnstXY(1)+cnstLW(1), cnstXY(2)+cnstLW(2)]);  %[left top right bottom]
set_param(cnstHandle, 'Orientation', 'left');
set_param(cnstHandle, 'Value', num2str(nDepartBeforeSimStop));

%Connector
phInPos = get_param(ph.Inport(2), 'Position');  %ph is for RelationalOperator
ph = get_param(cnstHandle, 'PortHandles');
phOutPos = get_param(ph.Outport, 'Position');  %ph is for Constant
add_line(sysName, [phOutPos; phInPos]);

% StopSimulation
stopSimPath = [sysName '/StopSimulation'];
stopSimHandle = add_block('built-in/Stop', stopSimPath);
stopSimXY = [200+igSpace*nWks+305 310];
stopSimLW = [35 35];
set_param(stopSimHandle, 'Position', [stopSimXY(1), stopSimXY(2), stopSimXY(1)+stopSimLW(1), stopSimXY(2)+stopSimLW(2)]);  %[left top right bottom]

%Connector
ph = get_param(geqHandle, 'PortHandles');
phOutPos = get_param(ph.Outport, 'Position');  %ph is for RelationalOperator
ph = get_param(stopSimHandle, 'PortHandles');
phInPos = get_param(ph.Inport, 'Position');  %ph is for Stop
add_line(sysName, [phOutPos; phInPos]);