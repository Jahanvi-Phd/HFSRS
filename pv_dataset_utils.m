% =========================================================================
% MATLAB UTILITY FUNCTIONS FOR PV FAULT DETECTION DATASET
% =========================================================================
%
% This file contains utility functions for loading, analyzing, and
% visualizing the PV fault detection dataset.
%
% FUNCTIONS:
%   - load_pv_dataset()         : Load dataset from CSV
%   - parse_hfe()               : Parse HFE string to array
%   - compute_beta_coverage()   : Compute β-coverage for given threshold
%   - compute_hfsrs_approximations() : Compute HFSRS lower/upper approximations
%   - visualize_dataset()       : Create visualization plots
%   - export_for_hfsrs()        : Export data in HFSRS-compatible format
%
% AUTHOR: Jahanvi, Dinesh Kumar Nishad, Rashmi Singh, Saifullah Khalid
% DATE: November 21, 2025
% LICENSE: CC BY 4.0
%
% =========================================================================

%% FUNCTION: Load PV Dataset
function data = load_pv_dataset(filename)
    % Load PV fault detection dataset from CSV file
    %
    % Usage:
    %   data = load_pv_dataset()  % Uses default filename
    %   data = load_pv_dataset('PV_Fault_Detection_Dataset.csv')
    %
    % Output:
    %   data - MATLAB table containing the dataset

    if nargin < 1
        filename = 'PV_Fault_Detection_Dataset.csv';
    end

    if ~isfile(filename)
        error('Dataset file not found: %s', filename);
    end

    data = readtable(filename, 'TextType', 'string');
    fprintf('✓ Dataset loaded: %d modules, %d columns\n', height(data), width(data));
end

%% FUNCTION: Parse Hesitant Fuzzy Element
function hfe_array = parse_hfe(hfe_string)
    % Parse HFE string to numerical array
    %
    % Usage:
    %   hfe = parse_hfe('{0.250, 0.267, 0.283}')
    %
    % Output:
    %   hfe_array - [0.250, 0.267, 0.283]

    % Remove braces and parse
    hfe_string = char(hfe_string);
    hfe_string = strrep(hfe_string, '{', '');
    hfe_string = strrep(hfe_string, '}', '');
    hfe_array = str2num(hfe_string); %#ok<ST2NM>
end

%% FUNCTION: Compute Beta Coverage
function [coverage_indices, coverage_size] = compute_beta_coverage(data, parameter, beta)
    % Compute β-coverage for a given parameter and threshold
    %
    % Usage:
    %   [indices, size] = compute_beta_coverage(data, 'Voltage_Drop', 0.65)
    %
    % Inputs:
    %   data      - Dataset table
    %   parameter - Parameter name ('Voltage_Drop', 'Temp_Rise', 'Irradiance_Loss')
    %   beta      - Threshold value [0, 1]
    %
    % Outputs:
    %   coverage_indices - Logical array indicating modules in coverage
    %   coverage_size    - Number of modules in coverage

    % Get expert assessment columns
    expert_cols = {sprintf('%s_Expert1', parameter), ...
                   sprintf('%s_Expert2', parameter), ...
                   sprintf('%s_Expert3', parameter)};

    % Extract expert values
    expert_matrix = [data.(expert_cols{1}), ...
                     data.(expert_cols{2}), ...
                     data.(expert_cols{3})];

    % Compute max HFE values (Definition 3.1: max(h_e(x)) >= β)
    max_hfe = max(expert_matrix, [], 2);

    % β-coverage: modules where max(h_e(x)) >= β
    coverage_indices = max_hfe >= beta;
    coverage_size = sum(coverage_indices);

    fprintf('β-Coverage (β=%.2f, %s):\n', beta, parameter);
    fprintf('  Modules in coverage: %d (%.1f%%)\n', ...
            coverage_size, 100*coverage_size/height(data));
end

