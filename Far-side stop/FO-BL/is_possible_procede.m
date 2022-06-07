function r = is_possible_procede(bus_No,bus_list,bus,berth,bus_location,berth_location)
    r = true;
    for i = 1:find(bus_list == bus_No)-1
        if bus_location(bus_No) >= bus_location(bus_list(i))-4 && bus_location(bus_No) <= bus_location(bus_list(i))
            r = false;
            return
        end
    end 
    if bus(bus_No).mission == 3 && bus(bus_No).berthNo ~= 1 && bus(bus_No).current_lane == 1
        for k = bus(bus_No).berthNo-1 :-1 :1
            if berth(k).current_bus ~= 0 && bus_location(bus_No) <= berth_location(k)-4 && berth_location(k)-4 <= bus_location(bus_No)
                r = false;
                return
            end
        end
    end               
end