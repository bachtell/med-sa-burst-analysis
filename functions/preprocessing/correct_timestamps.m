function ts = correct_timestamps(filteredC)

prefilter = [];

for i = 1:length(filteredC)

    if fix(filteredC(i)) > 1 && mod(abs(filteredC(i)),1) > 0
        prefilter(end+1,1) = filteredC(i);
    end

end

ts = [floor(prefilter(1)) mod(abs(prefilter(1)),1)];

tmp = floor(prefilter(1));

for i = 2:length(prefilter)

    tmp = tmp + floor(prefilter(i));

    ts(end+1,:) = [tmp mod(abs(prefilter(i)),1)];

end

end
