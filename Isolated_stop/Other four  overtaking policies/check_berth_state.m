function [newberth] = check_berth_state(bus_list,bus,berth,bus_location,berth_location,adjacent_lane_list)
    global berth_num;
    global thres_overtaking_out
    for k = 2: berth_num
        if berth(k).current_bus == 0
            if berth(k-1).current_bus ~= 0
                for j = 1: length(bus_list)
                    if bus_location(bus_list(j)) <= berth_location(k) && bus_location(bus_list(j)) > berth_location(k) -4
                        if bus(bus_list(j)).mission == 3 && bus(bus_list(j)).pro_overtaking_out <= thres_overtaking_out && is_possible_overtaking_out(bus_list(j),adjacent_lane_list,bus_location) && berth(k).block == 0
                            
                        else
                            berth(k).current_bus = bus_list(j);
                        end
                        break;
                    end
                end
            end
        end
    end
    newberth = berth;
end 