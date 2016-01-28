function [ Solution ] = BasicFactoryDynamics( ParallelMachineCount, ProcessingTime, varargin)
%Calculates the Best Case, Worst Case, and Practical Worst Case Performance
%of a Tandem Production Line

%Solution = BasicFactoryDynamics([1 2 6 2], [2 5 10 3], {'PlotsOn'})

%INPUTS:
% - ParallelMachineCount := Number of Machines at Each Workstation
% - ProcessingTime := Process time at each workstation
% - (Optional) PlotsOn := {'PlotsOn', 'PlotsOff'} produces the side-by-side plots

%OUTPUTS:
% - Solution: The WIP, CycleTime and Throughput of the System at various
            % levels of CONWIP (Used for custom plots)

%PLOTS:
% Outputs side-by-side plots of WIP vs CT and WIP vs TH

%ATTRIBUTION:
% Section 7.3 of Hopp & Spearman, Factory Physics, 1996 (edition 1).

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


    RawProcessTime = sum(ProcessingTime);
    BottleneckRate = min(ParallelMachineCount./ProcessingTime);
    CriticalWIP = BottleneckRate*RawProcessTime;
    
    Solution = zeros(25,2,3);
    
    %Calculates the Basic Factory Dynamics for WIP levels 1 to 25
    %Note: to change max level, Find&Replace (Ctrl+h) the 25
    for WIP = 1:25
        Solution(WIP, 1:2, 1) = BestCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate);
        Solution(WIP, 1:2, 2) = WorstCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate);
        Solution(WIP, 1:2, 3) = PracticalWorstCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate);
    end

%% Construct Basic Factory Dynamics Plot

    if isempty(varargin) == 1 || (strcmp(varargin{1}, 'PlotsOn') == 1)
        figure('Name','Basic Factory Dynamics')
        subplot(1,2,1)
        hold all
        plot(1:25, Solution(1:25,1,1), 'k*:')
        plot(1:25, Solution(1:25,1,2), 'k*:')
        plot(1:25, Solution(1:25,1,3), 'k*:')
        axis([0 25 0 max([Solution(:,1, 1); Solution(:,1,2); Solution(:,1,3)])])
        xlabel('WIP')
        ylabel('Cycle Time')
        hold off
        subplot(1,2,2)
        hold all
        plot(1:25, Solution(:,2,1), 'k*:')
        plot(1:25, Solution(:,2,2), 'k*:')
        plot(1:25, Solution(:,2,3), 'k*:')
        axis([0 25 0 max([Solution(:,2, 1); Solution(:,2,2); Solution(:,2,3)]) ])
        xlabel('WIP')
        ylabel('Throughput')
        hold off
    end
end

function solution = BestCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate)
%Calculate the Best Case Performance of System described by its WIP,
%Critical WIP, Raw Process Time, and Bottleneck Rate.

%ATTRIBUTION:
% Section 7.3.1 in Hopp & Spearman, Factory Physics, 1996 (edition 1).
    
    if WIP <= CriticalWIP
        CTbest = RawProcessTime;
        THbest = WIP/RawProcessTime;
    else
        CTbest = WIP/BottleneckRate;
        THbest = BottleneckRate;
    end
    
    solution = [CTbest, THbest];

end

function  solution = WorstCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate)
%Calculate the Worst Case Performance of System described by its WIP,
%Critical WIP, Raw Process Time, and Bottleneck Rate.

%ATTRIBUTION:
% Section 7.3.3 in Hopp & Spearman, Factory Physics, 1996 (edition 1).
    
    CTworst = WIP*RawProcessTime;
    THworst = 1/RawProcessTime;
    
    solution = [CTworst, THworst];

end

function solution = PracticalWorstCasePerformance(WIP, CriticalWIP, RawProcessTime, BottleneckRate)
%Calculate the Practical Worst Case Performance of System described by its WIP,
%Critical WIP, Raw Process Time, and Bottleneck Rate.

%ATTRIBUTION:
% Section 7.3.3 in Hopp & Spearman, Factory Physics, 1996 (edition 1).

    CTpwc = RawProcessTime + (WIP-1)/BottleneckRate;
    THpwc = (WIP/(CriticalWIP + WIP-1))*BottleneckRate;
    
    solution = [CTpwc, THpwc];
end


