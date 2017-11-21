function badsResult = read_bads_result(resultDir)
% the main function goes here

myBadsRes = dir(resultDir);
myBadsRes = myBadsRes([myBadsRes.isdir] == 0);
nfile = numel(myBadsRes);
for ifile = 1:nfile
    if ~ strcmp(myBadsRes(ifile).name, '.DS_Store')
        [param, obj, iter, evaltime] = solo_bads_result(fullfile(resultDir, myBadsRes(ifile).name));
        best_params{ifile} = param;
        sum_obj(ifile) = obj;
        total_iter(ifile) = iter;
        total_evaltime{ifile} = evaltime;
    end
end

badsResult = table(sum_obj', total_iter', total_evaltime', best_params' ...
    , 'VariableNames', {'sum_obj', 'total_iter', 'total_evaltime', 'best_params'});
badsResult = badsResult(badsResult.total_iter ~= 0, :);     % to remove the blank row caused by '.DS_Store'

end

function [param, obj, iter, evaltime] = solo_bads_result(filepath)
% the sub-function used to process each file

fid = fopen(filepath);
if fid == -1
    error('file not exist')
end

% read the txt file, and use the new line to replace the old one
% until the end of the file
line = fgetl(fid);
line_minus_one = [];
while ~feof(fid)
    line_minus_two = line_minus_one;
    line_minus_one = line;
    line = fgetl(fid);
end

% convert the last line of the file into a one-row cell array,
% where each column is splited by tab
if regexp(line, '.*bads.*done!')
    line = line_minus_two;      % line_minus_one is \n
end

line = regexp( deblank(line), '\t', 'split' );
evaltime = line{1};
obj = str2double(line{3});
iter = str2double(line{4});
param = cellfun( @str2num, line(5:end) );

fclose(fid);
end
