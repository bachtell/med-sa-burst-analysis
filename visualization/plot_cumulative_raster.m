function plot_cumulative_raster(dataDir, repSubjects, sessionFiles, outputName)
% PLOT_CUMULATIVE_RASTER
% Generates cumulative raster plots for representative subjects
% across sessions (e.g., LgA1 vs LgA10)
%
% Inputs:
%   dataDir       - folder containing Med-PC txt files
%   repSubjects   - cell array of subject IDs
%   sessionFiles  - struct with fields:
%                       .LgA1
%                       .LgA10
%   outputName    - output figure filename
% ============================
% SETUP
% ============================
cd(dataDir);

results_dir = fullfile(dataDir, 'Results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

numSubjects = length(repSubjects);

% colors (repeat-safe default colormap)
colors = lines(numSubjects);

% session layout (top = LgA1, bottom = LgA10)
session_labels = {'LgA10', 'LgA1'};
y_offset = [1 2];

% ============================
% FIGURE
% ============================
figure
tiledlayout(ceil(numSubjects/2), 2, ...
    'TileSpacing','compact','Padding','compact');

for i = 1:numSubjects
    nexttile
    hold on

    target_subject = repSubjects{i};
    color = colors(i,:);

    % loop over sessions
    for s = 1:2
        files = sessionFiles{s};
        found = false;

        for f = 1:length(files)
            filename = files(f).name;
            b = textread(filename,'%s','delimiter',['\t' ':' ' ']);

            subj_indices = find(strcmp(b,'Subject'));

            subj_start = [];
            subj_end = [];

            for j = 1:length(subj_indices)
                if j < length(subj_indices)
                    range = subj_indices(j):subj_indices(j+1)-1;
                else
                    range = subj_indices(j):length(b);
                end

                if any(strcmp(b(range), target_subject))
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

        if ~found
            warning('Subject %s not found in %s', target_subject, session_labels{s});
            continue
        end

        % ============================
        % EXTRACT C ARRAY
        % ============================
        Crow = [];

        for k = subj_start:subj_end-1
            if startsWith(b{k}, 'C') && strcmp(b{k+1}, '0')
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

        % ============================
        % RECONSTRUCT TIMESTAMPS
        % ============================
        prefilter = C(fix(C) > 1 & mod(abs(C),1) > 0);

        if isempty(prefilter)
            continue
        end

        ts = [floor(prefilter(1)) mod(abs(prefilter(1)),1)];
        t = floor(prefilter(1));

        for k = 2:length(prefilter)
            t = t + floor(prefilter(k));
            ts(end+1,:) = [t mod(abs(prefilter(k)),1)];
        end

        % ============================
        % FILTER CORRECT LEVER
        % ============================
        cl = ts(ts(:,2) > 0.099 & ts(:,2) < 0.101, 1);
        cl_min = cl / 6000;

        % limit to 360 min
        cl_min = cl_min(cl_min <= 360);

        % ============================
        % PLOT RASTER
        % ============================
        for k = 1:length(cl_min)
            plot([cl_min(k) cl_min(k)], ...
                 [y_offset(s)-0.4 y_offset(s)+0.4], ...
                 'Color', color, 'LineWidth', 1);
        end
    end

    title(repSubjects{i}, 'Interpreter','none')
    xlim([0 360])
    ylim([0 3])

    % Remove y-axis ticks
    yticks([])

    % Add session labels manually to left side
    text(-15, y_offset(1), 'LgA10', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 10);

    text(-15, y_offset(2), 'LgA1', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 10);

    ax = gca;
    ax.YColor = 'none';

    box off
    set(gca,'FontSize',11)

end

xlabel('Time (min)')
ylabel('Session')

saveas(gcf, fullfile(results_dir, outputName));
end