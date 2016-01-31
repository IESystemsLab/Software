%% Push Vs CONWIP Demonstration with Common Random Numbers
% This demonstration is intended to highlight the differences in the
% transient behavior of the Push vs CONWIP systems. Much of the previous
% discussion has examined the steady-state, long-run performance of these
% two types of systems, where the CONWIP system exhibits lower average cycle-times
% due to the constant WIP level. 
%
% This demonstration will focus on the back-order level of each system, and
% how each system recovers from periods of instability; e.g. a period of 
% long processing times coupled with a period of short interarrival times.
% To establish a simple but effective demonstration, each workstation is a
% M/M/1 queue/server with a processing time of 2 and the interarrival times to
% the system is 2.5, or the arrival rate is 0.4 while the bottleneck rate
% is 0.5. Therefore the system is stable in the long-run, but due to the
% randomness of both the arrivals and processing times, it may become
% temporarily unstable.

%% Baseline System with CONWIP Level = 15
% The first use case sets the CONWIP level at 15, while the critical wip
% for the system is somewhere around 12. Therefore, the system should
% perform at its maximum capacity.

open('ProdSys_Push');
open('ProdSys_CONWIP');

CONWIPlevel = '15';
meanArrival = '1/0.4';

set_param('ProdSys_Push/Workstation1/ProcessingTimes', 'Seed', '1', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_Push/Workstation1', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_Push/Workstation2/ProcessingTimes', 'Seed', '2', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_Push/Workstation2', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_Push/Workstation3/ProcessingTimes', 'Seed', '3', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_Push/Workstation3', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_Push/Workstation4/ProcessingTimes', 'Seed', '4', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_Push/Workstation4', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_Push/Arrival Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSys_Push/Demand Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSys_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSys_Push/EntityCount', 'const', '50000');

