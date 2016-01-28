function [ varargout ] = ProductionPlanning( varargin )
%[Production, Workforce, Overtime] = ProductionPlanning
% To run the ProductionSystem simulation afterward:
%[meanTotalProfit, varTotalProfit, meanServiceLevel, varServiceLevel ] = ProductionSystem(Production, Workforce, Overtime)

%rng default;
%addpath(genpath('C:\ILOG\CPLEX_Studio124\cplex\matlab'))
%addpath(genpath('C:\ILOG\CPLEX_Studio126\cplex\matlab')) %ISYE2014 Vlab
addpath(genpath('C:\ILOG\CPLEX_Enterprise_Server1262\CPLEX_Studio\cplex\matlab')) %ISYE2015 Vlab


%%%%%%%%%%%%%%%%PARAMETERS%%%%%%%%%%%%%%%%%%
nPeriods = 12;              %Number of Periods in Planning Horizon

%maxDem = 0;                 %Maximum Demand in Each Period
%minSales = 0;               %Minimum Sales Allowed in Each Period
meanDemand = [200 220 230 300 400 450 320 180 170 170 160 180];
%meanDemand = round((140-80)*rand(1,nPeriods) + 80); %Expected Demand in Each Period

revenue =   1000;           %Net profit per unit of product sold
holding =   10;             %Cost to hold one unit of product for one period
b = 12;                     %number of Worker-hours required to produce one unit
varLaborC = 35;             %cost of regular time in dollars per worker-hour
varLaborOC = 52.5;          %cost of overtime in dollars per worker-hour
IncreaseWorkforce = 15;     %cost to increase workforce by one worker-hour per period
DecreaseWorkforce = 9;      %cost to decrease workforce by one worker-hour per period

%Variables
%X_t                         %amount produced in period t
%St = meanDemand_t          %amount sold in period t
%I_t                        %inventory at end of t
I_0 = 0;                    %initial inventory (given as data)
%W_t                        %workforce in period t in worker-hours of regular time
W_0 = 168*15;               %initial workforce
%H_t                        %increase (hires) in workforce from period t-1
                                %to t in worker-hours
%F_t                        %decrease (fires) in workforce from period t-1
                                %to t in worker-hours
%O_t                        %overtime in period t in hours

try
%% Build Model
    PP = Cplex('PP');
    PP.Model.sense = 'minimize';

    nbVar = nPeriods*6;

%% Add Variables
%Note to Self 7/16: Need a Variable for each Variable type that indicates
%where it starts in the arry; i.e. WorkforceVarIndex = nPeriods then
%A(nPeriods*1+i) = 1 becomes A(WorkforceVarIndex+i);

%addCols (obj, A, lb, ub, ctype, colname)
    %Add Inventory Variables
    InventoryVarIndex = 0;
    for i =1:nPeriods
        PP.addCols(holding,[],0,[], 'C', strcat('I_', num2str(i)));
    end
    
    %Add Workforce Variables
    WorkforceVarIndex = nPeriods;
    for i =1:nPeriods
        PP.addCols(varLaborC,[],0,[], 'C', strcat('W_', num2str(i)));
    end
    
    %Add Overtime Variables
    OvertimeVarIndex = nPeriods*2;
    for i =1:nPeriods
        PP.addCols(varLaborOC,[],0,[], 'C', strcat('O_', num2str(i)));
    end
    
    %Add Hiring Variables
    HiringVarIndex = nPeriods*3;
    for i =1:nPeriods
        PP.addCols(IncreaseWorkforce,[],0,[], 'C', strcat('H_', num2str(i)));
    end
    
    %Add Firing Variables
    FiringVarIndex = nPeriods*4;
    for i =1:nPeriods
        PP.addCols(DecreaseWorkforce,[],0,[], 'C', strcat('F_', num2str(i)));
    end
    
    %Add Production Variables
    ProductionVarIndex = nPeriods*5;
    for i =1:nPeriods
        PP.addCols(0,[],0,[], 'C', strcat('X_', num2str(i)));
    end
    
%% Add Constraints
%addRows (lhs, A, rhs, rowname)

    % Add Inventory Constraints
    %Exception on First to accomodate Initial Inventory
    A = zeros(1,nbVar);
    A(1) = 1;
    A(ProductionVarIndex+1) = -1;
    PP.addRows(-meanDemand(1)+I_0, A, -meanDemand(1)+I_0, strcat('InvBal_', num2str(1)));
    
    %I_2 - I_1 - X_2 = -d_2;
    for i =2:nPeriods
        A = zeros(1,nbVar);
        A(InventoryVarIndex+i) = 1;
        A(InventoryVarIndex+i-1) = -1;
        A(ProductionVarIndex+i) = -1;
        PP.addRows(-meanDemand(i), A, -meanDemand(i), strcat('InvBal_', num2str(i)));
    end
    
    % Add WorkForce Constraints
    %Exception on First to accomodate Initial WorkForce
    %W_1 - W_0 - H_1 + F_1 = 0;
    A = zeros(1,nbVar);
    A(WorkforceVarIndex+1) = 1;
    A(HiringVarIndex+1) = -1;
    A(FiringVarIndex+1) = 1;
    PP.addRows(W_0, A, W_0, strcat('WorkForceBal_', num2str(1)));
    
    %W_2 - W_1 - H_2 + F_2 = 0
    for i =2:nPeriods
        A = zeros(1,nbVar);
        A(WorkforceVarIndex+i) = 1;
        A(WorkforceVarIndex+i-1) = -1;
        A(HiringVarIndex+i) = -1;
        A(FiringVarIndex+i) = 1;
        PP.addRows(0, A, 0, strcat('WorkForceBal_', num2str(i)));
    end
    
    % Add Production Constraints
    %12X_1 - W_1 - O_1 <= 0
    for i =1:nPeriods
        A = zeros(1,nbVar);
        A(ProductionVarIndex+i) = b;
        A(WorkforceVarIndex+i) = -1;
        A(OvertimeVarIndex+i) = -1;
        PP.addRows(-inf, A, 0, strcat('ProdBal_', num2str(i)));
    end
  
%% Solve Model    
%disp(PP.Model.A);
PP.solve();
PP.writeModel('PP.mps');

disp (' - Solution:');
{'Period', 'Demand', 'Inventory', 'Workforce', 'Overtime', 'Hiring', 'Firing', 'Production'}
for j = 1:nPeriods
    {strcat('Period ', num2str(j),': '), meanDemand(j), num2str(PP.Solution.x(nPeriods*0+j)), num2str(PP.Solution.x(nPeriods*1+j)), num2str(PP.Solution.x(nPeriods*2+j)), ...
        num2str(PP.Solution.x(nPeriods*3+j)), num2str(PP.Solution.x(nPeriods*4+j)), num2str(PP.Solution.x(nPeriods*5+j))}
end

fprintf('\n   Cost = %f\n', PP.Solution.objval);    
fprintf('\n   Profit = %f\n', revenue*sum(meanDemand) - PP.Solution.objval);
    
Solution = PP.Solution.x;

X_t = Solution(ProductionVarIndex+1:ProductionVarIndex+nPeriods);
W_t = Solution(WorkforceVarIndex+1:WorkforceVarIndex+nPeriods);
O_t = Solution(OvertimeVarIndex+1:OvertimeVarIndex+nPeriods);
%H_t = Solution(HiringVarIndex+1:HiringVarIndex+nPeriods);
%F_t = Solution(FiringVarIndex+1:FiringVarIndex+nPeriods);

varargout = {X_t, W_t, O_t};

catch m
    throw (m);      
end


























