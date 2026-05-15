function write_results(allResults)

outputFolder = 'Results';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

dateStr = datestr(now, 'mmddyyyy');

filename = fullfile(outputFolder, ...
    ['Burst_Summary_' dateStr '.txt']);

writetable(allResults, filename, ...
    'Delimiter', '\t', ...
    'FileType', 'text');

fprintf('Results saved to:\n%s\n', filename);

end
