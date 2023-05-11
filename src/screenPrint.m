function screenPrint(mode,varargin)
%% Function description:
% This function formats command window output.
%
%% Syntax:
%  screenPrint(mode)
%  screenPrint(mode, string)
%
%% Input:
%  mode     - Formatting mode (string)
%  string   - Output string


switch mode
    case 'StartUp'
        titleStr = varargin{1};
        fprintf('\n*************************************************************');
        fprintf(['\n                 ',titleStr,' \n']);
        fprintf('*************************************************************\n');
    case 'Termination'
        titleStr = varargin{1};
        fprintf('\n*************************************************************');
        fprintf(['\n                 ',titleStr,' \n']);
        fprintf('*************************************************************\n');
    case 'SegmentStart'
        titleStr = varargin{1};
        fprintf('\n------------------------------------------------------');
        fprintf(['\n     ',titleStr,' \n']);
        fprintf('------------------------------------------------------\n');
    case 'Step'
        titleStr = varargin{1};
        fprintf([' -> ',titleStr,'\n']);
    case 'SubStep'
        titleStr = varargin{1};
        fprintf(['    - ',titleStr,'\n']);
    case 'SegmentEnd'
        fprintf('\n------------------------------------------------------\n');
end