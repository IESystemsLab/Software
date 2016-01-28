function [ meanCT, stdevCT, lbCT, ubCT ] = getCycleTime( CycleTimeData, varargin )
%Extracts and Summarizes the Cycle Time metrics from a simulation output
%[mean, stdev, lb, ub] = getCycleTime(simOut, {'AverageCycleTimePlot', 'CycleTimePlot'})

% INPUTS:
% - Raw Cycle Time Data: Simulink Output or Struct 
% - Optional Plots = {'AverageCycleTimePlot', 'CycleTimePlot'}
% - 
% OUTPUTS:
% - Expected System Cycle Time
% - Standard Deviation of System Cycle Time
% - Lower Bound of Cycle Time Confidence Interval
% - Upper Bound of Cycle Time Confidence Interval
%
%
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

%% Extract Raw Data from Input
% The function accepts the raw data in several formats including two
% different SimEvents output formats. This data needs to be extracted into
% a uniform data set.

% Output: Array of Raw Data and Time 
        
    S = whos('CycleTimeData'); %Check the Class of the Input Data
    
    if strcmp(S.class, 'Simulink.SimulationOutput') ==1
        if isempty(CycleTimeData.get('CycleTime')) ==0
           data = CycleTimeData.get('CycleTime').signals.values;
           time = CycleTimeData.get('CycleTime').time;
        else
            disp('No CycleTime Data in data set');
        end
    elseif strcmp(S.class, 'Simulink.Timeseries') == 1
        data = CycleTimeData.Data;
        time = CycleTimeData.Time;
    elseif strcmp(S.class, 'Simulink.SimulationData.Dataset') == 1
        if isempty(CycleTimeData.get('CycleTime')) == 0
            data = CycleTimeData.get('CycleTime').Values.Data;
            time = CycleTimeData.get('CycleTime').Values.time;
        else
            disp('No CycleTime Data in data set');
        end
    elseif strcmp(S.class, 'struct') == 1
        data = CycleTimeData.signals.values;
        time = CycleTimeData.time;
    else
        disp('Data set in unrecognized format');
    end

%% Calculate the Cycle Time Statistics
%Repetition Length: Due to the presence of a single run of data, the System 
%statistics are calculated using rolling windows rather than by repetitive
%sampling of the system. The length of that window is set by the
%grandularity parameter below.

    trainingPeriod = 0.25; %discard the first x% of observations
    CI = 0.95; %Set the P-value of the Two-Sided Confidence Interval
    dataLength = length(data);
    granularity = 100; %Length of rolling window
    
    start = ceil(trainingPeriod*dataLength);
    finish = length(data)-granularity;
    CT = zeros(1, dataLength);
    for sys = start:finish
        CT(sys) = mean(data(sys:(sys+granularity)));
    end
    
    CT(CT==0) = [];
    stdevCT = sqrt(var(CT));
    meanCT = mean(CT);
    lbCT = meanCT - norminv(CI)*stdevCT;
    ubCT = meanCT + norminv(CI)*stdevCT;
    

%% Produce Optional Plots based on Optional Inputs
    if isempty(varargin) == 0
       %produce plots
       charts = varargin{1};
       for c = 1:length(charts)
           if strcmp(charts{c} , 'AverageCycleTimePlot') == 1
               CumulativeAverage  = zeros(1,dataLength);
               for i = 1:dataLength
                   CumulativeAverage(i) = mean(data(1:i));
               end
               figure('Name','Average Cycle Time');
               plot(time, CumulativeAverage);
               xlabel('Time')
               ylabel('Average Cycle Time')
           end

           if strcmp(charts{c}, 'CycleTimePlot') ==1
              figure('Name', 'Cycle Time');
              plot(time, data);
              xlabel('Time');
              ylabel('Cycle Time');
           end
       end
    end
end

