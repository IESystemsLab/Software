function [ exitFlag ] = setProcessNodeParameters( Model, ParallelMachineCount, ProcessingTime)
% Set the production line variables for PennyFab simulations
%   this function will set the parallel machine count and process times for
%   the production line models found in the penny fab lessons. 
%   TO DO: Could be more generic, but currently just provides a means to
%   reset the simulations to their default state

if strcmp(Model, 'PennyFab_Stochastic') ==1
    set_param(strcat(Model, '/Head_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(1)));
    set_param(strcat(Model, '/Tail_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(2)));
    set_param(strcat(Model, '/Rimming'), 'NumberOfServers', num2str(ParallelMachineCount(3)));
    set_param(strcat(Model, '/Deburring'), 'NumberOfServers', num2str(ParallelMachineCount(4)));

    set_param(strcat(Model, '/ProcessTime_HeadStamping'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_TailStamping'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_Rimming'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_Deburring'), 'Distribution', 'Exponential');


    set_param(strcat(Model, '/ProcessTime_HeadStamping'), 'meanExp', num2str(ProcessingTime(1)));
    set_param(strcat(Model, '/ProcessTime_TailStamping'), 'meanExp', num2str(ProcessingTime(2)));
    set_param(strcat(Model, '/ProcessTime_Rimming'), 'meanExp', num2str(ProcessingTime(3)));
    set_param(strcat(Model, '/ProcessTime_Deburring'), 'meanExp', num2str(ProcessingTime(4)));
    
    exitFlag = 1;

elseif strcmp(Model, 'PennyFab_Deterministic') == 1
    set_param(strcat(Model, '/Head_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(1)));
    set_param(strcat(Model, '/Tail_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(2)));
    set_param(strcat(Model, '/Rimming'), 'NumberOfServers', num2str(ParallelMachineCount(3)));
    set_param(strcat(Model, '/Deburring'), 'NumberOfServers', num2str(ParallelMachineCount(4)));

    set_param(strcat(Model, '/Head_Stamping'), 'ServiceTime', num2str(ProcessingTime(1)));
    set_param(strcat(Model, '/Tail_Stamping'), 'ServiceTime', num2str(ProcessingTime(2)));
    set_param(strcat(Model, '/Rimming'), 'ServiceTime', num2str(ProcessingTime(3)));
    set_param(strcat(Model, '/Deburring'), 'ServiceTime', num2str(ProcessingTime(4)));
    
    exitFlag = 1;
elseif strcmp(Model, 'PennyFab_ArrivalProcess') == 1
    set_param(strcat(Model, '/Head_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(1)));
    set_param(strcat(Model, '/Tail_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(2)));
    set_param(strcat(Model, '/Rimming'), 'NumberOfServers', num2str(ParallelMachineCount(3)));
    set_param(strcat(Model, '/Deburring'), 'NumberOfServers', num2str(ParallelMachineCount(4)));

    set_param(strcat(Model, '/ProcessTime_HeadStamping'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_TailStamping'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_Rimming'), 'Distribution', 'Exponential');
    set_param(strcat(Model, '/ProcessTime_Deburring'), 'Distribution', 'Exponential');

    set_param(strcat(Model, '/ProcessTime_HeadStamping'), 'meanExp', num2str(ProcessingTime(1)));
    set_param(strcat(Model, '/ProcessTime_TailStamping'), 'meanExp', num2str(ProcessingTime(2)));
    set_param(strcat(Model, '/ProcessTime_Rimming'), 'meanExp', num2str(ProcessingTime(3)));
    set_param(strcat(Model, '/ProcessTime_Deburring'), 'meanExp', num2str(ProcessingTime(4)));
    
    exitFlag = 1;
elseif strcmp(Model, 'PennyFab') ==1
    try
        set_param(strcat(Model, '/Head_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(1)),'Distribution', 'Exponential','meanExp', num2str(ProcessingTime(1)));
        set_param(strcat(Model, '/Tail_Stamping'), 'NumberOfServers', num2str(ParallelMachineCount(2)),'Distribution', 'Exponential','meanExp', num2str(ProcessingTime(2)));
        set_param(strcat(Model, '/Rimming'), 'NumberOfServers', num2str(ParallelMachineCount(3)),'Distribution', 'Exponential','meanExp', num2str(ProcessingTime(3)));
        set_param(strcat(Model, '/Deburring'), 'NumberOfServers', num2str(ParallelMachineCount(4)),'Distribution', 'Exponential','meanExp', num2str(ProcessingTime(4)));
        exitFlag = 1;
    catch
        exitFlag = 0;
    end
    
else 
    exitFlag = 0;
    
end


end