%% FUNCTION: Compute HFSRS Approximations
function [lower_approx, upper_approx, boundary_region] = ...
         compute_hfsrs_approximations(data, target_set, beta)
    % Compute HFSRS lower and upper approximations
    %
    % Usage:
    %   faulty_modules = find(data.Fault_Label == 1);
    %   [lower, upper, boundary] = compute_hfsrs_approximations(data, faulty_modules, 0.65)
    %
    % Inputs:
    %   data       - Dataset table
    %   target_set - Indices of modules in target set (e.g., faulty modules)
    %   beta       - Threshold value [0, 1]
    %
    % Outputs:
    %   lower_approx     - Indices of modules in lower approximation (definite)
    %   upper_approx     - Indices of modules in upper approximation (possible)
    %   boundary_region  - Indices of modules in boundary region (uncertain)

    n_modules = height(data);
    parameters = {'Voltage_Drop', 'Temp_Rise', 'Irradiance_Loss'};

    % Initialize approximations
    lower_approx = [];
    upper_approx = [];

    % For each parameter, compute β-coverage
    coverages = cell(length(parameters), 1);
    for p = 1:length(parameters)
        [coverage_indices, ~] = compute_beta_coverage(data, parameters{p}, beta);
        coverages{p} = find(coverage_indices);
    end

    % Lower approximation: x ∈ apr_β(X) if ∃C^β_e: x ∈ C^β_e ⊆ X
    for i = 1:n_modules
        for p = 1:length(parameters)
            coverage = coverages{p};
            if ismember(i, coverage)
                % Check if entire coverage containing i is subset of target_set
                if all(ismember(coverage, target_set))
                    if ~ismember(i, lower_approx)
                        lower_approx = [lower_approx; i]; %#ok<AGROW>
                    end
                end
            end
        end
    end

    % Upper approximation: x ∈ apr̄_β(X) if ∃C^β_e: x ∈ C^β_e ∩ X ≠ ∅
    for i = 1:n_modules
        for p = 1:length(parameters)
            coverage = coverages{p};
            if ismember(i, coverage)
                % Check if coverage intersects with target_set
                if any(ismember(coverage, target_set))
                    if ~ismember(i, upper_approx)
                        upper_approx = [upper_approx; i]; %#ok<AGROW>
                    end
                    break;  % Found intersection, move to next module
                end
            end
        end
    end

    % Boundary region: BN_β(X) = apr̄_β(X) - apr_β(X)
    boundary_region = setdiff(upper_approx, lower_approx);

    fprintf('\nHFSRS Approximations (β=%.2f):\n', beta);
    fprintf('  Target set size:      %d\n', length(target_set));
    fprintf('  Lower approximation:  %d modules (definite)\n', length(lower_approx));
    fprintf('  Upper approximation:  %d modules (possible)\n', length(upper_approx));
    fprintf('  Boundary region:      %d modules (uncertain)\n', length(boundary_region));
    fprintf('  Boundary percentage:  %.1f%%\n', 100*length(boundary_region)/n_modules);
end

%% FUNCTION: Visualize Dataset
function visualize_dataset(data)
    % Create comprehensive visualization of the dataset
    %
    % Usage:
    %   data = load_pv_dataset();
    %   visualize_dataset(data);

    figure('Position', [100, 100, 1200, 800], 'Name', 'PV Fault Detection Dataset');

    % Extract data
    voltage = [data.Voltage_Drop_Expert1, data.Voltage_Drop_Expert2, data.Voltage_Drop_Expert3];
    temp = [data.Temp_Rise_Expert1, data.Temp_Rise_Expert2, data.Temp_Rise_Expert3];
    irrad = [data.Irradiance_Loss_Expert1, data.Irradiance_Loss_Expert2, data.Irradiance_Loss_Expert3];

    voltage_mean = mean(voltage, 2);
    temp_mean = mean(temp, 2);
    irrad_mean = mean(irrad, 2);

    healthy_idx = data.Fault_Label == 0;
    faulty_idx = data.Fault_Label == 1;

    % Plot 1: Voltage Drop Distribution
    subplot(2, 3, 1);
    histogram(voltage(healthy_idx, :), 20, 'FaceColor', 'g', 'FaceAlpha', 0.6);
    hold on;
    histogram(voltage(faulty_idx, :), 20, 'FaceColor', 'r', 'FaceAlpha', 0.6);
    xlabel('Voltage Drop');
    ylabel('Frequency');
    title('Voltage Drop Distribution');
    legend('Healthy', 'Faulty');
    grid on;

    % Plot 2: Temperature Rise Distribution
    subplot(2, 3, 2);
    histogram(temp(healthy_idx, :), 20, 'FaceColor', 'g', 'FaceAlpha', 0.6);
    hold on;
    histogram(temp(faulty_idx, :), 20, 'FaceColor', 'r', 'FaceAlpha', 0.6);
    xlabel('Temperature Rise');
    ylabel('Frequency');
    title('Temperature Rise Distribution');
    legend('Healthy', 'Faulty');
    grid on;

    % Plot 3: Irradiance Loss Distribution
    subplot(2, 3, 3);
    histogram(irrad(healthy_idx, :), 20, 'FaceColor', 'g', 'FaceAlpha', 0.6);
    hold on;
    histogram(irrad(faulty_idx, :), 20, 'FaceColor', 'r', 'FaceAlpha', 0.6);
    xlabel('Irradiance Loss');
    ylabel('Frequency');
    title('Irradiance Loss Distribution');
    legend('Healthy', 'Faulty');
    grid on;

    % Plot 4: Scatter - Voltage vs Temperature
    subplot(2, 3, 4);
    scatter(voltage_mean(healthy_idx), temp_mean(healthy_idx), 50, 'g', 'filled', 'MarkerFaceAlpha', 0.6);
    hold on;
    scatter(voltage_mean(faulty_idx), temp_mean(faulty_idx), 50, 'r', 'filled', 'MarkerFaceAlpha', 0.6);
    xlabel('Voltage Drop (Mean)');
    ylabel('Temperature Rise (Mean)');
    title('Voltage Drop vs Temperature Rise');
    legend('Healthy', 'Faulty');
    grid on;

    % Plot 5: Scatter - Voltage vs Irradiance
    subplot(2, 3, 5);
    scatter(voltage_mean(healthy_idx), irrad_mean(healthy_idx), 50, 'g', 'filled', 'MarkerFaceAlpha', 0.6);
    hold on;
    scatter(voltage_mean(faulty_idx), irrad_mean(faulty_idx), 50, 'r', 'filled', 'MarkerFaceAlpha', 0.6);
    xlabel('Voltage Drop (Mean)');
    ylabel('Irradiance Loss (Mean)');
    title('Voltage Drop vs Irradiance Loss');
    legend('Healthy', 'Faulty');
    grid on;

    % Plot 6: Box plots
    subplot(2, 3, 6);
    boxplot([voltage_mean, temp_mean, irrad_mean], 'Labels', {'Voltage', 'Temp', 'Irradiance'});
    ylabel('Normalized Value');
    title('Fault Indicators (All Modules)');
    grid on;

    fprintf('\n✓ Visualizations created!\n');
