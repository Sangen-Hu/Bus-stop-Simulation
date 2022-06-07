function [newbus,newberth,newbus_location,newbuffer_lane_list] = move_forward(bus_No,bus,berth,bus_location,berth_location,buffer_location,buffer_lane_list,run_step,time_step,berth_num,back_headway,bus_running_list,buffer_num)

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
                if buffer_num > 0 
                    if k == berth_num && isempty(buffer_lane_list) ~= 1 && bus_location(buffer_lane_list(1)) == buffer_location(1)  
                        bus(buffer_lane_list(1)).lanechange_time = back_headway;
                        bus(buffer_lane_list(1)).reaction_time = back_headway;
                    end
                else
                    if k == berth_num && isempty(bus_running_list) ~= 1 && bus_location(bus_running_list(end)) == 0
                        bus(bus_running_list(end)).lanechange_time = back_headway;
                        bus(bus_running_list(end)).reaction_time = back_headway;
                    end  
                end 

                if k ~= berth_num
                    berth(k+1).block = 0; 
                end  
            end
        end
        bus_location(bus_No) = bus_location(bus_No) + 1;
        if bus(bus_No).speed == 0
            bus(bus_No).speed = 1;
        end
        if isempty(find(buffer_lane_list == bus_No)) ~= 1 && bus_location(bus_No) > buffer_location(1)
            buffer_lane_list(buffer_lane_list == bus_No) = []; 
        end  
   
        if bus_location(bus_No) > buffer_location(1) && bus(bus_No).enter_berth_time == 0 
            bus(bus_No).enter_berth_time = run_step;
        end    
    end
    newbus = bus;
    newberth = berth;
    newbus_location = bus_location;
    newbuffer_lane_list = buffer_lane_list;
end