function data = load_pv_dataset(filename)
    if nargin < 1
        filename = 'PV_Fault_Detection_Dataset.csv';
    end

    if ~isfile(filename)
        error('Dataset file not found: %s', filename);
    end

    data = readtable(filename, 'TextType', 'string');
    fprintf('✓ Dataset loaded: %d modules, %d columns\n', height(data), width(data));
end
