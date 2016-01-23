function [] = HELPER_VisualizationType7( ...
    xVals, xValsLabel, ...
    yValues, yLabels, ...
    tTitle )
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


%% Pre-Processing
N = length(yValues);

if N ~= length(yLabels)
    error('Length of inputs "yValues" and "yLabels" must be equal, with one label for each value.');
end

if N <= 2  %1 column
    nColumns = 1;
    figHorizScaling = 0.5;
    subplotWithTitle = 1;
elseif N > 2 && N <= 4  %2 columns
    nColumns = 2;
    figHorizScaling = 1;
    subplotWithTitle = 1;
elseif N > 4 && N <= 6  %3 columns
    nColumns = 3;
    figHorizScaling = 1.5;
    subplotWithTitle = 2;
elseif N > 6 && N <= 8  %4 columns
    nColumns = 4;
    figHorizScaling = 2;
    subplotWithTitle = 2;
elseif N > 8 && N <= 10  %5 columns
    nColumns = 5;
    figHorizScaling = 2.5;
    subplotWithTitle = 3;
end


%% Visualize
f1 = figure;
p = get(f1, 'Position');
set(f1, 'Position', [p(1), p(2), p(3)*figHorizScaling, p(4)]);  %[left bottom width height]

for ii = 1 : N
	subplot(2, nColumns, ii)
	plot(xVals, yValues{ii});
	box off, axis tight;
	xlabel(xValsLabel);
	ylabel(yLabels{ii});
	if ii == subplotWithTitle
        title(tTitle, 'FontWeight', 'normal');
    end
end