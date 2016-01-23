function [ WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean ] = ...
	MM1WorkstationPerfMetrics_QTheory( InterarrivalTime_mean, ProcessingTime_mean )
% An M/M/1 queue consists of two serially-arranged components:  
% (1) A single FIFO queue with infinite capacity, followed by 
% (2) A single machine/ server/ processor, which can process at most one job/ part/ entity at any time.

% ASSUMPTIONS:
% - Exponentially-distributed interarrival times
% - Exponentially-distributed processing time
% - The processing time mean is strictly less than the interarrival time mean (for a stable system)
% - The processing and interarrival times use consistent units.  Computations within this function are units-agnostic, and 
%	it is the user's burden to mind time's units and make them consistent between the input parameters.
%
% INPUTS:
% - InterarrivalTime_mean:  Interarrival times are exponentially distributed; this is the mean (and standard deviation) of that distribution.
% - ProcessingTime_mean:  Processing times are exponentially distributed; this is the mean (and standard deviation) of that distribution.
%
% OUTPUTS:
% - WIP_mean (Work-In-Process):  The average inventory between the input and output of the queueing system.
% - CT_mean (Cycle Time):  The average time a job/ part/ entity spends in the queueing system from entry to exit.
% - TH_mean (Throughput):  The average output of the queueing system, per unit time.
% - WIPq_mean:  The average inventory in only the queue, and not in-process.
% - CTq_mean:  The average time a job/ part/ entity spends in only the queue, and not in-process.
% - Util_mean:  The average utilization of the machine/ server/ processor, defined as the fraction of time it is busy.
%
% ATTRIBUTION:  Equations (8.13), (8.20-8.23) in Hopp & Spearman, Factory Physics, 1996 (edition 1).
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

arrivalRate = 1 ./ InterarrivalTime_mean;
processRate = 1 ./ ProcessingTime_mean;
if any((processRate - arrivalRate) <= 0)
    error('At least one pair of values in vectors (InterarrivalTime_mean, ProcessingTime_mean) yields an unstable system.')
end
Util_mean = arrivalRate ./ processRate;  %(8.13)

WIP_mean = Util_mean ./ (1 - Util_mean);  %(8.20)
CT_mean = ProcessingTime_mean  ./ (1 - Util_mean);  %(8.21)
TH_mean = WIP_mean ./ CT_mean;  %Little's Law
WIPq_mean = Util_mean.^2 ./ (1 - Util_mean);  %(8.22)
CTq_mean = ProcessingTime_mean .* Util_mean ./ (1 - Util_mean);  %(8.23)