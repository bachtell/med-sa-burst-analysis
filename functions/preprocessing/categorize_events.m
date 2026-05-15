function events = categorize_events(ts, params)

correct = [];
incorrect = [];
timeout = [];
infusion = [];

for i = 1:size(ts,1)

    code = ts(i,2);

    if code > params.correctRange(1) && code < params.correctRange(2)

        correct(end+1,1) = ts(i,1);

    elseif code > params.incorrectRange(1) && code < params.incorrectRange(2)

        incorrect(end+1,1) = ts(i,1);

    elseif code > params.timeoutRange(1) && code < params.timeoutRange(2)

        timeout(end+1,1) = ts(i,1);

    elseif code > params.infusionRange(1) && code < params.infusionRange(2)

        infusion(end+1,1) = ts(i,1);

    end

end

events.correct = correct;
events.incorrect = incorrect;
events.timeout = timeout;
events.infusion = infusion;

end
