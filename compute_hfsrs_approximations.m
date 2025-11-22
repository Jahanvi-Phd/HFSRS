function [lower_approx, upper_approx, boundary_region] = compute_hfsrs_approximations(data, target_set, beta)
% COMPUTE_HFSRS_APPROXIMATIONS Computes HFSRS lower/upper approximations and boundary region.
%
% Inputs:
%   data       - Table containing PV fault detection dataset
%   target_set - Indices of target modules (e.g., faulty modules)
%   beta       - β-threshold (e.g., 0.65)
%
% Outputs:
%   lower_approx    - Indices of modules fully included in target set
%   upper_approx    - Indices of modules possibly included in target set
%   boundary_region - Indices of modules in the boundary (upper - lower)

    % Initialize sets
    lower_approx = [];
    upper_approx = [];

    % Indicators to check (HFE columns)
    indicators = ["Voltage_Drop_HFE", "Temp_Rise_HFE", "Irradiance_Loss_HFE"];

    % Loop through dataset
    for i = 1:height(data)
        satisfies_all = true;
        satisfies_any = false;

        % Check each indicator
        for ind = indicators
            hfe_values = parse_hfe(data.(ind)(i));

            % β-condition
            if max(hfe_values) >= beta
                satisfies_any = true;
            else
                satisfies_all = false;
            end
        end

        % Lower approximation: must satisfy all indicators and be in target set
        if satisfies_all && ismember(i, target_set)
            lower_approx(end+1) = i;
        end

        % Upper approximation: satisfies at least one indicator and overlaps target set
        if satisfies_any && ismember(i, target_set)
            upper_approx(end+1) = i;
        end
    end

    % Boundary region = upper - lower
    boundary_region = setdiff(upper_approx, lower_approx);
end