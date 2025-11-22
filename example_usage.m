% =========================================================================
% EXAMPLE: WORKING WITH PV FAULT DETECTION DATASET IN MATLAB
% =========================================================================
%
% This script demonstrates how to:
% 1. Generate the dataset
% 2. Load and explore the data
% 3. Compute β-coverings
% 4. Calculate HFSRS approximations
% 5. Visualize results
% 6. Perform basic analysis
%
% AUTHOR: Jahanvi, Dinesh Kumar Nishad, Rashmi Singh, Saifullah Khalid
% DATE: November 21, 2025
% LICENSE: CC BY 4.0
%
% INSTRUCTIONS: Run this script section by section (Ctrl+Enter in MATLAB)
%
% =========================================================================

clear; clc; close all;

fprintf('\n');
fprintf('=================================================================\n');
fprintf(' PV FAULT DETECTION DATASET - MATLAB EXAMPLE\n');
fprintf('=================================================================\n');
run('pv_dataset_utils.m');
%% STEP 1: GENERATE DATASET (if not already generated)
fprintf('\n[STEP 1] Generating dataset...\n');
fprintf('Press Enter to continue, or Ctrl+C to skip if already generated\n');
pause;

generate_pv_dataset();  % Generate with default parameters (500 modules)

%% STEP 2: LOAD DATASET
fprintf('\n[STEP 2] Loading dataset...\n');

run('pv_dataset_utils.m');
data = load_pv_dataset();

% Display basic information
fprintf('\nDataset overview:\n');
fprintf('  Size: %d modules × %d columns\n', height(data), width(data));
fprintf('  Variables: %s\n', strjoin(data.Properties.VariableNames, ', '));

% Show first few rows
fprintf('\nFirst 5 modules:\n');
disp(data(1:5, :));

%% STEP 3: EXPLORE FAULT INDICATORS
fprintf('\n[STEP 3] Exploring fault indicators...\n');

% Count healthy vs faulty
n_healthy = sum(data.Fault_Label == 0);
n_faulty = sum(data.Fault_Label == 1);

fprintf('\nFault distribution:\n');
fprintf('  Healthy: %d (%.1f%%)\n', n_healthy, 100*n_healthy/height(data));
fprintf('  Faulty:  %d (%.1f%%)\n', n_faulty, 100*n_faulty/height(data));

% Compute statistics for each indicator
indicators = {'Voltage_Drop', 'Temp_Rise', 'Irradiance_Loss'};

fprintf('\nFault indicator statistics:\n');
for i = 1:length(indicators)
    indicator = indicators{i};
    expert_cols = {sprintf('%s_Expert1', indicator), ...
                   sprintf('%s_Expert2', indicator), ...
                   sprintf('%s_Expert3', indicator)};

    healthy_vals = [data{data.Fault_Label==0, expert_cols{1}}, ...
                    data{data.Fault_Label==0, expert_cols{2}}, ...
                    data{data.Fault_Label==0, expert_cols{3}}];

    faulty_vals = [data{data.Fault_Label==1, expert_cols{1}}, ...
                   data{data.Fault_Label==1, expert_cols{2}}, ...
                   data{data.Fault_Label==1, expert_cols{3}}];

    fprintf('\n  %s:\n', strrep(indicator, '_', ' '));
    fprintf('    Healthy - Mean: %.3f, Std: %.3f\n', mean(healthy_vals(:)), std(healthy_vals(:)));
    fprintf('    Faulty  - Mean: %.3f, Std: %.3f\n', mean(faulty_vals(:)), std(faulty_vals(:)));
end

%% STEP 4: PARSE HESITANT FUZZY ELEMENTS (HFEs)
fprintf('\n[STEP 4] Parsing Hesitant Fuzzy Elements...\n');

% Example: Parse voltage drop HFE for first module
module_1_voltage_hfe = parse_hfe(data.Voltage_Drop_HFE(1));
fprintf('\nModule PV_001 Voltage Drop HFE:\n');
fprintf('  String format: %s\n', data.Voltage_Drop_HFE(1));
fprintf('  Array format:  [%s]\n', num2str(module_1_voltage_hfe));
fprintf('  Max value:     %.3f (used for β-covering)\n', max(module_1_voltage_hfe));

%% STEP 5: COMPUTE β-COVERAGE
fprintf('\n[STEP 5] Computing β-coverage...\n');

% Test different β values
beta_values = [0.3, 0.5, 0.65, 0.8];

fprintf('\nβ-Coverage for Voltage Drop:\n');
for beta = beta_values
    [coverage_idx, coverage_size] = compute_beta_coverage(data, 'Voltage_Drop', beta);
    fprintf('  β=%.2f: %d modules (%.1f%%)\n', beta, coverage_size, ...
            100*coverage_size/height(data));
end

% Optimal β from paper: 0.65
fprintf('\n→ Optimal β = 0.65 (from sensitivity analysis in paper)\n');

%% STEP 6: COMPUTE HFSRS APPROXIMATIONS
fprintf('\n[STEP 6] Computing HFSRS approximations...\n');

% Define target set: faulty modules
faulty_modules = find(data.Fault_Label == 1);

% Compute approximations with β = 0.65
beta_optimal = 0.65;
[lower_approx, upper_approx, boundary_region] = ...
    compute_hfsrs_approximations(data, faulty_modules, beta_optimal);

% Display results
fprintf('\nResults:\n');
fprintf('  Lower approximation:  %d modules (%.1f%% of target)\n', ...
        length(lower_approx), 100*length(lower_approx)/length(faulty_modules));
