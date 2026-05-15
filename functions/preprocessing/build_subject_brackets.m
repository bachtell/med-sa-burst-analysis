function bracket = build_subject_brackets(rawData, metadata)

Crow = [];

for i = 1:length(rawData)-1

    if startsWith(rawData{i}, 'C') && strcmp(rawData{i+1}, '0')
        Crow(end+1) = i;
    end

end

orig_names = rawData(metadata.subjectPositions + 1);
nSubjects = length(orig_names);

subj_Cindex = zeros(nSubjects,1);

for s = 1:nSubjects

    cidx = find(Crow > metadata.subjectPositions(s), 1, 'first');

    subj_Cindex(s) = cidx;

end

orig_bracket = zeros(nSubjects,2);

for s = 1:nSubjects

    cStartRow = Crow(subj_Cindex(s));

    if s < nSubjects
        cEndRow = Crow(subj_Cindex(s+1)) - 1;
    else
        cEndRow = numel(rawData);
    end

    orig_bracket(s,:) = [cStartRow cEndRow];

end

bracket = orig_bracket(metadata.keepMask,:);

end
