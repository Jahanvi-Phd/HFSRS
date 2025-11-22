PV Fault Detection Dataset - MATLAB Version
A Hybrid Framework of Hesitant Fuzzy Soft Sets and Rough Sets for Uncertainty Modelling
Jahanvi, Dinesh Kumar Nishad, Rashmi Singh, Saifullah Khalid (2025)
📁 MATLAB Files
Core Scripts
generate_pv_dataset.m - Main dataset generation script
pv_dataset_utils.m - Utility functions for data analysis
example_usage.m - Complete workflow example
Generated Files
PV_Fault_Detection_Dataset.csv - Main dataset (500 modules)
dataset_statistics.txt - Statistical summary
dataset_metadata.json - Machine-readable metadata
hfsrs_input.mat - MATLAB-native format for HFSRS
hfsrs_results.mat - Analysis results
Quick Start
Method 1: Run Complete Example
matlab
% In MATLAB command window:
run('example_usage.m')
This will:Generate the dataset, Load and explore data, Compute β-coverings,Calculate HFSRS , pproximations, Create visualizations, Export results
Method 2: Generate Dataset Only
matlab
% Default: 500 modules (300 healthy, 200 faulty)
generate_pv_dataset()
% Custom configuration
generate_pv_dataset(1000, 600)  % 1000 modules, 600 healthy
Method 3: Load Existing Dataset
matlab
% Load CSV dataset
data = load_pv_dataset();
% Or load from existing CSV file
data = readtable('PV_Fault_Detection_Dataset.csv');
Dataset Structure
Column	Type	Description
Module_ID	String	Unique identifier (PV_001 to PV_500)
Voltage_Drop_Expert1	Double	Expert assessments [0-1]
Voltage_Drop_Expert2	Double	Expert assessments [0-1]
Voltage_Drop_Expert3	Double	Expert assessments [0-1]
Voltage_Drop_HFE	String	Hesitant fuzzy element
Temp_Rise_Expert1	Double	Expert assessments [0-1]
Temp_Rise_Expert2	Double	Expert assessments [0-1]
Temp_Rise_Expert3	Double	Expert assessments [0-1]
Temp_Rise_HFE	String	Hesitant fuzzy element
Irradiance_Loss_Expert1	Double	Expert assessments [0-1]
Irradiance_Loss_Expert2	Double	Expert assessments [0-1]
Irradiance_Loss_Expert3	Double	Expert assessments [0-1]
Irradiance_Loss_HFE	String	Hesitant fuzzy element
Fault_Label	Integer	0=Healthy, 1=Faulty
Fault_Type	String	"Healthy" or "Faulty"

Statistics
Total Modules: 500 (300 healthy, 200 faulty)
Parameters: 3 fault indicators
Experts: 3 assessments per module per parameter
Format: CSV with hesitant fuzzy elements

Usage Examples
Example 1: Load and Explore
matlab
% Load dataset
data = load_pv_dataset();
% Display summary
summary(data);
% View first 10 rows
head(data, 10)
% Count fault types
tabulate(data.Fault_Type)
Example 2: Parse Hesitant Fuzzy Elements
matlab
% Get HFE for first module
hfe_string = data.Voltage_Drop_HFE(1);  % '{0.250, 0.267}'
% Parse to array
hfe_array = parse_hfe(hfe_string);      % [0.250, 0.267]
% Compute max (for β-covering)
max_value = max(hfe_array);             % 0.267
Example 3: Compute β-Coverage
matlab
% Load data
data = load_pv_dataset();
% Compute β-coverage for voltage drop with β=0.65
[coverage_indices, coverage_size] = compute_beta_coverage(data, 'Voltage_Drop', 0.65);
% Display results
fprintf('Modules in coverage: %d (%.1f%%)\n', coverage_size, 100*coverage_size/height(data));
% Extract modules in coverage
modules_in_coverage = data(coverage_indices, :);
Example 4: HFSRS Approximations
matlab
% Load data
data = load_pv_dataset();
% Define target set (faulty modules)
faulty_modules = find(data.Fault_Label == 1);
% Compute approximations with β=0.65
beta = 0.65;
[lower_approx, upper_approx, boundary_region] = ...
    compute_hfsrs_approximations(data, faulty_modules, beta);
% Display results
fprintf('Lower approximation: %d modules (definite)\n', length(lower_approx));
fprintf('Upper approximation: %d modules (possible)\n', length(upper_approx));
fprintf('Boundary region: %d modules (uncertain)\n', length(boundary_region));
Example 5: Visualization
matlab
% Load data
data = load_pv_dataset();
% Create comprehensive visualizations
visualize_dataset(data);
% The function generates 6 plots:
% 1. Voltage Drop distribution
% 2. Temperature Rise distribution
% 3. Irradiance Loss distribution
% 4. Voltage vs Temperature scatter
% 5. Voltage vs Irradiance scatter
% 6. Box plots for all indicators
Example 6: β-Threshold Sensitivity
matlab
% Load data
data = load_pv_dataset();
faulty_modules = find(data.Fault_Label == 1);
% Test different β values
beta_values = 0.1:0.1:0.9;
accuracies = zeros(size(beta_values));
for i = 1:length(beta_values)
    beta = beta_values(i);
    [~, upper_approx, ~] = compute_hfsrs_approximations(data, faulty_modules, beta);
    % Compute accuracy
    predicted = false(height(data), 1);
    predicted(upper_approx) = true;
    actual = data.Fault_Label == 1;
    accuracies(i) = sum(predicted == actual) / height(data);
