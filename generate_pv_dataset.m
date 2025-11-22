% =========================================================================
% PV FAULT DETECTION DATASET GENERATOR - MATLAB VERSION
% =========================================================================
%
% Generates synthetic photovoltaic fault detection dataset with hesitant 
% fuzzy elements for validation of the HFSRS framework.
%
% USAGE:
%   generate_pv_dataset()          % Default: 500 modules, 300 healthy
%   generate_pv_dataset(1000, 600) % Custom: 1000 modules, 600 healthy
%
% OUTPUT FILES:
%   - PV_Fault_Detection_Dataset.csv (Main dataset)
%   - dataset_statistics.txt (Statistical summary)
%   - dataset_metadata.json (Metadata)
%
% AUTHOR: Jahanvi, Dinesh Kumar Nishad, Rashmi Singh, Saifullah Khalid
% DATE: November 21, 2025
% LICENSE: CC BY 4.0
% MATLAB VERSION: R2024b (compatible with R2020a+)
%
% =========================================================================

function generate_pv_dataset(n_modules, n_healthy)
    %% CONFIGURATION PARAMETERS
    if nargin < 1
        n_modules = 500;
    end
    if nargin < 2
        n_healthy = 300;
    end

    n_faulty = n_modules - n_healthy;
    n_experts = 3;
    expert_noise_std = 0.05;

    % Set random seed for reproducibility
    rng(42);

    %% DISPLAY CONFIGURATION
    fprintf('\n');
    fprintf('=========================================================\n');
    fprintf('  PV FAULT DETECTION DATASET GENERATOR (MATLAB)\n');
    fprintf('=========================================================\n');
    fprintf('\nConfiguration:\n');
    fprintf('  Total modules:       %d\n', n_modules);
    fprintf('  Healthy modules:     %d (%.1f%%)\n', n_healthy, 100*n_healthy/n_modules);
    fprintf('  Faulty modules:      %d (%.1f%%)\n', n_faulty, 100*n_faulty/n_modules);
    fprintf('  Experts per module:  %d\n', n_experts);
    fprintf('  Random seed:         42\n');
    fprintf('\nGenerating dataset...\n');

    %% INITIALIZE DATA STRUCTURES
    module_ids = cell(n_modules, 1);
    voltage_drop_experts = zeros(n_modules, n_experts);
    temp_rise_experts = zeros(n_modules, n_experts);
    irradiance_loss_experts = zeros(n_modules, n_experts);
    voltage_drop_hfe = cell(n_modules, 1);
    temp_rise_hfe = cell(n_modules, 1);
    irradiance_loss_hfe = cell(n_modules, 1);
    fault_labels = zeros(n_modules, 1);
    fault_types = cell(n_modules, 1);

    %% GENERATE HEALTHY MODULES
    fprintf('  [1/2] Generating healthy modules...');
    for i = 1:n_healthy
        module_ids{i} = sprintf('PV_%03d', i);

        % Base values for healthy modules (low fault indicators)
        voltage_drop_base = normrnd(0.25, 0.10);
        temp_rise_base = normrnd(0.30, 0.08);
        irradiance_loss_base = normrnd(0.20, 0.06);

        % Clip to [0, 1] range
        voltage_drop_base = max(0, min(1, voltage_drop_base));
        temp_rise_base = max(0, min(1, temp_rise_base));
        irradiance_loss_base = max(0, min(1, irradiance_loss_base));

        % Generate expert assessments with noise
        for j = 1:n_experts
            voltage_drop_experts(i, j) = round(clip_value(...
                voltage_drop_base + normrnd(0, expert_noise_std)), 3);
            temp_rise_experts(i, j) = round(clip_value(...
                temp_rise_base + normrnd(0, expert_noise_std)), 3);
            irradiance_loss_experts(i, j) = round(clip_value(...
                irradiance_loss_base + normrnd(0, expert_noise_std)), 3);
        end

        % Create HFE strings (sets of unique expert values)
        voltage_drop_hfe{i} = create_hfe_string(voltage_drop_experts(i, :));
        temp_rise_hfe{i} = create_hfe_string(temp_rise_experts(i, :));
        irradiance_loss_hfe{i} = create_hfe_string(irradiance_loss_experts(i, :));

        fault_labels(i) = 0;
        fault_types{i} = 'Healthy';
    end
    fprintf(' Done!\n');

    %% GENERATE FAULTY MODULES
    fprintf('  [2/2] Generating faulty modules...');
    for i = (n_healthy+1):n_modules
        module_ids{i} = sprintf('PV_%03d', i);

        % Base values for faulty modules (high fault indicators)
        voltage_drop_base = normrnd(0.75, 0.12);
        temp_rise_base = normrnd(0.70, 0.10);
        irradiance_loss_base = normrnd(0.80, 0.09);

        % Clip to [0, 1] range
        voltage_drop_base = max(0, min(1, voltage_drop_base));
        temp_rise_base = max(0, min(1, temp_rise_base));
        irradiance_loss_base = max(0, min(1, irradiance_loss_base));

        % Generate expert assessments with noise
        for j = 1:n_experts
            voltage_drop_experts(i, j) = round(clip_value(...
                voltage_drop_base + normrnd(0, expert_noise_std)), 3);
            temp_rise_experts(i, j) = round(clip_value(...
                temp_rise_base + normrnd(0, expert_noise_std)), 3);
            irradiance_loss_experts(i, j) = round(clip_value(...
                irradiance_loss_base + normrnd(0, expert_noise_std)), 3);
        end

        % Create HFE strings
        voltage_drop_hfe{i} = create_hfe_string(voltage_drop_experts(i, :));
        temp_rise_hfe{i} = create_hfe_string(temp_rise_experts(i, :));
        irradiance_loss_hfe{i} = create_hfe_string(irradiance_loss_experts(i, :));

        fault_labels(i) = 1;
        fault_types{i} = 'Faulty';
    end
    fprintf(' Done!\n');

    %% CREATE TABLE
    fprintf('\nCreating data table...\n');
    dataset_table = table(module_ids, ...
        voltage_drop_experts(:,1), voltage_drop_experts(:,2), voltage_drop_experts(:,3), voltage_drop_hfe, ...
        temp_rise_experts(:,1), temp_rise_experts(:,2), temp_rise_experts(:,3), temp_rise_hfe, ...
        irradiance_loss_experts(:,1), irradiance_loss_experts(:,2), irradiance_loss_experts(:,3), irradiance_loss_hfe, ...
        fault_labels, fault_types, ...
        'VariableNames', {'Module_ID', ...
            'Voltage_Drop_Expert1', 'Voltage_Drop_Expert2', 'Voltage_Drop_Expert3', 'Voltage_Drop_HFE', ...
            'Temp_Rise_Expert1', 'Temp_Rise_Expert2', 'Temp_Rise_Expert3', 'Temp_Rise_HFE', ...
            'Irradiance_Loss_Expert1', 'Irradiance_Loss_Expert2', 'Irradiance_Loss_Expert3', 'Irradiance_Loss_HFE', ...
            'Fault_Label', 'Fault_Type'});

    %% SAVE TO CSV
    output_filename = 'PV_Fault_Detection_Dataset.csv';
    writetable(dataset_table, output_filename);
    fprintf('\n✓ Dataset saved: %s\n', output_filename);

    %% COMPUTE AND DISPLAY STATISTICS
    compute_and_save_statistics(dataset_table, voltage_drop_experts, ...
        temp_rise_experts, irradiance_loss_experts, fault_labels);

    %% SAVE METADATA
    save_metadata(n_modules, n_healthy, n_faulty, n_experts, expert_noise_std);

    %% COMPLETION MESSAGE
    fprintf('\n=========================================================\n');
    fprintf('  ✓ DATASET GENERATION COMPLETE!\n');
    fprintf('=========================================================\n');
    fprintf('\nGenerated files:\n');
    fprintf('  1. %s\n', output_filename);
    fprintf('  2. dataset_statistics.txt\n');
    fprintf('  3. dataset_metadata.json\n');
    fprintf('\n');
