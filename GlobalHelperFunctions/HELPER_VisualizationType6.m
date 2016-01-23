function [] = HELPER_VisualizationType6( ...
	CostPerSatDmd_Total, CostPerSatDmd_Inventory, CostPerSatDmd_Backorder, CostPerSatDmd_Production, ...
	FillRate, BackorderSamples, ...
	xvals, xvalsLabel, textLabel, sharedTitle, varargin )
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


%% Pre-process BackorderSamples
% Expected Input:  A cell array of different-length vectors
% Output:  A matrix, with each vector in the cell array mapped to a column

%Compute minLength
nCols = length(BackorderSamples);
for ii = 1 : nCols
	if ii == 1
		minLength = length(BackorderSamples{ii});
	else
		if length(BackorderSamples{ii}) < minLength
			minLength = length(BackorderSamples{ii});
		end
	end
end

%Create a multi-column matrix
nBackorders = zeros(minLength, nCols);
for ii = 1 : nCols
	nRows = length(BackorderSamples{ii});
	nBackorders(:,ii) = BackorderSamples{ii}(nRows-minLength+1 : end);
	%Some samples are lost in this operation, but it's a tradeoff I'm willing to make so that the
	%cell array's vectors are equally-dimensioned and can be combined into a rectangular matrix
end


%% Visualize Costs and Fill Rate
f1 = figure;
pOld = get(f1, 'Position');
set(f1, 'Position', [pOld(1) pOld(2)-200 pOld(3) pOld(4)+200]);  %[left bottom width height]

%
subplot(3,1,1), hold on, box off;
a1 = gca;
plot(xvals, CostPerSatDmd_Total, 'k');
text(xvals(1), CostPerSatDmd_Total(1), 'Total Cost', ...
	'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', 'k');

plot(xvals, CostPerSatDmd_Inventory, 'r--');
text(xvals(1), CostPerSatDmd_Inventory(1), 'Inventory Cost', ...
	'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', 'r');

plot(xvals, CostPerSatDmd_Backorder, 'g--');
text(xvals(1), CostPerSatDmd_Backorder(1), 'Backorder Cost', ...
	'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', 'g');

plot(xvals, CostPerSatDmd_Production, 'b--');
text(xvals(1), CostPerSatDmd_Production(1), 'Production Cost', ...
	'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'Color', 'b');
xlabel(xvalsLabel);
ylabel('Costs per satisfied demand');
title(sharedTitle);

%
subplot(3,1,2), hold on, box off;
a2 = gca;
plot(xvals, FillRate);
xlabel(xvalsLabel);
ylabel('Fill Rate (%)');

%
subplot(3,1,3), hold on, box off;
a3 = gca;
boxplot(nBackorders)
box off, set(a3, 'xticklabel', {''});
xlabel('(Boxplot: red line is median and box edges are 25th and 75th percentiles)');
ylabel('Backorder Level');

% Adjust subplots' space utilization
p1 = get(a1, 'Position');
set(a1, 'Position', [p1(1) 0.58 p1(3) 0.36]);  %[left bottom width height]
p2 = get(a2, 'Position');
set(a2, 'Position', [p2(1) 0.36 p2(3) 0.14]);
p3 = get(a3, 'Position');
set(a3, 'Position', [p3(1) 0.08 p3(3) 0.21]);


%% Visualize Total Cost versus Fill Rate tradeoff

%Pre-Process:  varargin => More complex point labeling
if ~isempty(varargin)
	cellArrayOfLabels = varargin{1};
	cellArrayOfValues = varargin{2};
	if length(cellArrayOfLabels) ~= length(cellArrayOfValues)
		error('Invalid varargin');
	end
end

%Plot
figure, hold on, box off;
plot(FillRate, CostPerSatDmd_Total)

%Label Points
for kk = 1 : length(xvals)
	%The labeling of points can get a bit complex ... simplify this?
	if ~isempty(varargin)
		ptLabel = '';
		for zz = 1 : length(cellArrayOfLabels)
			if zz ~= 1
				ptLabel = [ptLabel ', '];
			end
			ptLabel = [ptLabel cellArrayOfLabels{zz} '=' num2str(cellArrayOfValues{zz}(kk))];
		end
	else
		ptLabel = [textLabel '=' num2str(xvals(kk))];
	end
	%Finally:  Label the point
	text(FillRate(kk), CostPerSatDmd_Total(kk), ptLabel, ...
		'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom')
end

%Annotate Axes
xlabel('Fill Rate (the fraction of demand filled without delay)');
ylabel('Total Cost per satisfied demand');
title(sharedTitle, 'FontWeight', 'Normal');