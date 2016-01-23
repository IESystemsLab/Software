function [] = HELPER_VisualizationType3( ...
    xvals, xvalsLabel, ...
    yvals1a, yvals1b, yvals1c, xval1ToCompare, yval1ToCompare, yvals1Label, ...
    yvals2a, yvals2b, yvals2c, xval2ToCompare, yval2ToCompare, yvals2Label, ...
    yvals3a, yvals3b, yvals3c, xval3ToCompare, yval3ToCompare, yvals3Label, ...
    yvalsAText, yvalsBText, yvalsCText, yvalToCompareText )
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
figure;

%WIP
subplot(2,2,1); hold on; box off;
plot(xvals, yvals1a, 'b-', xvals, yvals1b, 'g--', xvals, yvals1c, 'r:');
text(xvals(end), yvals1a(end), yvalsAText, 'HorizontalAlignment', 'right');
text(xvals(end), yvals1b(end), yvalsBText, 'HorizontalAlignment', 'right');
text(xvals(end), yvals1c(end), yvalsCText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
plot(xval1ToCompare, yval1ToCompare, 'k.', 'MarkerSize', 16);
text(xval1ToCompare, yval1ToCompare, yvalToCompareText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
ylabel(yvals1Label);
xlabel(xvalsLabel);

%CT
subplot(2,2,2); hold on; box off;
plot(xvals, yvals2a, 'b-', xvals, yvals2b, 'g--', xvals, yvals2c, 'r:');
text(xvals(end), yvals2a(end), yvalsAText, 'HorizontalAlignment', 'right');
text(xvals(end), yvals2b(end), yvalsBText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
text(xvals(end), yvals2c(end), yvalsCText, 'HorizontalAlignment', 'right');
plot(xval2ToCompare, yval2ToCompare, 'k.', 'MarkerSize', 16);
text(xval2ToCompare, yval2ToCompare, yvalToCompareText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
ylabel(yvals2Label);
xlabel(xvalsLabel);

%TH
subplot(2,2,3); hold on; box off;
plot(xvals, yvals3a, 'b-', xvals, yvals3b, 'g--', xvals, yvals3c, 'r:');
text(xvals(end), yvals3a(end), yvalsAText, 'HorizontalAlignment', 'right');
text(xvals(end), yvals3b(end), yvalsBText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
text(xvals(end), yvals3c(end), yvalsCText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
plot(xval3ToCompare, yval3ToCompare, 'k.', 'MarkerSize', 16);
text(xval3ToCompare, yval3ToCompare, yvalToCompareText, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
ylabel(yvals3Label);
xlabel(xvalsLabel);