function metadata = extract_metadata(rawData, params, filename)

%% Create SESSION Snippet (LgA only)

savename = upper(filename);

% Look for ShA/LgA pattern followed by numbers
match = regexp(savename, '(LGA|SHA)\d+', 'match', 'once');
if ~isempty(match)
    snippet = match;
else
    % fallback if pattern not found
    snippet = erase(savename, '.TXT');
end

metadata.sessionSnippet = string(snippet);

subj_pos = strmatch('Subject', rawData);
box_pos = strmatch('Box', rawData);
group_pos = strmatch('Group', rawData);
sex_pos = strmatch('Experiment', rawData);

animalnames = rawData(subj_pos + 1);
boxes = rawData(box_pos + 1);
groups = rawData(group_pos + 1);
sex = rawData(sex_pos + 1);

keep_idx = true(size(animalnames));

for p = params.excludePrefixes
    keep_idx = keep_idx & ~startsWith(animalnames, p, 'IgnoreCase', true);
end

metadata.subjects = animalnames(keep_idx);
metadata.sessionSnippet = string(snippet);
metadata.boxes = boxes(keep_idx);
metadata.groups = groups(keep_idx);
metadata.sex = sex(keep_idx);
metadata.keepMask = keep_idx;
metadata.subjectPositions = subj_pos;
metadata.numSubjects = sum(keep_idx);

end
