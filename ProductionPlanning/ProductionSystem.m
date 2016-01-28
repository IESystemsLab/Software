
function [meanTotalProfit, varTotalProfit, meanServiceLevel, varServiceLevel ] = ProductionSystem(Production, Workforce, Overtime)
%[meanTotalProfit, varTotalProfit, meanServiceLevel, varServiceLevel ] = ProductionSystem(Production, Workforce, Overtime)
% runlength is the number of days of demand to simulate
% seed is the index of the substreams to use (integer >= 1)
% other is not used
%runlength must be greater than warmup period 

%rng default %resets the random number generator -- allows replicability


%%%%%%%%%%%%%%%%PARAMETERS%%%%%%%%%%%%%%%%%%
%Experiment
nPeriods = 12;                  %Number of Periods in Planning Horizon
nRepetitions = 20;              %Repetitions
warmup = 0;                     %length of warm up period
seed =1;
nPeriods = nPeriods+warmup;       
              

%maxDem = 0;                 %Maximum Demand in Each Period
%minSales = 0;               %Minimum Sales Allowed in Each Period
meanDemand = [200 220 230 300 400 450 320 180 170 170 160 180];
%meanDemand = round((140-80)*rand(1,nPeriods) + 80); %Expected Demand in Each Period
stdevDemand = 0*ones(1,nPeriods);

revenue =   1000;           %Net profit per unit of product sold
holding =   10;             %Cost to hold one unit of product for one period
backorder = 0;              %Cost to backorder one unit of product for one period
b = 12;                     %number of Worker-hours required to produce one unit
varB = 0;                   %variance of Worker-hours required to produce one unit
availability = [1, 1];    %Worker Availability between 90% and 100%
varLaborC = 35;             %cost of regular time in dollars per worker-hour
varLaborOC = 52.5;          %cost of overtime in dollars per worker-hour
IncreaseWorkforce = 15;     %cost to increase workforce by one worker-hour per period
DecreaseWorkforce = 9;      %cost to decrease workforce by one worker-hour per period
I_backorder = 0;            %Indicator if backordering is allowed


%%%%%%%% Decision Variables %%%%%%%%%
%Production;                         %amount produced in period t
%St = meanDemand_t          %amount sold in period t
%FGInv                        %inventory at end of t
initialFGI = 0;                    %initial inventory (given as data)
%Workforce;                        %workforce in period t in worker-hours of regular time
initialWorkforce = 168*15;               %initial workforce
%Hiring                       %increase (hires) in workforce from period t-1
                                %to t in worker-hours
%Firing                       %decrease (fires) in workforce from period t-1
                                %to t in worker-hours
%Overtime;                       %overtime in period t in hours




%%%%%%%%Variability%%%%%%%%%
    % Generate new streams for 
    [DemandStream, LeadTimeStream, ProductionStream] = RandStream.create('mrg32k3a', 'NumStreams', 3);

    % Set the substream to the "seed"
    DemandStream.Substream = seed;
    %LeadTimeStream.Substream = seed;
    ProductionStream.Substream = seed;

    % Generate demands
    OldStream = RandStream.setGlobalStream(DemandStream);
    %Dem = repmat(meanDemand,1,nRepetitions);
    Dem=normrnd(repmat(meanDemand, nRepetitions,1), repmat(stdevDemand,nRepetitions,1));
    
    % Generate lead times
    %RandStream.setGlobalStream(LeadTimeStream);
    %LT=poissrnd(meanLT, nRepetitions, nPeriods);
    
    %Generate Capacity: Create Variability In Capacity of Production System
    RandStream.setGlobalStream(ProductionStream);
    b = normrnd(b, varB, nRepetitions,nPeriods);
    availability = (availability(2)-availability(1))*rand(nRepetitions,nPeriods)+availability(1);
    
    RandStream.setGlobalStream(OldStream); % Restore previous stream

Output = zeros(2,nRepetitions);
Inv = zeros(nRepetitions, nPeriods);
for j =1:nRepetitions
    
    %Vector tracks outstanding orders. Row 1: day of delivery and row 2: quantity.
    FGInv = initialFGI;
    %Variables to estimate service level constraint.
    nUnits = 0;
    nLate = 0;

    TotalProfit = 0;
    
    for i=1:nPeriods
               
        %Receive Replenishment Orders
        
        %Adjust Workforce Levels
        if (i > warmup) && i > 1
            TotalProfit = TotalProfit - IncreaseWorkforce*max(Workforce(i)-Workforce(i-1),0) - DecreaseWorkforce*max(Workforce(i-1)-Workforce(i),0);
        elseif (i > warmup) && i == 1
            TotalProfit = TotalProfit - IncreaseWorkforce*max(Workforce(i)-initialWorkforce,0)- DecreaseWorkforce*max(initialWorkforce-Workforce(i),0);
        end
        
        
        %Production
        Production(i) = min(availability(j,i)*(Workforce(i)+Overtime(i))/b(j,i), Production(i));
        FGInv = FGInv +  Production(i);
        if (i > warmup)
            TotalProfit = TotalProfit - varLaborC*Workforce(i) - varLaborOC*Overtime(i);
        end
        
        %Satisfy or backorder demand
        Demand = Dem(j,i);
        FGInv = FGInv - Demand;
        if(i > warmup)
            nUnits = nUnits + Demand;
            if FGInv < 0 && I_backorder == 1
                nLate = nLate + min(Demand, -FGInv);
                TotalProfit = TotalProfit + revenue*(Demand) + backorder*FGInv;
            elseif FGInv < 0 && I_backorder == 0
                nLate = nLate + min(Demand, -FGInv);
                TotalProfit = TotalProfit + revenue*(Demand+FGInv);
                FGInv = 0;
            elseif ge(FGInv,0) ==1
                TotalProfit = TotalProfit + revenue*(Demand) - holding*FGInv;
            end
        end
        
        %Record Inventory
        Inv(j,i) = FGInv; 
    end

Output(1,j) = TotalProfit;%/(nPeriods-warmup);
Output(2,j) = 1-nLate/nUnits;


end



%First row has mean cost, second has stockout rate:
meanTotalProfit = mean(Output(1,:));
varTotalProfit = var(Output(1,:))/nRepetitions;
meanServiceLevel = mean(Output(2,:)); % Constraint not satisfied if this is positive
varServiceLevel = var(Output(2,:))/nRepetitions;

end

%Multiple Resources
%meanCapacity = [40*15,40*6,40*7]'; %[Resource1, Resource2, Resource3] in hours per unit
%stdevCapacity = [4*sqrt(10),4*sqrt(6),4*sqrt(7)]'; %[Resource1, Resource2, Resource3] in hours per unit
%ProdCap = normrnd((repmat(meanProdCapReq,1,nRepetitions,nPeriods)),(repmat(stdevProdCapReq,1,nRepetitions,nPeriods)),length(meanProdCapReq),nRepetitions,nPeriods)

%meanProdCapReq = [10,3,5]'; %[Resource1, Resource2, Resource3] in hours per unit
%stdevProdCapReq = [1,0.3,0.5]'; %[Resource1, Resource2, Resource3] in hours per unit
%ProdCapReq = normrnd((repmat(meanProdCapReq,1,nRepetitions,nPeriods)),(repmat(stdevProdCapReq,1,nRepetitions,nPeriods)),length(meanProdCapReq),nRepetitions,nPeriods)

%Production = min(floor(ProdCap(:,j,i)./ProdCapReq(:,j,i)), meanDemand(j,i));
