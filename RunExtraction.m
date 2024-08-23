%% % run this code from the folder containing the Nelly package
% (should have subdirectory test_data)
clear variables;
close all; 
clc;
datafolder= '..\..\Data\Par extraction test';% data folder
datafilename='Ch2_05042023_295data.txt'; % name of data file
parameterfilename='parameterC2_295_DG.json'; % name of settings file
%fulldatapath= strcat(datafolder,'\',datafilename); % name of file to read
fnames = dir;
%path
%expected_files = {'test_data\parameter_file.json'};
%assert(numel(setdiff(expected_files, {fnames.name})) == 0, ...
   % 'parameter file is required')

addpath('utilities')

%% % sample cell configuration (quartz-sample-quartz)
% ref cell configuration ( quartz-air-quartz)
[f, tf_spec, freq, func] = Calculate(datafolder,datafilename,...
        strcat(datafolder,'\',parameterfilename));


function [fig, tf_spec, freq, func] = Calculate(folder,data_file, input_file)
fulldatapath= strcat(folder,'\',data_file);
d_smp = importdata(fulldatapath,'\t',1);
t_ref= d_smp.data(:,1); A_ref = d_smp.data(:,2);
t_smp= d_smp.data(:,1); A_smp = d_smp.data(:,3);

[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func]...
    = nelly_main(input_file, t_smp, A_smp, t_ref, A_ref);
alpha=4*pi*imag(n_fit).*freq*33.35641;
OutputMatrix = horzcat(transpose(freq),transpose(real(n_fit)),transpose(imag(n_fit)),transpose(alpha));
fig = figure();
subplot(1,2,1)
plot(freq, real(n_fit))
hold on
xlabel('Frequency (THz)')
ylabel('n')
axis([-inf inf 1 2.5])

subplot(1,2,2)
plot(freq, alpha)
hold on
xlabel('Frequency (THz)')
ylabel('\alpha')
HeaderRow={'freq','index','kappa','alpha'}; % Header for output. Later wavenames in Igor
FileSaveName=strcat(folder,'\','NellyOutput_',data_file); % Name of output file
Celldata=num2cell(OutputMatrix); % Converts data to cell, inorder to combine
                              % with header
Output=cell2table(Celldata,'VariableNames',HeaderRow);% Converts to table 
                                                 % for easy file writing
writetable(Output,FileSaveName,'Delimiter','\t');
end
