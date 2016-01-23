function [ RStar ] = Inventory_BaseStock_ComputeRStar( ReplenishLeadTimeYears, ...
	Demand_distrib, DemandUnitsPerYear_mean, Demand_SCV, ...
	UnitAnnualHoldingCost_H, UnitAnnualBackorderCost_B )
% For the Base Stock inventory model, this function computes an optimal base stock level R.  The
% formula implemented for the optimal solution is derived in Hopp & Spearman section 2.4.2 (ed. 2).
%
% ASSUMPTIONS
% - This currently only works for *deterministic* replenishment lead times
% - The demand distribution is *during replenishment lead time*.  This is why ReplenishLeadTimeYears
% is an input, to adjust DemandUnitsPerYear_mean to demand units during replenishment lead time.


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


%% Compute
DemandUnitsPerLeadTime_mean = DemandUnitsPerYear_mean * ReplenishLeadTimeYears;
pd = HELPER_GetProbDistObj(Demand_distrib, DemandUnitsPerLeadTime_mean, Demand_SCV);
criticalRatio = UnitAnnualBackorderCost_B / (UnitAnnualBackorderCost_B + UnitAnnualHoldingCost_H);
RStar = icdf(pd, criticalRatio);
RStar = round(RStar);