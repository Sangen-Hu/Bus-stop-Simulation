function [berth_No,newbus,newberth] = update_target_berth(bus_No,bus,berth,bus_location,bus_lane_list,berth_location,adjacent_lane_list,berth_num,lag_delay,stop_entrance,thres_overtaking_in)

	berth_No = 0;
    if bus(bus_No).berthNo == 0
        if bus(bus_No).pro_overtaking_in <= thres_overtaking_in  
            for i = 1: berth_num
                if (berth(i).current_bus == 0 || berth(i).current_bus == bus_No) && (bus_location(bus_No) <= berth_location(i))
                    if berth(i).potential_bus ~= 0 && berth(i).potential_bus ~= bus_No
                        if bus_location(berth(i).potential_bus) < bus_location(bus_No) || (bus_location(berth(i).potential_bus) == bus_location(bus_No) && berth(i).potential_bus > bus_No)
                            bus(berth(i).potential_bus).target_berth = 0;
                        else
                            continue;
                        end
                    end
                    if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i
                        berth(bus(bus_No).target_berth).potential_bus = 0;
                    end 
                    berth_No = i;
                    if berth_No ~= berth_num  
                        if bus_location(bus_No) == stop_entrance  
                            if bus(bus_No).speed == 0 && berth(i).potential_bus ~= bus_No && bus(bus_No).target_berth == 0
                                bus(bus_No).reaction_time = lag_delay; 
                            end
                            if isempty(bus_lane_list) || (isempty(bus_lane_list) ~= 1 && bus_location(bus_lane_list(length(bus_lane_list))) > berth_location(berth_No)) 
                                bus(bus_No).lane_No = 1;
                            else
                                bus(bus_No).lane_No = 2;
                            end
                        else
                           if isempty(find(bus_lane_list == bus_No)) == 1 && isempty(find(adjacent_lane_list == bus_No)) ~= 1
                                bus(bus_No).lane_No = 2;
                            end 
                        end
                    else
                        bus(bus_No).lane_No = 1;
                    end
                    berth(i).potential_bus = bus_No;
                    newbus = bus;
                    newberth = berth;
                    return
                end
            end
		else 
			for i = berth_num: -1: 1
                if bus_location(bus_No) < berth_location(i)
                    if (berth(i).current_bus == 0 || berth(i).current_bus == bus_No) && (berth(i).potential_bus == 0 || berth(i).potential_bus >= bus_No)
                        continue;
                    else
                        break;
                    end
                end
			end
			if i ~= berth_num 
                if i == 1 && (berth(1).current_bus == 0 || berth(1).current_bus == bus_No) && (berth(1).potential_bus == 0 || berth(1).potential_bus == bus_No)
                    if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i
                        berth(bus(bus_No).target_berth).potential_bus = 0;
                    end 
                    berth(1).potential_bus = bus_No;
                    berth_No = 1;
                else  
                    if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i+1
                        berth(bus(bus_No).target_berth).potential_bus = 0;
                    end 
                    berth(i+1).potential_bus = bus_No;
                    berth_No = i+1;
                end
                newbus = bus;
                newberth = berth;
                return
            else
                if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= berth_num
                    berth(bus(bus_No).target_berth).potential_bus = 0;
                end 
                if berth_num == 1
                    berth(berth_num).potential_bus = bus_No;
                    berth_No = berth_num;
                end
                newbus = bus;
                newberth = berth;
                return
			end
        end
    end
    newbus = bus;
    newberth = berth;
end


