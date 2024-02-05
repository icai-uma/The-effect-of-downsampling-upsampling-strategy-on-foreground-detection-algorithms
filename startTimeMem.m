function [startTime,startMem]=startTimeMem(params)

if isunix
    MemData=GetMemUseLinux();
    startTime=MemData(1)+MemData(2);
    %startMem = MemData(5)+MemData(6);
    startMem = MemData(3);
else
    startMem=GetMemoMEX();
    startTime = tic;
end