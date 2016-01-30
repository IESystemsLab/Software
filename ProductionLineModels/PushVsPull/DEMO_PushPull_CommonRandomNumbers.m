%% Baseline System with CONWIP Level = 15
% Observations: 
% 1) Throughput is the same: Good
% 2) Cycletime for CONWIP system is lower: Good
% 3) Average Backorder Level: Both systems manage Backorder levels well, though the CONWIP takes longer to recover from some backorders around t=0.75e4


CONWIPlevel = '15';
meanArrival = '1/0.4';

set_param('ProdSystem_Push/Workstation1/ProcessTime', 'Seed', '1');
set_param('ProdSystem_Push/Workstation1', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_Push/Workstation2/ProcessTime', 'Seed', '2');
set_param('ProdSystem_Push/Workstation2', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_Push/Workstation3/ProcessTime', 'Seed', '3');
set_param('ProdSystem_Push/Workstation3', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_Push/Workstation4/ProcessTime', 'Seed', '4');
set_param('ProdSystem_Push/Workstation4', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_Push/Arrival Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSystem_Push/Demand Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSystem_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);

set_param('ProdSystem_CONWIP/Workstation1/ProcessTime', 'Seed', '1');
set_param('ProdSystem_CONWIP/Workstation1', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_CONWIP/Workstation2/ProcessTime', 'Seed', '2');
set_param('ProdSystem_CONWIP/Workstation2', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_CONWIP/Workstation3/ProcessTime', 'Seed', '3');
set_param('ProdSystem_CONWIP/Workstation3', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_CONWIP/Workstation4/ProcessTime', 'Seed', '4');
set_param('ProdSystem_CONWIP/Workstation4', 'NumberOfServers', '1', 'Capacity', 'inf', 'Distribution', 'Exponential', 'meanExp', '2');
set_param('ProdSystem_CONWIP/Arrival Generator', 'Distribution', 'Exponential', 'Mean', meanArrival, 'InitialSeed', '12345');
set_param('ProdSystem_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);


warning('off', 'all')
simOutCONWIP = sim('ProdSystem_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSystem_Push', 'SaveOutput', 'On');

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

%% Reduce the CONWIP level to 12
% This is around the critical WIP level for this system
% Observations: 
% 1) Throughput is the same: Good
% 2) Cycletime for CONWIP system is lower: Good
% 3) Average Backorder Level: The CONWIP system struggles to recover, but manages to get the backorers to zero.

CONWIPlevel = '12';
set_param('ProdSystem_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSystem_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);


warning('off', 'all')
simOutCONWIP = sim('ProdSystem_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSystem_Push', 'SaveOutput', 'On');

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



%% Reduce the CONWIP level to 10
% Observations: 
% 1) Throughput for the CONWIP system is lower than the Push system: so it's not really a fair comparison anymore
% 2) Cycletime for CONWIP system is lower: Good
% 3) Average Backorder Level: The CONWIP system never recovers.

CONWIPlevel = '10';
set_param('ProdSystem_Push/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);
set_param('ProdSystem_CONWIP/WIP_Queue', 'NumberOfEventsPerPeriod', CONWIPlevel);


warning('off', 'all')
simOutCONWIP = sim('ProdSystem_CONWIP', 'SaveOutput', 'On');
simOutPUSH = sim('ProdSystem_Push', 'SaveOutput', 'On');

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