end
% Plot results
plot(beta_values, 100*accuracies, 'LineWidth', 2);
xlabel('β Threshold');
ylabel('Accuracy (%)');
title('HFSRS Accuracy vs β-Threshold');
grid on;
Example 7: Export for HFSRS Analysis
matlab
% Load data
data = load_pv_dataset();
% Export in HFSRS-compatible MATLAB format
export_for_hfsrs(data, 'hfsrs_input.mat');
% Load exported data
load('hfsrs_input.mat');
% Access HFSRS structure
disp(HFSRS.parameters);           % Parameter names
disp(HFSRS.voltage_drop_max);     % Max HFE values for voltage drop
 Mathematical Framework
β-Coverage Definition (Definition 3.1)
For a hesitant fuzzy soft set (F, E) and threshold β ∈ [0,1]:
text
C^β_e = {x ∈ U : max(h_e(x)) ≥ β}
MATLAB Implementation:
matlab
% Extract expert assessments
expert_matrix = [data.Voltage_Drop_Expert1, ...
                 data.Voltage_Drop_Expert2, ...
                 data.Voltage_Drop_Expert3];
% Compute max HFE values
max_hfe = max(expert_matrix, [], 2);
% β-coverage
beta = 0.65;
coverage = max_hfe >= beta;
HFSRS Approximations
Lower Approximation (Definite):
text
apr_β(X) = {x ∈ U : ∃C^β_e such that x ∈ C^β_e ⊆ X}
Upper Approximation (Possible):
text
apr̄_β(X) = {x ∈ U : ∃C^β_e such that x ∈ C^β_e ∩ X ≠ ∅}
Boundary Region (Uncertain):
text
BN_β(X) = apr̄_β(X) - apr_β(X)
Results 
Using β = 0.65 (optimal threshold):
Metric	HFSRS	Classical RS	Improvement
Accuracy	92%	85%	+7%
AUC	0.97	0.92	+0.05
Boundary Region	8%	12%	-35%
System Requirements
MATLAB 
Recommended: R2024b
Minimum: R2020a
Required Toolboxes: Statistics and Machine Learning Toolbox
Hardware
RAM: 4 GB minimum, 8 GB recommended
Storage: 100 MB for dataset and scripts
Processor: Any modern CPU
Project Structure
text
PV-Fault-HFSRS-Dataset/
├── generate_pv_dataset.m     # Main generation script
├── pv_dataset_utils.m             # Utility functions
├── example_usage.m                # Complete example workflow
├── PV_Fault_Detection_Dataset.csv # Generated dataset
├── dataset_statistics.txt         # Statistical summary
├── dataset_metadata.json          # Metadata
├── README_MATLAB.md               # This file
└── LICENSE                        # CC BY 4.0
Troubleshooting
Issue: "Dataset file not found"
matlab
% Ensure you're in the correct directory
cd('path/to/dataset/folder')
% Or specify full path
data = readtable('C:/path/to/PV_Fault_Detection_Dataset.csv');
Issue: "Undefined function"
matlab
% Add folder to MATLAB path
addpath('path/to/dataset/folder');
savepath;  % Save for future sessions
Issue: "Out of memory"
matlab
% For large datasets, use tall arrays
data_tall = tall(readtable('PV_Fault_Detection_Dataset.csv'));
Function Reference
Main Functions
Function	Purpose	Usage
generate_pv_dataset()	Generate dataset	generate_pv_dataset(500, 300)
load_pv_dataset()	Load dataset	data = load_pv_dataset()
parse_hfe()	Parse HFE string	arr = parse_hfe('{0.25, 0.30}')
compute_beta_coverage()	Compute β-coverage	[idx, size] = compute_beta_coverage(data, 'Voltage_Drop', 0.65)
compute_hfsrs_approximations()	HFSRS approximations	[lower, upper, boundary] = compute_hfsrs_approximations(data, target, beta)
visualize_dataset()	Create plots	visualize_dataset(data)
export_for_hfsrs()	Export to .mat	export_for_hfsrs(data)
Citation
@article{jahanvi2025hfsrs,
  title={A Hybrid Framework of Hesitant Fuzzy Soft Sets and Rough Sets 
         for Uncertainty Modelling},
  author={Jahanvi and Nishad, Dinesh Kumar and Singh, Rashmi and 
          Khalid, Saifullah},
  year={2025},
  note={Dataset and MATLAB code available at: 
        https://github.com/dineshnishad1234/Integrating-Hesitant-Fuzzy-Soft-Sets-.git
}
Support
For MATLAB-specific questions:
Email: dknishad_tech@dsmnru.ac.in
GitHub Issues: 
For general dataset questions:
Corresponding Authors:
Rashmi Singh (rsingh7@amity.edu)
Saifullah Khalid (skhalid.sudan@yahoo.com)

