function row = build_output_table(...
    metadata, subjectIndex, sa, burst)

row = table();

row.RAT_ID = string(metadata.subjects(subjectIndex));
row.SESSION = metadata.sessionSnippet;
row.BOX = string(metadata.boxes(subjectIndex));
row.GROUP = string(metadata.groups(subjectIndex));
row.SEX = string(metadata.sex(subjectIndex));

row.Correct = sa.correctCount;
row.Cor_15 = sa.correct15;
row.Cor_30 = sa.correct30;

row.Incorrect = sa.incorrectCount;

row.Timeout = sa.timeoutCount;
row.Norm_TO = sa.normTimeout;

row.Lev_Discrimination = sa.leverDiscrimination;

row.Lat_1st = sa.lat1;
row.Lat_3rd = sa.lat3;
row.Lat_5th = sa.lat5;

row.Load_Lat3 = sa.loadLat3;
row.Load_Lat5 = sa.loadLat5;

row.Burst_Episodes = burst.count;
row.Avg_Burst_Presses = burst.avgPresses;
row.Avg_Burst_Duration = burst.avgDuration;
row.Burst_Infusions = burst.totalBurstInfusions;
row.Burst_Ratio = burst.burstInfusionRatio;
row.Avg_Inter_Burst_Interval = burst.avgInterval;
row.Avg_Inter_Inf_Interval = sa.avgInterInfusionInterval;

end
