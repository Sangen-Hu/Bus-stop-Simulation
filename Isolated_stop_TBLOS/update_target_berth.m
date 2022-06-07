function [berth_No,newbus,newberth] = update_target_berth(bus_No,bus,berth,bus_location,bus_lane_list,berth_location,berth_count,lag_delay,thres_overtaking_in)

	berth_No = 0;
    if bus(bus_No).berthNo == 0
        for j = 1: berth_count
            for i = 2: -1: 1
                if bus_location(bus_No) < berth_location(i+3*(j-1))
                    if (berth(i+3*(j-1)).current_bus == 0 || berth(i+3*(j-1)).current_bus == bus_No) && (berth(i+3*(j-1)).potential_bus == 0 || berth(i+3*(j-1)).potential_bus >= bus_No)
                        continue;
                    else
                        break;
                    end
                end
            end
            if i ~= 2
                if i == 1 && (berth(i+3*(j-1)).current_bus == 0 || berth(i+3*(j-1)).current_bus == bus_No) && (berth(i+3*(j-1)).potential_bus == 0 || berth(i+3*(j-1)).potential_bus == bus_No)
                    if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i+3*(j-1)
                        berth(bus(bus_No).target_berth).potential_bus = 0;
                    end 
                    berth(i+3*(j-1)).potential_bus = bus_No;
                    berth_No = i+3*(j-1);
                    bus(bus_No).lane_No = 2; 
                else  
                    if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i+3*(j-1)+1
                        berth(bus(bus_No).target_berth).potential_bus = 0;
                    end 
                    berth(i+3*(j-1)+1).potential_bus = bus_No;
                    berth_No = i+3*(j-1)+1;
                   
                    if (i+3*(j-1)+1) == (berth_count*2+berth_count-1)
                        bus(bus_No).lane_No = 1; 
                    else
                        bus(bus_No).lane_No = 2; 
                    end
                end
                newbus = bus;
                newberth = berth;
                return
            else  
                if j ~= berth_count
                    continue;
                end
                if bus(bus_No).target_berth ~= 0 && bus(bus_No).target_berth ~= i+3*(j-1)
                    berth(bus(bus_No).target_berth).potential_bus = 0;
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
