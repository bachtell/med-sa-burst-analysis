function burst = compute_burst_metrics(burstData, cl)

%% Initialize Output Structure

burst.count = length(burstData.counts);

burst.avgPresses = NaN;
burst.avgDuration = NaN;
burst.avgInterval = NaN;

burst.totalBurstInfusions = 0;
burst.burstInfusionRatio = NaN;

%% Compute Summary Metrics

if burst.count > 0
    burst.avgPresses = mean(burstData.counts);
    burst.avgDuration = mean(burstData.durations);

    if ~isempty(burstData.intervals)
        burst.avgInterval = mean(burstData.intervals);

    end

end

%% Burst Infusion Metrics

totalInfusions = length(cl);
if ~isempty(burstData.counts)
    burst.totalBurstInfusions = ...
        sum(burstData.counts);

end

if totalInfusions > 0
    burst.burstInfusionRatio = ...
        100 * (burst.totalBurstInfusions / totalInfusions);

end

%% Preserve Raw Burst Data

burst.starts = burstData.starts;
burst.ends = burstData.ends;

burst.counts = burstData.counts;
burst.durations = burstData.durations;
burst.intervals = burstData.intervals;

end