set_param('ProdSys_CONWIP/Workstation1/ProcessingTimes', 'Seed', '1', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_CONWIP/Workstation1', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_CONWIP/Workstation2/ProcessingTimes', 'Seed', '2', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_CONWIP/Workstation2', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_CONWIP/Workstation3/ProcessingTimes', 'Seed', '3', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_CONWIP/Workstation3', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_CONWIP/Workstation4/ProcessingTimes', 'Seed', '4', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSys_CONWIP/Workstation4', 'NumberOfServers', '1', 'Capacity', 'inf');
set_param('ProdSys_CONWIP/Arrival Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSys_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSys_CONWIP/EntityCount', 'const', '50000');


warning('off', 'all')
simOutCONWIP = sim('ProdSys_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSys_Push', 'SaveOutput', 'On');

avgCTconwip = simOutCONWIP.get('logsout').get('avgCycleTime');
avgCTpush = simOutPUSH.get('logsout').get('avgCycleTime');

avgTHconwip = simOutCONWIP.get('logsout').get('avgThroughput');
avgTHpush = simOutPUSH.get('logsout').get('avgThroughput');

avgWIPconwip = simOutCONWIP.get('logsout').get('WIP');
avgWIPpush = simOutPUSH.get('logsout').get('WIP');

avgBOconwip = simOutCONWIP.get('logsout').get('nDemandQueue');
avgBOpush = simOutPUSH.get('logsout').get('nDemandQueue');


nDeparturesconwip = simOutCONWIP.get('logsout').get('Departures');
nDeparturespush = simOutPUSH.get('logsout').get('Departures');

figure
plot(avgTHpush.Values.Time, avgTHpush.Values.Data)
hold on
plot(avgTHconwip.Values.Time, avgTHconwip.Values.Data)
hold off
title('Average Throughput: CONWIP Level = 15')

figure
plot(avgCTpush.Values.Time, avgCTpush.Values.Data)
hold on
plot(avgCTconwip.Values.Time, avgCTconwip.Values.Data)
hold off
title('Average Cycletime: CONWIP Level = 15')

figure
plot(avgBOpush.Values.Time(1:2e4), avgBOpush.Values.Data(1:2e4))
hold on
plot(avgBOconwip.Values.Time(1:2e4), avgBOconwip.Values.Data(1:2e4))
hold off
title('Average Backorder Level: CONWIP Level = 15')

%% 
% Observations: 
%
% * Throughput is the same: Good
% * Cycletime for CONWIP system is lower: Good
% * Average Backorder Level: Both systems manage Backorder levels well,
% though the CONWIP takes longer to recover from some backorders around t=0.75e4.

%% Reduce the CONWIP level to 12
% The second use case sets the CONWIP level around the critical WIP level
% for this system. 


CONWIPlevel = '12';
set_param('ProdSys_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSys_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);


warning('off', 'all')
simOutCONWIP = sim('ProdSys_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSys_Push', 'SaveOutput', 'On');

avgCTconwip = simOutCONWIP.get('logsout').get('avgCycleTime');
avgCTpush = simOutPUSH.get('logsout').get('avgCycleTime');

avgTHconwip = simOutCONWIP.get('logsout').get('avgThroughput');
avgTHpush = simOutPUSH.get('logsout').get('avgThroughput');

avgWIPconwip = simOutCONWIP.get('logsout').get('WIP');
avgWIPpush = simOutPUSH.get('logsout').get('WIP');

avgBOconwip = simOutCONWIP.get('logsout').get('nDemandQueue');
avgBOpush = simOutPUSH.get('logsout').get('nDemandQueue');

figure
plot(avgTHpush.Values.Time, avgTHpush.Values.Data)
hold on
plot(avgTHconwip.Values.Time, avgTHconwip.Values.Data)
hold off
title('Average Throughput: CONWIP Level = 12')

figure
plot(avgCTpush.Values.Time, avgCTpush.Values.Data)
hold on
plot(avgCTconwip.Values.Time, avgCTconwip.Values.Data)
hold off
title('Average Cycletime: CONWIP Level = 12')

figure
plot(avgBOpush.Values.Time(1:2e4), avgBOpush.Values.Data(1:2e4))
hold on
plot(avgBOconwip.Values.Time(1:2e4), avgBOconwip.Values.Data(1:2e4))
hold off
title('Average Backorder Level: CONWIP Level = 12')

%% 
% Observations: 
%
% * Throughput is the same: Good
% * Cycletime for CONWIP system is lower: Good
% * Average Backorder Level: The CONWIP system struggles to recover, but manages to get the backorers to zero.

%% Reduce the CONWIP level to 10
% In this last use case, the CONWIP level is set below the critical WIP
% level for this system. Therefore, the maximum throughput of the CONWIP
% system is less than its maximum, and the system is actually unstable. We
% expect the backorders to run-away towards infinity. This use case is
% intended to highlight the perils of selecting the wrong CONWIP level for
% a system.


CONWIPlevel = '10';
set_param('ProdSys_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSys_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);


warning('off', 'all')
simOutCONWIP = sim('ProdSys_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSys_Push', 'SaveOutput', 'On');

avgCTconwip = simOutCONWIP.get('logsout').get('avgCycleTime');
avgCTpush = simOutPUSH.get('logsout').get('avgCycleTime');

avgTHconwip = simOutCONWIP.get('logsout').get('avgThroughput');
avgTHpush = simOutPUSH.get('logsout').get('avgThroughput');

avgWIPconwip = simOutCONWIP.get('logsout').get('WIP');
avgWIPpush = simOutPUSH.get('logsout').get('WIP');

avgBOconwip = simOutCONWIP.get('logsout').get('nDemandQueue');
avgBOpush = simOutPUSH.get('logsout').get('nDemandQueue');


figure
plot(avgTHpush.Values.Time, avgTHpush.Values.Data)
hold on
plot(avgTHconwip.Values.Time, avgTHconwip.Values.Data)
hold off
title('Average Throughput: CONWIP Level = 10')

figure
plot(avgCTpush.Values.Time, avgCTpush.Values.Data)
hold on
plot(avgCTconwip.Values.Time, avgCTconwip.Values.Data)
hold off
title('Average Cycletime: CONWIP Level = 10')

figure
plot(avgBOpush.Values.Time(1:2e4), avgBOpush.Values.Data(1:2e4))
hold on
plot(avgBOconwip.Values.Time(1:2e4), avgBOconwip.Values.Data(1:2e4))
hold off
title('Average Backorder Level: CONWIP Level = 10')

%%
% Observations: 
%
% * Throughput for the CONWIP system is lower than the Push system: so it's not really a fair comparison anymore
% * Cycletime for CONWIP system is lower: Good
% * Average Backorder Level: The CONWIP system never recovers.

close all

