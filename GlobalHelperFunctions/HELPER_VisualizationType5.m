function [] = HELPER_VisualizationType5( ...
    xvals, xvalsLabel, ...
    yvals1a, yvals1aText, yvals1b, yvals1bText, ...
    yvals1Label, subplotTitles)
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
nSubplots = size(yvals1a, 2);  %All yvals are expected to be matrices containing multiple curves
if size(yvals1b, 2) ~= nSubplots || length(subplotTitles) ~= nSubplots
    error('Inconsistent input argument dimensions');
end

figure;
for jj = 1 : nSubplots
    subplot(2,2,jj); hold on; box off;  %=> Hard-coded to nSubplots <= 4
    plot(xvals, yvals1a(:,jj), 'b-', xvals, yvals1b(:,jj), 'r--');
    text(xvals(end), yvals1a(end,jj), yvals1aText, 'HorizontalAlignment', 'right');
    text(xvals(end), yvals1b(end,jj), yvals1bText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    title(subplotTitles{jj}, 'FontWeight', 'normal');
    if jj == 3 || jj == 4
        xlabel(xvalsLabel);
    end
    if jj == 1 || jj == 3
        ylabel(yvals1Label);
    end
end