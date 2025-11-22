function [coverage_idx, coverage_size] = compute_beta_coverage(data, indicator_type, beta)
% COMPUTE_BETA_COVERAGE Identifies modules satisfying β-coverage for a given fault indicator.
%
% Inputs:
%   data           - Table containing PV fault detection dataset
%   indicator_type - String: 'Voltage_Drop', 'Temp_Rise', or 'Irradiance_Loss'
%   beta           - Threshold value (e.g., 0.65)
%
% Outputs:
%   coverage_idx   - Row indices of modules satisfying β-coverage
%   coverage_size  - Total number of covered modules

    % Construct HFE column name
    hfe_column = indicator_type + "_HFE";

    % Initialize coverage index list
    coverage_idx = [];

    % Loop through each module
    for i = 1:height(data)
        hfe_string = data.(hfe_column)(i);
        hfe_values = parse_hfe(hfe_string);  % Requires parse_hfe.m

        % Check β-coverage condition
        if max(hfe_values) >= beta
            coverage_idx(end+1) = i;
        end
    end

    % Output coverage size
    coverage_size = numel(coverage_idx);
end