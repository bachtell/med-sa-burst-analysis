clc;
clear;

addpath('functions');
addpath('config');

params = analysis_parameters();

folder = uigetdir;
cd(folder);

files = dir(params.filePattern);

allResults = [];

for f = 1:length(files)

    filename = files(f).name;
    fprintf('Processing: %s\n', filename);
    rawData = load_medpc_file(filename);
    metadata = extract_metadata(rawData, params, filename);
    brackets = build_subject_brackets(rawData, metadata);
    sessionTable = [];

    for s = 1:metadata.numSubjects

        filteredC = extract_c_array(rawData, brackets(s,:));
        ts = correct_timestamps(filteredC);
        events = categorize_events(ts, params);
        saMetrics = compute_sa_metrics(events);
        burstData = detect_bursts(events.correct, params);
        burstMetrics = compute_burst_metrics( ...
            burstData, ...
            events.correct);
        resultRow = build_output_table(metadata, s, saMetrics, burstMetrics);

        sessionTable = [sessionTable; resultRow];

    end

    allResults = [allResults; sessionTable];

end

write_results(allResults);

fprintf('Analysis Complete.\n');