end

%% HELPER FUNCTIONS

function val = clip_value(val)
    % Clip value to [0, 1] range
    val = max(0, min(1, val));
end

function hfe_str = create_hfe_string(values)
    % Create HFE string representation from array of values
    % Input: [0.250, 0.267, 0.250] -> Output: '{0.250, 0.267}'
    unique_vals = unique(values);
    hfe_str = '{';
    for i = 1:length(unique_vals)
        hfe_str = [hfe_str, sprintf('%.3f', unique_vals(i))];
        if i < length(unique_vals)
            hfe_str = [hfe_str, ', '];
        end
    end
    hfe_str = [hfe_str, '}'];
end

function compute_and_save_statistics(dataset_table, voltage_drop_experts, ...
                                     temp_rise_experts, irradiance_loss_experts, fault_labels)
    % Compute and save comprehensive statistics

    n_modules = height(dataset_table);
    n_healthy = sum(fault_labels == 0);
    n_faulty = sum(fault_labels == 1);

    fprintf('\n=========================================================\n');
    fprintf('  DATASET STATISTICS\n');
    fprintf('=========================================================\n');
    fprintf('\nOverall Statistics:\n');
    fprintf('  Total modules:    %d\n', n_modules);
    fprintf('  Healthy modules:  %d (%.1f%%)\n', n_healthy, 100*n_healthy/n_modules);
    fprintf('  Faulty modules:   %d (%.1f%%)\n', n_faulty, 100*n_faulty/n_modules);
    fprintf('  Total columns:    %d\n', width(dataset_table));

    % Open file for statistics
    fid = fopen('dataset_statistics.txt', 'w');
    fprintf(fid, '==========================================================\n');
    fprintf(fid, ' PV FAULT DETECTION DATASET - STATISTICAL SUMMARY\n');
    fprintf(fid, '==========================================================\n');
    fprintf(fid, '\nGeneration Date: %s\n', datestr(now));
    fprintf(fid, 'MATLAB Version: %s\n', version);
    fprintf(fid, '\nOverall Statistics:\n');
    fprintf(fid, '  Total modules:    %d\n', n_modules);
    fprintf(fid, '  Healthy modules:  %d (%.1f%%)\n', n_healthy, 100*n_healthy/n_modules);
    fprintf(fid, '  Faulty modules:   %d (%.1f%%)\n', n_faulty, 100*n_faulty/n_modules);

    % Compute statistics for each fault indicator
    indicators = {'Voltage_Drop', 'Temp_Rise', 'Irradiance_Loss'};
    expert_data = {voltage_drop_experts, temp_rise_experts, irradiance_loss_experts};

    fprintf('\nFault Indicator Statistics:\n');
    fprintf(fid, '\n----------------------------------------------------------\n');
    fprintf(fid, 'Fault Indicator Statistics (All Expert Assessments)\n');
    fprintf(fid, '----------------------------------------------------------\n');

    for idx = 1:length(indicators)
        indicator = indicators{idx};
        data = expert_data{idx};

        healthy_vals = data(fault_labels == 0, :);
        faulty_vals = data(fault_labels == 1, :);

        healthy_mean = mean(healthy_vals(:));
        healthy_std = std(healthy_vals(:));
        healthy_min = min(healthy_vals(:));
        healthy_max = max(healthy_vals(:));

        faulty_mean = mean(faulty_vals(:));
        faulty_std = std(faulty_vals(:));
        faulty_min = min(faulty_vals(:));
        faulty_max = max(faulty_vals(:));

        fprintf('\n  %s:\n', strrep(indicator, '_', ' '));
        fprintf('    Healthy - Mean: %.3f, Std: %.3f, Range: [%.3f, %.3f]\n', ...
                healthy_mean, healthy_std, healthy_min, healthy_max);
        fprintf('    Faulty  - Mean: %.3f, Std: %.3f, Range: [%.3f, %.3f]\n', ...
                faulty_mean, faulty_std, faulty_min, faulty_max);

        fprintf(fid, '\n%s:\n', strrep(indicator, '_', ' '));
        fprintf(fid, '  Healthy Modules:\n');
        fprintf(fid, '    Mean:      %.3f\n', healthy_mean);
        fprintf(fid, '    Std Dev:   %.3f\n', healthy_std);
        fprintf(fid, '    Min:       %.3f\n', healthy_min);
        fprintf(fid, '    Max:       %.3f\n', healthy_max);
        fprintf(fid, '  Faulty Modules:\n');
        fprintf(fid, '    Mean:      %.3f\n', faulty_mean);
        fprintf(fid, '    Std Dev:   %.3f\n', faulty_std);
        fprintf(fid, '    Min:       %.3f\n', faulty_min);
        fprintf(fid, '    Max:       %.3f\n', faulty_max);
    end

    % Correlation analysis
    fprintf('\nCorrelation Analysis:\n');
    fprintf(fid, '\n----------------------------------------------------------\n');
    fprintf(fid, 'Correlation Matrix (All Expert Assessments)\n');
    fprintf(fid, '----------------------------------------------------------\n');

    voltage_vals = voltage_drop_experts(:);
    temp_vals = temp_rise_experts(:);
    irrad_vals = irradiance_loss_experts(:);

    corr_vt = corr(voltage_vals, temp_vals);
    corr_vi = corr(voltage_vals, irrad_vals);
    corr_ti = corr(temp_vals, irrad_vals);

    fprintf('  Voltage Drop <-> Temperature Rise:   r = %.3f\n', corr_vt);
    fprintf('  Voltage Drop <-> Irradiance Loss:    r = %.3f\n', corr_vi);
    fprintf('  Temperature Rise <-> Irradiance Loss: r = %.3f\n', corr_ti);

    fprintf(fid, '\n                    Voltage_Drop  Temp_Rise  Irradiance_Loss\n');
    fprintf(fid, '  Voltage_Drop          1.000       %.3f        %.3f\n', corr_vt, corr_vi);
    fprintf(fid, '  Temp_Rise             %.3f       1.000        %.3f\n', corr_vt, corr_ti);
    fprintf(fid, '  Irradiance_Loss       %.3f       %.3f        1.000\n', corr_vi, corr_ti);

    fprintf(fid, '\n==========================================================\n');
    fprintf(fid, ' END OF STATISTICAL SUMMARY\n');
    fprintf(fid, '==========================================================\n');

    fclose(fid);
    fprintf('\n✓ Statistics saved: dataset_statistics.txt\n');
