
clear all

MemDataBefore=GetMemUseLinux();
StartTime=MemDataBefore(1)+MemDataBefore(2);

demo_backfeat_singlethread;

MemDataAfter=GetMemUseLinux();
CPUtime=MemDataAfter(1)+MemDataAfter(2)-StartTime;
%MemUsed = MemDataAfter(2)-MemDataBefore(2);
MemUsed = MemDataAfter(3)-MemDataBefore(3);
fprintf('CPUtime: %f \r\n',CPUtime);
fprintf('MemUsed: %f \r\n',MemUsed);