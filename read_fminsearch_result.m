function [param, obj] = read_fminsearch_result(filepath)

fid = fopen(filepath);
if fid == -1
    error('file not exist')
end

% read the txt file, and use the new line to replace the old one
% until the end of the file
while ~feof(fid)
    line = fgetl(fid);
end

% convert the last line of the file into a one-row cell array,
% where each column is splited by tab
line = regexp( deblank(line), '\t', 'split' );

obj = str2num(line{2});
param = cellfun( @str2num, line(4:end) );

end
