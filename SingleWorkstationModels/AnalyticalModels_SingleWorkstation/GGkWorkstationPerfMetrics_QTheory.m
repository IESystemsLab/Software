function [ WIP_mean, CT_mean, TH_mean, WIPq_mean, CTq_mean, Util_mean ] = GGkWorkstationPerfMetrics_QTheory( ...
    InterarrivalTime_mean, InterarrivalTime_variance, ...
    ProcessingTime_mean, ProcessingTime_variance, k )
% A G/G/k workstation consists of two serially-arranged components:
% (1) A single FIFO queue with infinite capacity, followed by 
% (2) k parallel machines/ servers/ processors, which can together process at most k jobs/ parts/ entities at any time.
% (This is the same structure as an M/M/k workstation; the difference is relaxing the interarrival and processing time distribution types.)
%
% ASSUMPTIONS:
% - No specific distribution types are assumed for interarrival or processing times; all that must be known is mean and variance
% - The processing time mean is strictly less than the interarrival time mean (for a stable system)
% - The processing and interarrival times use consistent units.  Computations within this function are units-agnostic, and 
%	it is the user's burden to mind time's units and make them consistent between the input parameters.
%
% INPUTS:
% - InterarrivalTime_mean:  The mean of interarrival times.
% - InterarrivalTime_variance:  The variance of interarrival times.
% - ProcessingTime_mean:  The mean of processing times.
% - ProcessingTime_variance:  The variance of processing times.
% - k:  The number of parallel machines/ servers/ processors in the single-queue system.
%
% OUTPUTS:
% - WIP_mean (Work-In-Process):  The average inventory between the input and output of the queueing system.
% - CT_mean (Cycle Time):  The average time a job/ part/ entity spends in the queueing system from entry to exit.
% - TH_mean (Throughput):  The average output of the queueing system, per unit time.
% - WIPq_mean:  The average inventory in only the queue, and not in-process.
% - CTq_mean:  The average time a job/ part/ entity spends in only the queue, and not in-process.
% - Util_mean:  The average utilization of the k machines/ servers/ processors, defined as the
%	summed time each is busy divided by k * total time.
%
% ATTRIBUTION:  Equations (8.13), (8.14-8.16), (8.27) in Hopp & Spearman, Factory Physics, 1996 (edition 1).
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

if length(k)>1 && (length(InterarrivalTime_mean)>1 || length(ProcessingTime_mean)>1)
    error('This function can support vectorization for either the Interarrival and Processing times, or the number of servers "k", but not both.');
elseif length(InterarrivalTime_mean) ~= length(InterarrivalTime_variance) ...
		|| length(ProcessingTime_mean) ~= length(ProcessingTime_variance)
	error('If vectorizing either the Interarrival or Processing times, same-length vectors are needed for mean and variance.');
end
arrivalRate = 1 ./ InterarrivalTime_mean;
processRate = k ./ ProcessingTime_mean;
if any((processRate - arrivalRate) <= 0)
    error('At least one pair of values in vectors (InterarrivalTime_mean, ProcessingTime_mean) yields an unstable system.')
end
Util_mean = arrivalRate .* ProcessingTime_mean ./ k;  %(8.13)
SCVarrival = InterarrivalTime_variance ./ (InterarrivalTime_mean.^2);
SCVprocess = ProcessingTime_variance ./ (ProcessingTime_mean.^2);

CTq_mean = (SCVarrival+SCVprocess)/2 .* Util_mean.^(sqrt(2.*(k+1))-1) ./ (k.*(1-Util_mean)) .* ProcessingTime_mean;  %(8.27) THIS IS AN APPROXIMATION.
WIPq_mean = arrivalRate .* CTq_mean;  %(8.16)
CT_mean = CTq_mean + ProcessingTime_mean;  %(8.14)
TH_mean = arrivalRate;  %In a serial line without yield loss or rework, TH = arrivalRate at every workstation.
WIP_mean = TH_mean .* CT_mean;  %Little's Law