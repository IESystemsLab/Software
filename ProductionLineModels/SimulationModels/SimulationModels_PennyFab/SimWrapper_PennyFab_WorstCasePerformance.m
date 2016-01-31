function Solution = SimWrapper_PennyFab_WorstCasePerformance(ParallelMachineCount, ProcessingTime, varargin)
%Simulates the Worst Case Performance of a Tandem Production Line 

%Solution = PennyFabScript_WorstCasePerformance([1 2 6 2], [2 5 10 3], {'PlotsOn'})

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
% Inspired by Section 7.3.2 of Hopp & Spearman, Factory Physics, 1996 (edition 1).

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


%% Set up the Simulation Model According to the Input Parameters
    Model = 'PennyFab_Deterministic';
    open(Model);
    setProcessNodeParameters(Model, ParallelMachineCount, ProcessingTime);
        

%% Execute the Simulation
%For CONWIP values of 1 to 25, simulate the Penny Fab
    for W = 1:25
        setProcessNodeParameters(Model, ParallelMachineCount, W*ProcessingTime);
               

        %save_system(Model);
        set_param(strcat(Model, '/EntityCount'), 'const', '500');
        simOut = sim(Model, 'StopTime', '100000');
        Solution(W,2) = getCycleTime(simOut);
        Solution(W,1) = W;
        Solution(W,3) = W*getThroughput(simOut);
    end
    
    setProcessNodeParameters(Model, ParallelMachineCount, ProcessingTime);

%% Construct Basic Factory Dynamics Plot

    if isempty(varargin) == 1 || (strcmp(varargin{1}, 'PlotsOn') == 1)
        figure('Name','Worst Case Performance')
        subplot(1,2,1)
        plot(Solution(:,1), Solution(:,3), 'k*:')
        axis([0 1.1*max(Solution(:,1)) 0 1.1*max(Solution(:,3))])
        xlabel('WIP')
        ylabel('Throughput')
        subplot(1,2,2)
        plot(Solution(:,1), Solution(:,2), 'k*:')
        axis([0 1.1*max(Solution(:,1)) 0 1.1*max(Solution(:,2))])
        xlabel('WIP')
        ylabel('Cycle Time')
    end

end


