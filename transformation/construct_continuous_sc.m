
% MATLAB R2018a
%
% FUNCTION NAME:
%   construct_continuous_sc
%
% DESCRIPTION:
%   Approximates the continuous high-resolution SC matrix from a discrete atlas ROI-level SC matrix.
%
% INPUT:
%   discrete_sc - (matrix) Discrete ROI-level connectivity data
%   parc - (struct) Parcellation
%   varargin - Optional arguments:
%       roi_mask - (vector) A vector of label IDs for ROIs to exclude
%
% OUTPUT:
%   sc_continuous - (matrix) Approximated continuous connectivity data
%
% ASSUMPTIONS AND LIMITATIONS:
%   The approximation assumes uniform connectivity within ROI pairs and cannot recover fine-grained details lost during aggregation.
%
% USAGE EXAMPLE:
%   sc_continuous = construct_continuous_sc(discrete_sc, sbci_parc, 'roi_mask', roi_exclusion_index);
function [result] = construct_continuous_sc(discrete_sc, sbci_parc, sbci_map, varargin)
    % Input Parser for optional arguments
    p = inputParser;
    addParameter(p, 'roi_mask', [], @isnumeric);     % Optional ROI mask to exclude specific ROIs
    addParameter(p, 'merge_lr', false, @islogical);  % Optional: merge left-right hemisphere
    parse(p, varargin{:});
    params = p.Results;
    
    was_triangular = false;

    vertex_labels = sbci_parc.labels;   % Vertices, each assigned a label from 1 to n_rois
    names = string(sbci_parc.names);    % ROI names
    
    % Determine ROI indices based on atlas type (standard or CoCoNest)
    if contains(sbci_parc.atlas{1}, 'CoCoNest') || contains(sbci_parc.atlas{1}, 'Gordon')
        % Extract numerical part from 'Parcel_xxxx' in ROI names for CoCoNest
        roi_indices = arrayfun(@(name) str2double(regexp(name{1}, '\d+', 'match', 'once')), names);
        % Replace NaN values with 4 for any non-numeric or missing values in roi_indices
        roi_indices(isnan(roi_indices)) = 4;
    else
        % For standard atlases with consecutive indices, use a sequential list
        roi_indices = 1:length(names);
    end

    n_rois = length(roi_indices);  % Number of ROIs based on atlas type

    % Adjust the Discrete SC Matrix for excluded ROIs
    if ~isempty(params.roi_mask)
        include_mask = ~ismember(roi_indices, params.roi_mask);  % Logical mask for included ROIs
    else
        include_mask = true(1, n_rois);  % Include all ROIs if no mask is provided
    end

    % Find the indices of the included ROIs
    included_rois_index = roi_indices(include_mask);  % Indices of the included ROIs

    % Expand the discrete SC matrix to a full n_rois x n_rois matrix by adding zeros for excluded ROIs
    full_discrete_sc = zeros(n_rois, n_rois);  % Initialize matrix based on number of ROIs
    full_discrete_sc(include_mask, include_mask) = discrete_sc;

    % If merge_lr is set to true, merge left and right hemisphere ROIs (optional)
    if params.merge_lr == true
        names = regexprep(names,{'^LH_','^RH_'},{'',''});
        
        [~,~,idx] = unique(names, 'stable');
        vertex_labels = int64(idx(labels)');
    end

    % Initialize the full continuous SC matrix
    n_vertices = length(vertex_labels); 
    result_n = zeros(n_vertices, n_vertices);  % Initialize the constructed continuous SC matrix
    
    % Precompute the number of vertices each ROI represents (areas)
    areas = arrayfun(@(t) nnz(sbci_map.map(2,:) == t), unique(sbci_map.map(2,:)));
    
    % Loop through each pair of ROIs to map the SC values to the continuous matrix
    for i = 1:length(included_rois_index)
        roi_index_i = included_rois_index(i);  % Get current ROI index from included list

        % Find the indices of the vertices that belong to the i-th ROI
        idx_i = find(vertex_labels == roi_index_i);  % Indices of vertices in ROI i
        area_a = areas(idx_i);

        for j = i:length(included_rois_index)
            roi_index_j = included_rois_index(j);  % Get current ROI index from included list
            idx_j = find(vertex_labels == roi_index_j);  % Indices of vertices in ROI j
            area_b = areas(idx_j);
            
            area_ab = area_a' * area_b;

            % Retrieve the SC value from the full discrete SC matrix
            sc_value = full_discrete_sc(i, j);

            % Scale the SC value by the combined areas (to ensure larger ROIs contribute more
            scaled_sc_value = sc_value.*(sum(area_a) * sum(area_b))* area_ab/sum(sum(area_ab.^2)); 

            result_n(idx_i,idx_j) = scaled_sc_value;
            
        end
    end
    if ~was_triangular
        result_n = result_n + result_n';
    end   
    % Final output as the constructed continuous SC matrix
    result = result_n; 
end
