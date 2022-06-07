function [newbus,newberth] = bus_servicing(bus_No,bus,berth,bus_location,berth_location,run_step,time_step)
%     global run_step;
%     global time_step;
   	if bus(bus_No).service_time > 0
       	bus(bus_No).service_time = bus(bus_No).service_time - time_step;
%         bus_location(bus_No, run_step) = bus_location(bus_No, run_step-1); 
%         bus(bus_No).speed = 0;
        if bus(bus_No).reaction_time > 0
            bus(bus_No).reaction_time = bus(bus_No).reaction_time - time_step;
        end
        if bus(bus_No).lanechange_time > 0
            bus(bus_No).lanechange_time = bus(bus_No).lanechange_time - time_step;
        end
    else
       	bus(bus_No).mission = 3;
        bus(bus_No).current_lane = 1;
       	berth(bus(bus_No).berthNo).potential_bus = 0;
        bus(bus_No).service_finished = run_step-1;
        %确保换道时间在服务期不能减为零，其中机械延时是不能减为零，如果前车顺序出站，后车换道反应时间为机械延时，
        %如果前车也是换道出去，为了保证安全距离，后车换道反应时间为回传时间和机械延时两部分
%         bus(bus_No).lanechange_time = max(lag_delay,bus(bus_No).lanechange_time);
%         bus(bus_No).reaction_time = max(lag_delay,bus(bus_No).reaction_time); %确保反应时间在服务期不能减为零，机械延时是不能减为零
        if bus_location(bus_No) == berth_location(1)  %当最下游的berth的bus出站，直接离开stop
%             bus(bus_No).reaction_time = lag_delay;
            bus(bus_No).mission = 4;
        end 
    end
    newbus = bus;
    newberth = berth;
end