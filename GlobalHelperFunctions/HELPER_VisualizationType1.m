function [] = HELPER_VisualizationType1( ...
	xvals, xvalsLabel, ...
	yvals1, yvals1Label, ...
	yvals2, yvals2Label, ...
	yvals3, yvals3Label, ...
	nSubplot, eachSubplotSharedTitle)
% This helper function is a bit of a hack ... rather than copy & paste several copies of the same
% visualization code, I extracted it here and generalized a bit.  However, I didn't really finish
% the generalization task (look at the function's arguments), nor think more broadly about different
% fundamental types of visualizations.
%
% The bigger picture:  In the demos we've written, we're observing that code to visualize results
% frequently comprises a large fraction of total lines of code - sometimes even a majority.  An
% effort (which we've barely started) would look for patterns in visualizations generated and most
% appreciated and helpful to users, and then write some generic functions to generate those
% visualizations.  The 'HELPER_VisualizationType<>' functions are a primitive first effort to
% separate the "Here's what we're trying to demonstrate" code from low-level figure manipulations.


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
subplot(1,2,nSubplot); hold on; box off;

%One curve for Work-In-Process
plot(xvals, yvals1, 'r:');
text(xvals(end), yvals1(end), yvals1Label, 'HorizontalAlignment', 'right');

%Another curve for Cycle Time
plot(xvals, yvals2, 'g--');
text(xvals(end), yvals2(end), yvals2Label, 'HorizontalAlignment', 'right');

%Another curve for Throughput
plot(xvals, yvals3, 'b-.');
text(xvals(end), yvals3(end), yvals3Label, 'HorizontalAlignment', 'right');

xlabel(xvalsLabel);
title([eachSubplotSharedTitle ', k=' num2str(nSubplot)], 'FontWeight', 'normal')

%Fix y-axis scaling
yLim = get(gca, 'YLim');
yLim(1) = 0;
set(gca, 'YLim', yLim);