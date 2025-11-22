function visualize_dataset(data)
% VISUALIZE_DATASET Creates visualization plots for the PV fault detection dataset.
%
% Input:
%   data - Table containing PV fault detection dataset
%
% Example:
%   visualize_dataset(data);

    % Fault distribution (Healthy vs Faulty)
    figure('Name','PV Fault Detection Visualizations','Position',[100,100,1000,600]);

    subplot(2,2,1);
    categories = categorical(data.Fault_Type);
    bar(countcats(categories));
    xticklabels(categories(categories~=categorical(missing)));
    xlabel('Fault Type');
    ylabel('Count');
    title('Fault Distribution');
    grid on;

    % Voltage Drop comparison
    subplot(2,2,2);
    boxplot([data.Voltage_Drop_Expert1, data.Voltage_Drop_Expert2, data.Voltage_Drop_Expert3], ...
            'Labels',{'Expert1','Expert2','Expert3'});
    ylabel('Voltage Drop');
    title('Voltage Drop by Experts');

    % Temperature Rise comparison
    subplot(2,2,3);
    boxplot([data.Temp_Rise_Expert1, data.Temp_Rise_Expert2, data.Temp_Rise_Expert3], ...
            'Labels',{'Expert1','Expert2','Expert3'});
    ylabel('Temperature Rise');
    title('Temperature Rise by Experts');

    % Irradiance Loss comparison
    subplot(2,2,4);
    boxplot([data.Irradiance_Loss_Expert1, data.Irradiance_Loss_Expert2, data.Irradiance_Loss_Expert3], ...
            'Labels',{'Expert1','Expert2','Expert3'});
    ylabel('Irradiance Loss');
    title('Irradiance Loss by Experts');

    sgtitle('PV Fault Detection Dataset Overview');
end