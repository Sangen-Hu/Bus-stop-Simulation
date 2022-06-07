function [newberth] = check_berth_state(bus_list,bus,berth,bus_location,berth_location,adjacent_lane_list,buffer_lane_list,time_step,berth_num,cycle_length,green_time,buffer_num,current_time,thres_overtaking_out)

    for k = 1: berth_num
        if buffer_num ~= 0
            if berth(k).current_bus == 0
                if k == 1
                    if (length(buffer_lane_list) == buffer_num)    
                        for j = 1: length(bus_list)
                            if bus_location(bus_list(j)) <= berth_location(k) && bus_location(bus_list(j)) > berth_location(k) -4
                                berth(k).current_bus = bus_list(j);
                                break;
                            end
                        end
                    end            
                else
                    if berth(k-1).current_bus ~= 0
                        for j = 1: length(bus_list)
                            if bus_location(bus_list(j)) <= berth_location(k) && bus_location(bus_list(j)) > berth_location(k) -4
                                if bus(bus_list(j)).mission == 3 && bus(bus_list(j)).pro_overtaking_out <= thres_overtaking_out && is_possible_overtaking_out(bus_list(j),adjacent_lane_list,bus_location) && length(buffer_lane_list) < buffer_num

                                else
                                    berth(k).current_bus = bus_list(j);
                                end
                                break;
                            end
                        end
                    end
                end
            end
        else
            if berth(k).current_bus == 0
                if k == 1
                    for j = 1: length(bus_list)
                        if bus_location(bus_list(j)) <= berth_location(k) && bus_location(bus_list(j)) > berth_location(k) -4
                            if mod(current_time,cycle_length) + (berth_location(k) - bus_location(bus_list(j)))*time_step > green_time
                                berth(k).current_bus = bus_list(j);
                                break;
                            end
                        end
                    end         
                else
                    if berth(k-1).current_bus ~= 0
                        for j = 1: length(bus_list)
                            if bus_location(bus_list(j)) <= berth_location(k) && bus_location(bus_list(j)) > berth_location(k) -4
                                if bus(bus_list(j)).mission == 3 && bus(bus_list(j)).pro_overtaking_out <= thres_overtaking_out && is_possible_overtaking_out(bus_list(j),adjacent_lane_list,bus_location) ...
                                    && mod(current_time,cycle_length) + bus(bus_list(j)).lanechange_time+ (berth_location(1) - bus_location(bus_list(j)))*time_step <= green_time
                                else
                                    berth(k).current_bus = bus_list(j);
                                end
                                break;
                            end
                        end
                    end
                end
            end
        end
    end 
    newberth = berth;
end