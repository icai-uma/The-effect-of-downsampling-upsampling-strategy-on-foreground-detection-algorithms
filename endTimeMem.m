function [endTime,endMem]=endTimeMem(params,startTime,startMem)

if isunix
    MemData=GetMemUseLinux();
    endTime=MemData(1)+MemData(2)-startTime;
    endMem = MemData(3) - startMem;
else
    endTime=toc(startTime);
    endMem=GetMemoMEX() - startMem;
end

%endTime in seconds
%endMem in KBytes