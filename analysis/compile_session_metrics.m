% Title: compile_session_metrics.m
%
% Description:
% Converts the output from run_analysis.m
% (MultiStrain_Burst_SA_Summary.txt)
% into a wide-format Excel workbook with:
%
%   • one sheet per behavioral metric
%   • sessions ordered consistently
%   • optional interpolation of missing values
%   • subject filtering based on missing data
%
% Compatible with:
%   run_analysis.m
%   build_output_table.m
%
% Date: 05/15/26

clc;
clear;

%% Select Input File

[inputFile, inputPath] = uigetfile( ...
    '*.txt', ...
    'Select MultiStrain_Burst_SA_Summary.txt');

if isequal(inputFile, 0)

    disp('User cancelled file selection.');
    return;

end

fullPath = fullfile(inputPath, inputFile);

%% Import Table

opts = detectImportOptions( ...
    fullPath, ...
    'Delimiter', '\t');

opts = setvartype( ...
    opts, ...
    {'RAT_ID', 'SESSION', 'GROUP', 'SEX'}, ...
    'string');

T = readtable(fullPath, opts);

%% Define Metadata + Data Columns

metadataCols = { ...
    'RAT_ID', ...
    'SESSION', ...
    'GROUP', ...
    'SEX'};

dataCols = setdiff( ...
    T.Properties.VariableNames, ...
    metadataCols);

%% Define Session Order

shaSessions = compose("SHA%d", 1:10);
lgaSessions = compose("LGA%d", 1:10);

sessionOrder = [shaSessions, lgaSessions];

%% Filter Rats with Excessive Missing Correct Values

T_correct = T( ...
    ismember(T.SESSION, sessionOrder), :);

missingCorrect = T_correct(:, ...
    {'RAT_ID', 'SESSION', 'Correct'});

pivotCorrect = unstack( ...
    missingCorrect, ...
    'Correct', ...
    'SESSION');

missingCounts = sum( ...
    ismissing(pivotCorrect{:, 2:end}), ...
    2);

validRats = pivotCorrect.RAT_ID( ...
    missingCounts <= 3);

T = T(ismember(T.RAT_ID, validRats), :);

%% Initialize Wide Table

rats = unique(T.RAT_ID);

wideTable = table( ...
    rats, ...
    'VariableNames', {'RAT_ID'});

%% Add Metadata Columns

[~, firstIdx] = unique( ...
    T.RAT_ID, ...
    'stable');

metaSubset = T(firstIdx, ...
    {'RAT_ID', 'GROUP', 'SEX'});

wideTable = outerjoin( ...
    wideTable, ...
    metaSubset, ...
    'Keys', 'RAT_ID', ...
    'MergeKeys', true, ...
    'Type', 'left');

%% Convert Long → Wide Format

for i = 1:length(sessionOrder)

    currentSession = sessionOrder(i);

    sessionRows = T.SESSION == currentSession;

    if ~any(sessionRows)
        continue;
    end

    T_session = T(sessionRows, :);

    T_subset = T_session(:, ...
        [{'RAT_ID'}, dataCols]);

    newNames = strcat( ...
        dataCols, ...
        "_", ...
        currentSession);

    T_subset.Properties.VariableNames(2:end) = ...
        newNames;

    wideTable = outerjoin( ...
        wideTable, ...
        T_subset, ...
        'Keys', 'RAT_ID', ...
        'MergeKeys', true, ...
        'Type', 'full');

end

%% Reorder Variables by Metric → Session

baseCols = {'RAT_ID', 'GROUP', 'SEX'};

orderedVariables = baseCols;

for d = 1:length(dataCols)

    metric = dataCols{d};

    for s = 1:length(sessionOrder)

        colName = sprintf( ...
            '%s_%s', ...
            metric, ...
            sessionOrder{s});

        if ismember( ...
                colName, ...
                wideTable.Properties.VariableNames)

            orderedVariables{end+1} = colName; %#ok<AGROW>

        end

    end

end

wideTable = wideTable(:, orderedVariables);

%% Metrics Excluded from Interpolation

noInterpolation = { ...
    'Avg_Burst_Duration', ...
    'Avg_Burst_Presses', ...
    'Avg_Inter_Burst_Interval'};

%% Interpolate Missing Values

for d = 1:length(dataCols)

    metric = dataCols{d};

    if ismember(metric, noInterpolation)
        continue;
    end

    colIdx = find(contains( ...
        wideTable.Properties.VariableNames, ...
        [metric '_']));

    if isempty(colIdx)
        continue;
    end

    M = wideTable{:, colIdx};

    for r = 1:size(M, 1)

        row = M(r, :);

        nanIdx = isnan(row);

        if any(nanIdx)

            validIdx = find(~nanIdx);

            if length(validIdx) >= 2

                M(r, nanIdx) = interp1( ...
                    validIdx, ...
                    row(validIdx), ...
                    find(nanIdx), ...
                    'linear', ...
                    NaN);

            end

        end

    end

    wideTable{:, colIdx} = M;

end

%% Define Output File

outputFile = fullfile( ...
    inputPath, ...
    'Burst_SA_Summary.xlsx');

%% Ordered Metric Export

orderedMetrics = { ...
    'Correct', ...
    'Incorrect', ...
    'Timeout', ...
    'Norm_TO', ...
    'Lev_Discrimination', ...
    'Lat_1st', ...
    'Lat_3rd', ...
    'Lat_5th', ...
    'Load_Lat3', ...
    'Load_Lat5', ...
    'Burst_Episodes', ...
    'Burst_Infusions', ...
    'Burst_Ratio', ...
    'Avg_Burst_Presses', ...
    'Avg_Burst_Duration', ...
    'Avg_Inter_Burst_Interval', ...
    'Avg_Inter_Inf_Interval'};

%% Write One Sheet per Metric

for d = 1:length(orderedMetrics)

    metric = orderedMetrics{d};

    if ~ismember(metric, dataCols)
        continue;
    end

    colsForMetric = startsWith( ...
        wideTable.Properties.VariableNames, ...
        metric);

    T_metricData = wideTable(:, colsForMetric);

    sessionHeaders = erase( ...
        T_metricData.Properties.VariableNames, ...
        metric + "_");

    T_metricData.Properties.VariableNames = ...
        sessionHeaders;

    % Round numeric values

    T_metricData = varfun( ...
        @(x) round(x, 2), ...
        T_metricData);

    % Add metadata columns

    T_metric = [ ...
        wideTable(:, baseCols), ...
        T_metricData];

    % Write Excel sheet

    writetable( ...
        T_metric, ...
        outputFile, ...
        'Sheet', metric);

end

%% Completion Message

fprintf( ...
    '\n✅ Excel workbook saved:\n%s\n', ...
    outputFile);