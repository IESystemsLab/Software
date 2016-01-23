function [ ] = HELPER_SetDistributionParameters( blockPathOrHandle, distribType, paramNamesAndValues )
% This function goes hand-in-hand with HELPER_DistribParamsFromMeanAndVar.  That function returns a
% structure of distribution-specific parameters to realize a particular mean and variance, and this
% function reaches into a simulation model to batch-set them.
%
% Before this function I would reach into a simulation model to set distribution-specific parameters
% one-by-one, but Simulink performs validation after each setting of a parameter, which can lead to
% errors.  A frequent culprit was triangular, for example trying to set a new mininum which is
% greater than the old mode or maximum will throw an error.  This function was created to set all
% distribution-specific parameters at once, eliminating one-by-one validation errors.
%
% p.s. It's a hack in need of generalization - at the time of writing it will fail for >5 parameters


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


%%
fields = fieldnames(paramNamesAndValues);
nParams = length(fields);

%How to handle this in general?  Perhaps construct a long string of (name, value) pairs and then
%call EVAL?
set_param(blockPathOrHandle, 'Distribution', distribType);
if nParams == 1
	set_param(blockPathOrHandle, ...
		fields{1}, num2str(paramNamesAndValues.(fields{1})));
	
elseif nParams == 2
	set_param(blockPathOrHandle, ...
		fields{1}, num2str(paramNamesAndValues.(fields{1})), ...
		fields{2}, num2str(paramNamesAndValues.(fields{2})));
	
elseif nParams == 3
	set_param(blockPathOrHandle, ...
		fields{1}, num2str(paramNamesAndValues.(fields{1})), ...
		fields{2}, num2str(paramNamesAndValues.(fields{2})), ...
		fields{3}, num2str(paramNamesAndValues.(fields{3})));
	
elseif nParams == 4
	set_param(blockPathOrHandle, ...
		fields{1}, num2str(paramNamesAndValues.(fields{1})), ...
		fields{2}, num2str(paramNamesAndValues.(fields{2})), ...
		fields{3}, num2str(paramNamesAndValues.(fields{3})), ...
		fields{4}, num2str(paramNamesAndValues.(fields{4})));
	
elseif nParams == 5
	set_param(blockPathOrHandle, ...
		fields{1}, num2str(paramNamesAndValues.(fields{1})), ...
		fields{2}, num2str(paramNamesAndValues.(fields{2})), ...
		fields{3}, num2str(paramNamesAndValues.(fields{3})), ...
		fields{4}, num2str(paramNamesAndValues.(fields{4})), ...
		fields{5}, num2str(paramNamesAndValues.(fields{5})));
end