end

%% FUNCTION: Export for HFSRS
function export_for_hfsrs(data, output_file)
    % Export dataset in HFSRS-compatible format
    %
    % Usage:
    %   data = load_pv_dataset();
    %   export_for_hfsrs(data, 'hfsrs_input.mat');

    if nargin < 2
        output_file = 'hfsrs_input.mat';
    end

    % Create HFSRS structure
    HFSRS = struct();
    HFSRS.module_ids = data.Module_ID;
    HFSRS.n_modules = height(data);
    HFSRS.n_parameters = 3;
    HFSRS.parameters = {'Voltage_Drop', 'Temp_Rise', 'Irradiance_Loss'};

    % Expert assessments
    HFSRS.voltage_drop = [data.Voltage_Drop_Expert1, ...
                          data.Voltage_Drop_Expert2, ...
                          data.Voltage_Drop_Expert3];
    HFSRS.temp_rise = [data.Temp_Rise_Expert1, ...
                       data.Temp_Rise_Expert2, ...
                       data.Temp_Rise_Expert3];
    HFSRS.irradiance_loss = [data.Irradiance_Loss_Expert1, ...
                             data.Irradiance_Loss_Expert2, ...
                             data.Irradiance_Loss_Expert3];

    % Compute max HFE values for each parameter
    HFSRS.voltage_drop_max = max(HFSRS.voltage_drop, [], 2);
    HFSRS.temp_rise_max = max(HFSRS.temp_rise, [], 2);
    HFSRS.irradiance_loss_max = max(HFSRS.irradiance_loss, [], 2);

    % Ground truth labels
    HFSRS.fault_labels = data.Fault_Label;
    HFSRS.fault_types = data.Fault_Type;

    % Save
    save(output_file, 'HFSRS', '-v7.3');
    fprintf('\n✓ HFSRS-compatible data saved: %s\n', output_file);
end

%% EXAMPLE USAGE
% Uncomment to run examples:
%
% % Load dataset
% data = load_pv_dataset();
%
% % Parse HFE example
% hfe = parse_hfe(data.Voltage_Drop_HFE(1));
% disp(hfe);
%
% % Compute β-coverage
% [indices, size] = compute_beta_coverage(data, 'Voltage_Drop', 0.65);
%
% % Compute HFSRS approximations for faulty modules
% faulty_modules = find(data.Fault_Label == 1);
% [lower, upper, boundary] = compute_hfsrs_approximations(data, faulty_modules, 0.65);
%
% % Visualize dataset
% visualize_dataset(data);
%
% % Export for HFSRS
% export_for_hfsrs(data);
