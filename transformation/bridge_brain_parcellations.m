% FUNCTION NAME:
%   bridging_brain_parcellations
%
% DESCRIPTION:
%   Visualizes the continuous SC matrix using approxmiation from parcells.
%
% INPUT:
%   sc_discrete   - (matrix) A PxP discrete structural connectivity matrix.
%   parc     - (struct) A struct with parcellation.
%   atlas_num     - The index of the atlas to use for parcellation within sbci_parc.
%   sbci_mapping  - (struct) A structure containing SBCI mapping information.
%   roi_mask_num  - (vector) A vector of label IDs for ROIs to remove.
%
% OUTPUT:
%   A figure displaying the approximated continuous SC matrix with given visualization parameters.
%
% ASSUMPTIONS AND LIMITATIONS:
%   The approximation assumes uniform connectivity within ROI pairs and cannot recover fine-grained details lost during aggregation.
%
% USAGE EXAMPLE:
%   bridge_brain_parcellations(sc_discrete, sbci_parc, atlas_num, sbci_mapping, roi_mask_num,target_num);

function bridge_brain_parcellations(discrete_sc, sbci_parc, atlas_num, sbci_mapping, roi_mask_num, target_num)
    
    % Reconstruct the continuous SC matrix from the discrete SC matric
    sc_continuous = construct_continuous_sc(discrete_sc, sbci_parc(atlas_num), sbci_mapping, 'roi_mask', roi_mask_num);
    % Symmetrize the connectivity matrices & removing diagonal elements.
    sc_continuous = sc_continuous + sc_continuous' - 2*diag(diag(sc_continuous));
    sc_continuous = sc_continuous/sum(sum(sc_continuous));

    % Convert to another target atlas
    tdiscrete_sc = parcellate_sc(sc_continuous, sbci_parc(target_num), sbci_mapping, 'roi_mask', roi_mask_num);
    
    atlas_index = atlas_num;
    target_index = target_num;
  
    plot_sbci_mat(log((sc_continuous*10^7)+1), sbci_parc(atlas_index), 'roi_mask', roi_mask_num, 'figid', 2, 'clim', [0, 3.5]);
    title(['Reversed Continuous SC (' sbci_parc(atlas_index).atlas{1} ')'], 'Interpreter', 'none');

    plot_discrete_sc_mat(tdiscrete_sc, sbci_parc, target_index, ...
         'Title', ['Target Discrete SC (' sbci_parc(target_index).atlas{1} ')'])
end
