%FUNCTION NAME:
%   plot_discrete_sc_mat
%
% DESCRIPTION:
%   Visualise a discrete structural‑connectivity matrix.
%
% Inputs
%   discrete_sc   – N×N double, structural‑connectivity weights.
%   sbci_parc     – struct array with field .atlas (char or 1‑cell char).
%   atlas_index   – scalar index identifying the current atlas in sbci_parc.
%
% Optional name‑value pairs
%   'Scale' (double, default 1e7)     – multiplicative factor before log.
%   'CLim'  (1×2 double, default [0 3.5]) – colour‑axis limits.
%   'Title' (char)                    – custom figure title.
%
% Output
%   fig - (figure) Handle to the generated figure
%   Side effects: figure
%
function hFig = plot_discrete_sc_mat(discrete_sc, sbci_parc, atlas_index, varargin)
p = inputParser;
p.addParameter('Scale', 10^7,  @(x) isnumeric(x) && isscalar(x) && x > 0);
p.addParameter('CLim',  [0 3.5], @(x) isnumeric(x) && numel(x)==2);
p.addParameter('Title', '',      @(x) ischar(x)   || isstring(x));
p.parse(varargin{:});
scaleFactor = p.Results.Scale;
clims       = p.Results.CLim;
customTitle = p.Results.Title;

atlasField = sbci_parc(atlas_index).atlas;
if iscell(atlasField)
    atlasName = atlasField{1};
else
    atlasName = atlasField;
end

if isempty(customTitle)
    plotTitle = sprintf('Input Discrete SC (%s)', atlasName);
else
    plotTitle = char(customTitle);
end

hFig = figure('Color', 'w');           
imagesc(log((discrete_sc*scaleFactor) + 1))
axis square;
daspect([1 1 1]);
set(gca, 'CLim', clims);
colorbar();
title(plotTitle, 'Interpreter', 'none');

end
