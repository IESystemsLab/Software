%% Purpose
% This is a mechanical script written to demonstrate sweeping over two variables, plus replications,
% and then visualizing the results in a surface plot.  It may be somewhat interesting that one of 
% the arbitrarily-chosen swept variables is the single workstation's queue capacity, because any 
% finite value acts as a WIP cap.  Any of the performance measures [WIP, CT, TH, U] can be plotted
% against the two swept variables, and cycle time is the arbitrary choice at the time of writing.


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


%% Input Parameters
iaDistrib = 'normal';
iaMean = 100;
iaVar = eps;

procDistrib = 'lognormal';
procMeans = 70 : 5 : 95;
procVars = procMeans.^2;

queueCapacity = 6: -1 : 1;  %Sweep over this
numberOfServers = 1;

nReps = 10;
nDepartBeforeSimStop = 2000;


%% Check File Dependencies
f1 = 'SimWrapper_GGkWorkstation.m';
HELPER_ValidateFileDependencies({f1});


%% Simulate
m = length(procMeans);
n = length(queueCapacity);
WIP_reps = zeros(nReps, 1);
CT_reps = zeros(nReps, 1);
TH_reps = zeros(nReps, 1);
U_reps = zeros(nReps, 1);
WIPmeans = zeros(m,n);
CTmeans = zeros(m,n);
THmeans = zeros(m,n);
Umeans = zeros(m,n);

%Outer loop for sweep variable
for ii = 1 : m
    
    %Outer loop for sweep variable
	for jj = 1 : n
        
        %Inner loop for replications
        for kk = 1 : nReps
            [WIP_reps(ii), CT_reps(ii), TH_reps(ii), U_reps(ii)] = SimWrapper_GGkWorkstation( ...
                iaDistrib, iaMean, iaVar, ...
                procDistrib, procMeans(ii), procVars(ii), ...
                queueCapacity(jj), numberOfServers, nDepartBeforeSimStop );
        end
        
        %Average over all replications
        WIPmeans(ii,jj) = mean(WIP_reps);
        CTmeans(ii,jj) = mean(CT_reps);
        THmeans(ii,jj) = mean(TH_reps);
        Umeans(ii,jj) = mean(U_reps);
	end
end


%% Visualize
figure;
surf(repmat(procMeans', 1, n), ...
	 repmat(queueCapacity, m, 1), ...
	 CTmeans);
xlabel('Mean Processing Time');
ylabel('Queue Capacity');
zlabel('Cycle Time');
