function [ meanTH, stdevTH, lbTH, ubTH ] = getThroughput( ThroughputData , varargin)
%Extracts and Summarizes the Throughput metrics from a simulation output
% [mean, stdev, lb, ub] = getThroughput(simOut, {'AverageThroughputPlot', 'ThroughputPlot'})

% INPUTS:
% - Raw Throughput Data: Simulink Output or Struct 
% - Optional Plots = {'AverageThroughputPlot', 'ThroughputPlot'}
% - 
% OUTPUTS:
% - Expected System Throughput
% - Standard Deviation of System Throughput
% - Lower Bound of Throughput Confidence Interval
% - Upper Bound of Throughput Confidence Interval
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
    S = whos('ThroughputData'); %Check the Class of the Input Data
    
    if strcmp(S.class, 'Simulink.SimulationOutput') ==1
        if isempty(ThroughputData.get('Departures')) ==0
           data = ThroughputData.get('Departures').signals.values;
           time = ThroughputData.get('Departures').time;
        else
            disp('No Throughput Data in data set');
        end
    elseif strcmp(S.class, 'Simulink.Timeseries') == 1
        data = ThroughputData.Data;
        time = ThroughputData.Time;
    elseif strcmp(S.class, 'Simulink.SimulationData.Dataset') == 1
        if isempty(ThroughputData.get('Departures')) == 0
            data = ThroughputData.get('Departures').Values.Data;
            time = ThroughputData.get('Departures').Values.time;
        else
            disp('No Throughput Data in data set');
        end
    elseif strcmp(S.class, 'struct') == 1
        data = ThroughputData.signals.values;
        time = ThroughputData.time;
    else
        data = ThroughputData.signals.values;
        time = ThroughputData.time;
    end

    
%% Calculate the Throughput Statistics
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
    TH = zeros(1, dataLength);
    
    for sys = start:finish
        TH(sys) = (data(sys+granularity) - data(sys))/(time(sys+granularity) - time(sys));
    end
    
    TH(TH==0) = [];
    stdevTH = sqrt(var(TH));
    meanTH = mean(TH);
    lbTH = meanTH - norminv(CI)*stdevTH;
    ubTH = meanTH + norminv(CI)*stdevTH;
    
%% Produce Optional Plots based on Optional Inputs    
    if isempty(varargin) == 0
       %produce plots
       charts = varargin{1};
       for c = 1:length(charts)
           if strcmp(charts{c} , 'AverageThroughputPlot') == 1
               CumulativeAverage  = zeros(1,length(TH));
               for i = 1:length(TH)
                   CumulativeAverage(i) = mean(TH(1:i));
               end
               figure('Name','Average Throughput');
               plot(time(start:finish), CumulativeAverage);
               xlabel('Time')
               ylabel('Average Throughput')
           end

           if strcmp(charts{c}, 'ThroughputPlot') ==1
              figure('Name', 'Throughput');
              plot(time(start:finish), TH);
              xlabel('Time');
              ylabel('Throughput');
           end
       end
    end
end

