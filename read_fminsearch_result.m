function [param, obj] = read_fminsearch_result(filepath)

fid = fopen(filepath);
if ~fid
    error('file not exist')
    return
end
while ~feof(fid)
    line = fgetl(fid);
end

line = regexp( deblank(line), '\t', 'split' );

obj = str2num(line{2});
param = cellfun( @str2num, line(4:end) );

end