end

function save_metadata(n_modules, n_healthy, n_faulty, n_experts, expert_noise_std)
    % Save metadata in JSON format

    metadata = struct();
    metadata.generation_date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    metadata.matlab_version = version;
    metadata.version = '1.0.0';
    metadata.total_modules = n_modules;
    metadata.healthy_modules = n_healthy;
    metadata.faulty_modules = n_faulty;
    metadata.num_experts = n_experts;
    metadata.expert_noise_std = expert_noise_std;
    metadata.random_seed = 42;
    metadata.parameters = {'Voltage_Drop', 'Temperature_Rise', 'Irradiance_Loss'};
    metadata.value_range = [0, 1];
    metadata.precision = 3;

    % Fault distributions
    metadata.fault_distributions.voltage_drop.healthy.mean = 0.25;
    metadata.fault_distributions.voltage_drop.healthy.std = 0.10;
    metadata.fault_distributions.voltage_drop.faulty.mean = 0.75;
    metadata.fault_distributions.voltage_drop.faulty.std = 0.12;

    metadata.fault_distributions.temperature_rise.healthy.mean = 0.30;
    metadata.fault_distributions.temperature_rise.healthy.std = 0.08;
    metadata.fault_distributions.temperature_rise.faulty.mean = 0.70;
    metadata.fault_distributions.temperature_rise.faulty.std = 0.10;

    metadata.fault_distributions.irradiance_loss.healthy.mean = 0.20;
    metadata.fault_distributions.irradiance_loss.healthy.std = 0.06;
    metadata.fault_distributions.irradiance_loss.faulty.mean = 0.80;
    metadata.fault_distributions.irradiance_loss.faulty.std = 0.09;

    metadata.standards_reference = {'IEC 61215-2:2021', 'IEEE Std 1526-2020'};
    metadata.license = 'CC-BY-4.0';

    % Convert to JSON and save
    json_str = jsonencode(metadata, 'PrettyPrint', true);
    fid = fopen('dataset_metadata.json', 'w');
    fprintf(fid, '%s', json_str);
    fclose(fid);

    fprintf('✓ Metadata saved: dataset_metadata.json\n');
end