fprintf('  Upper approximation:  %d modules (%.1f%% of target)\n', ...
        length(upper_approx), 100*length(upper_approx)/length(faulty_modules));
fprintf('  Boundary region:      %d modules (%.1f%% of dataset)\n', ...
        length(boundary_region), 100*length(boundary_region)/height(data));

%% STEP 7: CLASSIFICATION ACCURACY
fprintf('\n[STEP 7] Evaluating classification accuracy...\n');

% Simple classification: classify as faulty if in upper approximation
predicted_faulty = false(height(data), 1);
predicted_faulty(upper_approx) = true;

actual_faulty = data.Fault_Label == 1;

% Confusion matrix
TP = sum(predicted_faulty & actual_faulty);
TN = sum(~predicted_faulty & ~actual_faulty);
FP = sum(predicted_faulty & ~actual_faulty);
FN = sum(~predicted_faulty & actual_faulty);

accuracy = (TP + TN) / height(data);
precision = TP / (TP + FP);
recall = TP / (TP + FN);
f1_score = 2 * (precision * recall) / (precision + recall);

fprintf('\nClassification metrics (using upper approximation):\n');
fprintf('  Accuracy:  %.1f%%\n', 100*accuracy);
fprintf('  Precision: %.1f%%\n', 100*precision);
fprintf('  Recall:    %.1f%%\n', 100*recall);
fprintf('  F1-Score:  %.3f\n', f1_score);

fprintf('\nConfusion Matrix:\n');
fprintf('                Predicted\n');
fprintf('              Healthy  Faulty\n');
fprintf('  Actual  H    %4d    %4d\n', TN, FP);
fprintf('          F    %4d    %4d\n', FN, TP);

%% STEP 8: VISUALIZE DATASET
fprintf('\n[STEP 8] Creating visualizations...\n');
fprintf('(Close figure window to continue)\n');

visualize_dataset(data);

%% STEP 9: SENSITIVITY ANALYSIS (β-threshold)
fprintf('\n[STEP 9] β-threshold sensitivity analysis...\n');

beta_range = 0.1:0.05:0.9;
coverage_sizes = zeros(size(beta_range));
boundary_sizes = zeros(size(beta_range));
accuracies = zeros(size(beta_range));

for i = 1:length(beta_range)
    beta = beta_range(i);

    % Compute coverage
    [~, coverage_sizes(i)] = compute_beta_coverage(data, 'Voltage_Drop', beta);

    % Compute approximations
    [~, upper_temp, boundary_temp] = ...
        compute_hfsrs_approximations(data, faulty_modules, beta);

    boundary_sizes(i) = length(boundary_temp);

    % Compute accuracy
    predicted = false(height(data), 1);
    predicted(upper_temp) = true;
    accuracies(i) = sum(predicted == actual_faulty) / height(data);
end

% Plot sensitivity
figure('Position', [100, 100, 1000, 600], 'Name', 'β-Threshold Sensitivity');

subplot(1, 3, 1);
plot(beta_range, coverage_sizes, 'b-', 'LineWidth', 2);
xlabel('β Threshold');
ylabel('Coverage Size');
title('β-Coverage Size vs Threshold');
grid on;

subplot(1, 3, 2);
plot(beta_range, boundary_sizes, 'r-', 'LineWidth', 2);
xlabel('β Threshold');
ylabel('Boundary Region Size');
title('Boundary Region vs Threshold');
grid on;

subplot(1, 3, 3);
plot(beta_range, 100*accuracies, 'g-', 'LineWidth', 2);
hold on;
[max_acc, max_idx] = max(accuracies);
plot(beta_range(max_idx), 100*max_acc, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('β Threshold');
ylabel('Accuracy (%)');
title('Classification Accuracy vs Threshold');
legend('Accuracy', sprintf('Max (β=%.2f, Acc=%.1f%%)', beta_range(max_idx), 100*max_acc));
grid on;

fprintf('\nOptimal β from analysis: %.2f (Accuracy: %.1f%%)\n', ...
        beta_range(max_idx), 100*max_acc);

%% STEP 10: EXPORT FOR FURTHER ANALYSIS
fprintf('\n[STEP 10] Exporting data...\n');

% Export HFSRS-compatible format
export_for_hfsrs(data);

% Export specific results
results = struct();
results.beta_optimal = beta_optimal;
results.lower_approximation = lower_approx;
results.upper_approximation = upper_approx;
results.boundary_region = boundary_region;
results.accuracy = accuracy;
results.precision = precision;
results.recall = recall;
results.f1_score = f1_score;

save('hfsrs_results.mat', 'results', '-v7.3');
fprintf('✓ Results saved: hfsrs_results.mat\n');

%% COMPLETION
fprintf('\n');
fprintf('=================================================================\n');
fprintf(' ✓ EXAMPLE COMPLETED SUCCESSFULLY!\n');
fprintf('=================================================================\n');
fprintf('\nGenerated files:\n');
fprintf('  1. PV_Fault_Detection_Dataset.csv\n');
fprintf('  2. dataset_statistics.txt\n');
fprintf('  3. dataset_metadata.json\n');
fprintf('  4. hfsrs_input.mat\n');
fprintf('  5. hfsrs_results.mat\n');
fprintf('\nNext steps:\n');
fprintf('  - Modify β threshold in Step 6 for different results\n');
fprintf('  - Apply HFSRS-TOPSIS algorithm from paper\n');
fprintf('  - Compare with other rough set methods\n');
fprintf('\n');
