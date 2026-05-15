function plot_cumulative_records( ...
    dataDir, ...
    repSubjects, ...
    sessionFiles, ...
    outputName)

% PLOT_CUMULATIVE_RECORDS
%
% Generates cumulative response records for representative subjects
% across sessions (e.g., LgA1 vs LgA10)
%
% Inputs:
%   dataDir
%   repSubjects
%   sessionFiles
%   outputName

%% Setup

cd(dataDir);

results_dir = fullfile(dataDir, 'Results');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

numSubjects = length(repSubjects);

lineStyles = {'--','-'};
sessionLabels = {'LgA1','LgA10'};

%% Figure

figure( ...
    'Units','normalized', ...
    'Position',[0.05 0.1 0.9 0.4]);

tiledlayout(1, numSubjects, ...
    'TileSpacing','compact', ...
    'Padding','compact');

%% Loop Through Subjects

for i = 1:numSubjects

    nexttile
    hold on

    target_subject = repSubjects{i};

    %% Loop Through Sessions

    for s = 1:2

        files = sessionFiles{s};

        found = false;

        %% Search Files

        for f = 1:length(files)

            filename = files(f).name;

            b = textread(filename, '%s', ...
                'delimiter', ['\t' ':' ' ']);

            subj_indices = find(strcmp(b,'Subject'));

            subj_start = [];
            subj_end = [];

            %% Find Subject

            for j = 1:length(subj_indices)

                if j < length(subj_indices)

                    range = subj_indices(j):subj_indices(j+1)-1;

                else

                    range = subj_indices(j):length(b);

                end

                if any(strcmpi( ...
                        strtrim(b(range)), ...
                        strtrim(target_subject)))

                    subj_start = subj_indices(j);

                    if j < length(subj_indices)

                        subj_end = subj_indices(j+1)-1;

                    else

                        subj_end = length(b);

                    end

                    found = true;
                    break

                end
            end

            if found
                break
            end
        end

        %% Subject Not Found

        if ~found

            warning( ...
                'Subject %s not found in %s', ...
                target_subject, ...
                sessionLabels{s});

            continue

        end

        %% Extract C Array

        Crow = [];

        for k = subj_start:subj_end-1

            if startsWith(b{k},'C') && strcmp(b{k+1},'0')

                Crow(end+1) = k;

            end
        end

        if isempty(Crow)

            warning('No C events for %s', target_subject);
            continue

        end

        start_idx = Crow(1)+1;
        end_idx = subj_end;

        C = [];

        for k = start_idx:end_idx-1

            val = str2double(b{k});

            if ~isnan(val)

                C(end+1) = val;

            end
        end

        %% Reconstruct Timestamps

        prefilter = C( ...
            fix(C)>1 & mod(abs(C),1)>0);

        if isempty(prefilter)
            continue
        end

        ts = [ ...
            floor(prefilter(1)) ...
            mod(abs(prefilter(1)),1)];

        t = floor(prefilter(1));

        for k = 2:length(prefilter)

            t = t + floor(prefilter(k));

            ts(end+1,:) = [ ...
                t ...
                mod(abs(prefilter(k)),1)];

        end

        %% Correct Lever Responses

        cl = ts( ...
            ts(:,2)>0.099 & ts(:,2)<0.101, ...
            1);

        cl_min = cl / 6000;

        %% Sort and Compute Cumulative Responses

        cl_min_sorted = sort(cl_min);

        cumulative = 1:length(cl_min_sorted);

        %% Plot

        plot( ...
            cl_min_sorted, ...
            cumulative, ...
            lineStyles{s}, ...
            'LineWidth',2, ...
            'DisplayName',sessionLabels{s});

    end

    %% Formatting

    title(target_subject, ...
        'Interpreter','none')

    xlim([0 720])

    box off

    set(gca,'FontSize',11)

    if i == 1

        legend('Location','northwest')

    end

end

xlabel('Time (min)')

ylabel('Cumulative Correct Lever Responses')

%% Save Figure

saveas(gcf, ...
    fullfile(results_dir, outputName));

end