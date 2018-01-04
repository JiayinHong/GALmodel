function param = parsePVPairs(names, defaults, validators, pvs, varargin) 
% Parse Parameter Value inputs & return structure of parameters
% param = parsePVPairs(names, defaults, validators, pvs) 
%
% All inputs are cell arrays. names contains the names of the parameters,
% defaults - their default values, validators - the function handles each
% of which validate the input value, and pvs - the set of parameter value
% inputs. param is a structure with a field corresponding to each named
% parameter.
%
% param = parsePVPairs(..., 'caseSensitive', true) enforces a case sensitive
% match. Default = false
%
% param = parsePVPairs(..., 'partialMatch', false) enforces a full
% parameter match. Default = true
%
% param = parsePVPairs(..., 'keepUnmatched', false) enforces that all
% paramters match those listed in names. Default = false
%
% param = parsePVPairs(..., 'pvOutput', true) returns output as a cell
% array of parameter value pairs. Default = false 

% Copyright 2014 MathWorks, Inc.

if ~isempty(varargin) % To prevent infinite recursion
    localParam = parsePVPairs({'caseSensitive','partialMatch','keepUnmatched','pvOutput'},...
        {false, true, false, false},{@islogical, @islogical, @islogical, @islogical}, varargin);
else
    localParam.caseSensitive = false;
    localParam.partialMatch = true;
    localParam.keepUnmatched = true;
    localParam.pvOutput = false;
end

if nargin < 2 || isempty(defaults), defaults = repmat({[]},1,length(names)); end
if nargin < 3 || isempty(validators), validators = repmat({{}},1,length(names)); end    

p = inputParser;
for i = 1:length(names)
    if ~isempty(validators{i})
        p.addParamValue(names{i},defaults{i},validators{i});
    else
        p.addParamValue(names{i},defaults{i});
    end
end
p.CaseSensitive = localParam.caseSensitive;
p.PartialMatching = localParam.partialMatch;
p.KeepUnmatched = localParam.keepUnmatched;
p.parse(pvs{:});
param = p.Results;

if localParam.pvOutput
    param = [fieldnames(param)';struct2cell(param)'];
    param = param(:)';
end