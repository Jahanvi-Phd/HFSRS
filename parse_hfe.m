function values = parse_hfe(hfe_string)
% PARSE_HFE Converts a hesitant fuzzy element string to a numeric array.
%   Input:  hfe_string = "{0.131, 0.213, 0.234}"
%   Output: values = [0.131, 0.213, 0.234]

    hfe_string = strrep(hfe_string, '{', '');
    hfe_string = strrep(hfe_string, '}', '');
    parts = strsplit(hfe_string, ',');

    values = str2double(strtrim(parts));
end