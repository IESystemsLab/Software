function [ SCVdeparture ] = SCVofDepartProcessFromSingleWorkstation_QTheory( SCVarrival, SCVprocess, utilization, k )
% INPUTS:
% - SCVarrival:  The squared coefficient of variation of interarrivals (variance / mean^2)
% - SCVprocess:  The squared coefficient of variation of processing (variance / mean^2)
% - utilization:  Average fraction of time that the workstation is busy (meanArrivalRate * meanProcTime / k)
% - k:  The number of parallel machines/ servers/ processors in the single workstation
%
% OUTPUTS:
% - SCVdeparture:  The squared coefficient of variation of departures from the workstation (variance / mean^2)
%
% ATTRIBUTION:  Equation (8.11-8.12) in Hopp & Spearman, Factory Physics, 1996 (edition 1)
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

if abs(k-1) < eps  %%e.g. k == 1
    SCVdeparture = utilization.^2 .* SCVprocess + (1 - utilization.^2) .* SCVarrival;
else
    SCVdeparture = 1 + (1 - utilization.^2) .* (SCVarrival - 1) + utilization.^2 .* (SCVprocess - 1) ./ sqrt(k);
    %Hopp & Spearman note:  This second equation reduces to the first when k == 1.
end