function funcAuto_bzLFPfromDat(mouseName)
% ==========================================
% Batch run bz_LFPfromDat for all .dat files
% (just cd into each folder and run bz_LFPfromDat)
% save date folder into such format: YYYY-MM-DD for clear automation
%
% ==========================================

rootDir = fullfile('\\Buzsakilabspace\LabShare\JunH\Photometry', mouseName);
if ~isfolder(rootDir)
    error('Mouse folder not found: %s', rootDir);
end

fprintf('\n🐭 Mouse: %s\n', mouseName);

dateFolders = dir(rootDir);
dateFolders = dateFolders([dateFolders.isdir] & ~startsWith({dateFolders.name}, '.'));

for d = 1:numel(dateFolders)
    datePath = fullfile(rootDir, dateFolders(d).name);
    fprintf('\n📅 Date: %s\n', dateFolders(d).name);

    % Case 1: .dat directly in date folder
    cd(datePath);
    if ~isempty(dir('*.dat'))
        processSessionFolder(datePath);
    end

    % Case 2: .dat inside subfolders (task, pre, etc.)
    subFolders = dir(datePath);
    subFolders = subFolders([subFolders.isdir] & ~startsWith({subFolders.name}, '.'));
    for s = 1:numel(subFolders)
        subPath = fullfile(datePath, subFolders(s).name);
        cd(subPath);
        if ~isempty(dir('*.dat'))
            processSessionFolder(subPath);
        end
    end
end

fprintf('\n🎉 Finished processing all available sessions for %s.\n', mouseName);
end

% --- helper ---
function processSessionFolder(sessionPath)
    fprintf('   → Session: %s\n', sessionPath);
    [~, baseName] = fileparts(sessionPath);
    lfpPath = fullfile(sessionPath, [baseName '.lfp']);
    if exist(lfpPath, 'file')
        fprintf('     ⏭️  LFP already exists, skipping.\n');
        return;
    end
    try
        cd(sessionPath);
        fprintf('     ⚙️  Running bz_LFPfromDat ...\n');
        bz_LFPfromDat;   % <-- no input required
        fprintf('     ✅ Done: %s\n', baseName);
    catch ME
        fprintf('     ❌ Error in %s: %s\n', sessionPath, ME.message);
    end
end
