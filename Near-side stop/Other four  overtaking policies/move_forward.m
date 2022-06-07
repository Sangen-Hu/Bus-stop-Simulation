function [newbus,newberth,newbus_location] = move_forward(bus_No,bus,berth,bus_location,berth_location,buffer_location,run_step,time_step,berth_num,back_headway,buffer_num,bus_running_list)

    if bus(bus_No).reaction_time > 0
        bus(bus_No).reaction_time = bus(bus_No).reaction_time - time_step;
        bus(bus_No).speed = 0;
    else
        for k = 1:berth_num
            if berth(k).current_bus == bus_No && bus_location(bus_No) == berth_location(k)
                berth(k).current_bus = 0;
                if k ~= berth_num && berth(k+1).current_bus ~= 0 && bus(berth(k+1).current_bus).speed == 0
                    bus(berth(k+1).current_bus).reaction_time = back_headway;
                    bus(berth(k+1).current_bus).lanechange_time = back_headway;

                end  
                if k == berth_num && isempty(bus_running_list) ~= 1 && bus_location(bus_running_list(end)) == 0  
                    bus(bus_running_list(end)).lanechange_time = back_headway;
                    bus(bus_running_list(end)).reaction_time = back_headway;
                end 

                if k ~= berth_num
                    berth(k+1).block = 0;
                end  
            end
        end
        if buffer_num ~= 0 && bus_location(bus_No) == buffer_location(buffer_num) 
            if berth(1).current_bus ~= 0 && bus(berth(1).current_bus).speed == 0 && bus(berth(1).current_bus).berthNo == 1
                bus(berth(1).current_bus).reaction_time = back_headway;
            end    
        end
        bus_location(bus_No) = bus_location(bus_No) + 1;
        bus(bus_No).speed = 1;
  
        if bus_location(bus_No) > berth_location(1) && bus(bus_No).leave_stop_time == 0
           bus(bus_No).leave_stop_time = run_step-1;
        end
    end
    newbus = bus;
    newberth = berth;
    newbus_location = bus_location;
end