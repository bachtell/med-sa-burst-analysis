function sa = compute_sa_metrics(events)

cl = events.correct;
ic = events.incorrect;
tol = events.timeout;

sa.correctCount = length(cl);
sa.incorrectCount = length(ic);
sa.timeoutCount = length(tol);

sa.totalPresses = sa.correctCount + sa.incorrectCount;

if sa.totalPresses > 0

    sa.leverDiscrimination = ...
        (sa.correctCount / sa.totalPresses) * 100;

else

    sa.leverDiscrimination = NaN;

end

if sa.correctCount > 0

    sa.normTimeout = sa.timeoutCount / sa.correctCount;

else

    sa.normTimeout = NaN;

end

cl_min = cl / 6000;

%% Inter-Infusion Intervals

cl_intervals = diff(cl) / 6000;

if ~isempty(cl_intervals)
    sa.avgInterInfusionInterval = mean(cl_intervals);
else
    sa.avgInterInfusionInterval = NaN;
end

sa.correct15 = sum(cl_min <= 15);
sa.correct30 = sum(cl_min <= 30);

if length(cl) >= 1
    sa.lat1 = cl(1) / 6000;
else
    sa.lat1 = NaN;
end

if length(cl) >= 3
    sa.lat3 = cl(3) / 6000;
else
    sa.lat3 = NaN;
end

if length(cl) >= 5
    sa.lat5 = cl(5) / 6000;
else
    sa.lat5 = NaN;
end

%% Load Times: Time required to progress from first infusion to third or fifth infusion

if sa.lat1 == 120 || sa.lat3 == 120
   sa.loadLat3 = NaN;

else
   sa.loadLat3 = sa.lat3 - sa.lat1;

end

if sa.lat1 == 120 || sa.lat5 == 120
   sa.loadLat5 = NaN;

else
   sa.loadLat5 = sa.lat5 - sa.lat1;

end

end