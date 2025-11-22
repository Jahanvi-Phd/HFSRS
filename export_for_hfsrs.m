function export_for_hfsrs(data)
% EXPORT_FOR_HFSRS Exports dataset into HFSRS-compatible format for further analysis.
%
% Input:
%   data - Table containing PV fault detection dataset
%
% Output:
%   Saves 'hfsrs_input.mat' containing structured data for HFSRS algorithms

    % Initialize structure
    hfsrs_input = struct();

    % Module IDs
    hfsrs_input.Module_ID = data.Module_ID;

    % Hesitant fuzzy elements for each indicator
    hfsrs_input.Voltage_Drop_HFE = data.Voltage_Drop_HFE;
    hfsrs_input.Temp_Rise_HFE = data.Temp_Rise_HFE;
    hfsrs_input.Irradiance_Loss_HFE = data.Irradiance_Loss_HFE;

    % Fault labels and types
    hfsrs_input.Fault_Label = data.Fault_Label;
    hfsrs_input.Fault_Type = data.Fault_Type;

    % Save to MAT file
    save('hfsrs_input.mat', 'hfsrs_input', '-v7.3');

    fprintf('✓ Data exported: hfsrs_input.mat\n');
end