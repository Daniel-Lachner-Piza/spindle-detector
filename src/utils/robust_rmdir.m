function robust_rmdir(dirPath)
% Robust directory removal function for Windows
% This function handles common Windows issues with directory deletion

if ~exist(dirPath, 'dir')
    return; % Directory doesn't exist, nothing to do
end

try
    % First attempt: Standard MATLAB rmdir
    [success, msg] = rmdir(dirPath, 's');
    if success
        return; % Success, we're done
    end

    fprintf('Standard rmdir failed: %s\n', msg);
    fprintf('Attempting Windows-specific robust deletion...\n');

    % Second attempt: Use Windows rd command with force
    % The /s flag removes all subdirectories and files
    % The /q flag suppresses confirmation prompts
    cmd = sprintf('rd /s /q "%s"', dirPath);
    [status, result] = system(cmd);

    if status == 0
        fprintf('Successfully deleted directory using Windows rd command\n');
        return;
    end

    fprintf('Windows rd command failed: %s\n', result);

    % Third attempt: Force deletion using robocopy trick
    % This is a Windows-specific workaround that works by copying
    % an empty directory over the target directory
    tempEmptyDir = fullfile(tempdir, ['empty_' datestr(now, 'yyyymmdd_HHMMSS')]);
    mkdir(tempEmptyDir);

    try
        % Use robocopy to mirror an empty directory (effectively deleting content)
        cmd = sprintf('robocopy "%s" "%s" /mir /nfl /ndl /njh /njs', tempEmptyDir, dirPath);
        [status, result] = system(cmd);

        % Robocopy exit codes 0-7 are considered successful
        if status <= 7
            % Now try to remove the empty directory
            [success, msg] = rmdir(dirPath, 's');
            if success
                fprintf('Successfully deleted directory using robocopy method\n');
                rmdir(tempEmptyDir, 's'); % Clean up temp directory
                return;
            end
        end

        fprintf('Robocopy method failed: %s\n', result);

    catch ME
        fprintf('Robocopy method encountered error: %s\n', ME.message);
    end

    % Clean up temp directory
    try
        rmdir(tempEmptyDir, 's');
    catch
        % Ignore cleanup errors
    end

    % Fourth attempt: Manual recursive deletion from bottom up
    fprintf('Attempting manual recursive deletion...\n');
    manual_recursive_delete(dirPath);

catch ME
    fprintf('Error in robust_rmdir: %s\n', ME.message);
    fprintf('Manual intervention may be required to delete: %s\n', dirPath);
end
end

function manual_recursive_delete(dirPath)
% Manually delete directory contents recursively from bottom up
try
    % Get all contents
    contents = dir(fullfile(dirPath, '**', '*'));

    % Filter out '.' and '..' entries
    contents = contents(~ismember({contents.name}, {'.', '..'}));

    if isempty(contents)
        % Directory is empty, try to remove it
        [success, msg] = rmdir(dirPath);
        if ~success
            fprintf('Failed to remove empty directory %s: %s\n', dirPath, msg);
        end
        return;
    end

    % Sort by depth (deepest first) to delete from bottom up
    depths = cellfun(@(x) length(strfind(x, filesep)), {contents.folder});
    [~, sortIdx] = sort(depths, 'descend');
    contents = contents(sortIdx);

    % Delete files first, then directories
    for i = 1:length(contents)
        fullPath = fullfile(contents(i).folder, contents(i).name);

        if contents(i).isdir
            % Try to remove directory
            [success, msg] = rmdir(fullPath);
            if ~success
                fprintf('Failed to remove directory %s: %s\n', fullPath, msg);
                % Try to change permissions and retry
                try
                    fileattrib(fullPath, '+w', '', 's'); % Make writable
                    [success, msg] = rmdir(fullPath);
                    if ~success
                        fprintf('Still failed after changing permissions: %s\n', msg);
                    end
                catch
                    % Ignore permission change errors
                end
            end
        else
            % Try to delete file
            try
                % Make file writable first
                fileattrib(fullPath, '+w');
                delete(fullPath);
            catch ME
                fprintf('Failed to delete file %s: %s\n', fullPath, ME.message);
            end
        end
    end

    % Finally, try to remove the main directory
    [success, msg] = rmdir(dirPath);
    if ~success
        fprintf('Failed to remove main directory %s: %s\n', dirPath, msg);
    else
        fprintf('Successfully removed directory manually: %s\n', dirPath);
    end

catch ME
    fprintf('Error in manual_recursive_delete: %s\n', ME.message);
end
end