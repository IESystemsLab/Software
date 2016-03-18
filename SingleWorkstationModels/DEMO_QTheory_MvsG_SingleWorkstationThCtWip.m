%% Purpose
% The following demo uses the closed-form queueing theory approximations from Hopp & Spearman, 
% chapter 8, and compares the Markovian case with the General case.  The expected result is that if 
% means and variances for Inter-Arrival times and Processing times have SCVs near one, then the G/G 
% case should match the M/M case.  If at least one SCV is far from one, then the cases should 
% diverge.
%
% Parameters which can be changed by a user include interarrival time mean, processing time mean,
% and the range of SCVs to test in the General case (Markovian -> SCV=1).


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


%% Input Variables
InterarrivalTime_mean = 10;
ProcessingTime_mean = 9.9;
SCVs = 0.1 : 0.1 : 2;  %Use the same SCVs for both inter-arrivals and processing


%% Check File Dependencies
f1 = 'MM1WorkstationPerfMetrics_QTheory.m';
f2 = 'GG1WorkstationPerfMetrics_QTheory.m';
f3 = 'MMkWorkstationPerfMetrics_QTheory.m';
f4 = 'GGkWorkstationPerfMetrics_QTheory.m';
f5 = 'HELPER_VisualizationType3.m';
HELPER_ValidateFileDependencies({f1, f2, f3, f4, f5});


%% Compare
n = length(SCVs);
InterarrivalTime_var = 1 * InterarrivalTime_mean^2;  %Markovian case:  SCVia = 1
InterarrivalTime_vars = SCVs * InterarrivalTime_mean^2;  %Variable case
ProcessingTime_var = 1 * ProcessingTime_mean^2;  %Markovian case:  SCVp = 1
ProcessingTime_vars = SCVs * ProcessingTime_mean^2;  %Variable case
InterarrivalTime_means = InterarrivalTime_mean * ones(1,n);
ProcessingTime_means = ProcessingTime_mean * ones(1,n);

%M/M/1
[WIP_mean_MM1, CT_mean_MM1, TH_mean_MM1] = MM1WorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, ProcessingTime_mean );
%G/G/1
[WIP_mean_GG1, CT_mean_GG1, TH_mean_GG1] = GG1WorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_means, InterarrivalTime_vars, ...
    ProcessingTime_means, ProcessingTime_vars );
%M/G/1
[WIP_mean_MG1, CT_mean_MG1, TH_mean_MG1] = GG1WorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, InterarrivalTime_var, ...
    ProcessingTime_means, ProcessingTime_vars );
%G/M/1
[WIP_mean_GM1, CT_mean_GM1, TH_mean_GM1] = GG1WorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_means, InterarrivalTime_vars, ...
    ProcessingTime_mean, ProcessingTime_var );


%% Visualize
HELPER_VisualizationType3(SCVs, 'SCV of Inter-Arrivals or Processing', ...
    WIP_mean_GG1, WIP_mean_MG1, WIP_mean_GM1, 1.0, WIP_mean_MM1, 'Work-In-Process', ...
    CT_mean_GG1, CT_mean_MG1, CT_mean_GM1, 1.0, CT_mean_MM1, 'Cycle Time', ...
    TH_mean_GG1, TH_mean_MG1, TH_mean_GM1, 1.0, TH_mean_MM1, 'Throughput', ...
    'G/G/1', 'M/G/1', 'G/M/1', 'M/M/1' );


%% Compare M/M/k with G/G/k
k = 1+ceil(rand*5);  %Use a random k

%M/M/k
[WIP_mean_MMk, CT_mean_MMk, TH_mean_MMk] = MMkWorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, ProcessingTime_mean, ...
    k );
%G/G/k
[WIP_mean_GGk, CT_mean_GGk, TH_mean_GGk] = GGkWorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_means, InterarrivalTime_vars, ...
    ProcessingTime_means, ProcessingTime_vars, ...
    k );
%M/G/k
[WIP_mean_MGk, CT_mean_MGk, TH_mean_MGk] = GGkWorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, InterarrivalTime_var, ...
    ProcessingTime_means, ProcessingTime_vars, ...
    k );
%G/M/k
[WIP_mean_GMk, CT_mean_GMk, TH_mean_GMk] = GGkWorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_means, InterarrivalTime_vars, ...
    ProcessingTime_mean, ProcessingTime_var, ...
    k );


%% Visualize
HELPER_VisualizationType3(SCVs, 'SCV of Inter-Arrivals or Processing', ...
    WIP_mean_GGk, WIP_mean_MGk, WIP_mean_GMk, 1.0, WIP_mean_MMk, 'Work-In-Process', ...
    CT_mean_GGk, CT_mean_MGk, CT_mean_GMk, 1.0, CT_mean_MMk, 'Cycle Time', ...
    TH_mean_GGk, TH_mean_MGk, TH_mean_GMk, 1.0, TH_mean_MMk, 'Throughput', ...
    ['G/G/' num2str(k)], ['M/G/' num2str(k)], ['G/M/' num2str(k)], ['M/M/' num2str(k)] );
