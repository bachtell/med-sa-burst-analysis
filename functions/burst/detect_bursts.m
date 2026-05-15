function burstData = detect_bursts(cl, params)

%% Initialize Output Structure

burstData.starts = [];
burstData.ends = [];

burstData.counts = [];
burstData.durations = [];
burstData.intervals = [];

%% Exit if Empty

if isempty(cl)
    return;
end

%% Initialize First Burst

burstTemp = cl(1);
burstCount = 0;

%% Main Burst Detection Loop

for k = 2:length(cl)

    % Check whether response belongs
    % to current burst

    if cl(k) - burstTemp(end) <= params.burstThreshold
        burstTemp(end+1) = cl(k);

    else

        % Save burst if criterion met

        if length(burstTemp) >= params.minBurstResponses
            burstCount = burstCount + 1;
            burstData.starts(burstCount) = burstTemp(1);
            burstData.ends(burstCount) = burstTemp(end);
            burstData.counts(burstCount) = length(burstTemp);
            burstData.durations(burstCount) = ...
                (burstTemp(end) - burstTemp(1)) / 6000;

            % Inter-burst interval

            if burstCount > 1
                burstData.intervals(burstCount - 1) = ...
                    (burstData.starts(burstCount) - ...
                    burstData.ends(burstCount - 1)) / 6000;

            end

        end

        % Start next burst

        burstTemp = cl(k);

    end

end

%% Process Final Burst

if length(burstTemp) >= params.minBurstResponses
    burstCount = burstCount + 1;
    burstData.starts(burstCount) = burstTemp(1);
    burstData.ends(burstCount) = burstTemp(end);
    burstData.counts(burstCount) = length(burstTemp);
    burstData.durations(burstCount) = ...
        (burstTemp(end) - burstTemp(1)) / 6000;

    if burstCount > 1
        burstData.intervals(burstCount - 1) = ...
            (burstData.starts(burstCount) - ...
            burstData.ends(burstCount - 1)) / 6000;

    end

end

end