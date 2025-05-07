clear all;
close all;

% Set the ICO level for high-resolution brain surface analysis. Default is 'ico4', 
% which uses a refined triangular mesh with 5,120 faces suitable for neuroimaging.
% This is a option in SBCI Pipeline.
icoLevel = 'ico4';
% Add required directories to the path for the initial setup.
addpath('./plot');
addpath('./example_data/fsaverage_label/');
addpath('./transformation');

% Load average data and surface from the SBCI pipeline.
[sbci_parc, sbci_mapping, ~] = load_sbci_data('example_data/fsaverage_label', icoLevel);
sbci_surf = load_sbci_surface('example_data/fsaverage_label');

% Load Discrete SC matrices.
load('discrete_sc.mat');

% Set and Display the atlas currently in use.
% atlas name can be found by `sbci_parc.atlas`
atlas_index = 44; % Example using 'aparc' atlas
disp(fprintf('The atlas current use is: %s', sbci_parc(atlas_index).atlas{1}));
target_index = 33; % Example using 'Schaefer2018_300' atlas
disp(fprintf('The target atlas is: %s', sbci_parc(target_index).atlas{1}));

% Define indices for regions to exclude from analysis (non-meaningful brain regions).
% Specific ROI Names can be found by `sbci_parc.names`
roi_exclusion_index = [1,36]; % Index 1: 'LH_missing', Index 36: 'RH_missing'

% Visualize original Discrete SC matrices.
plot_discrete_sc_mat(discrete_sc, sbci_parc, atlas_index);

% Convert ROI-based discrete matrices to any other target atlas.
bridge_brain_parcellations(discrete_sc, sbci_parc, atlas_index, sbci_mapping, roi_exclusion_index, target_index);
