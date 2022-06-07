function renew_list = lane_change(bus_No,bus_list,bus_location)

    if isempty(bus_list)
        bus_list(1) = bus_No;
        renew_list = bus_list;
        return
    elseif length(bus_list) == 1
        if bus_location(bus_No) < bus_location(bus_list(1))
            bus_list(2) = bus_No;
        elseif bus_location(bus_No) > bus_location(bus_list(1))
            bus_list(2) = bus_list(1);
            bus_list(1) = bus_No;
        end
        renew_list = bus_list;
        return 
    end
    for i = 1:length(bus_list)-1
        if bus_location(bus_list(length(bus_list)))-4 >= bus_location(bus_No)  
            bus_list(length(bus_list)+1) = bus_No;
            renew_list = bus_list;
            return
        end
        if bus_location(bus_list(1)) <= bus_location(bus_No) 
            bus_list = [bus_No,bus_list(1:end)];
            renew_list = bus_list;
            return
        end     
        ahead_bus = bus_list(i);
        after_bus = bus_list(i+1);
        if bus_location(bus_No) <= bus_location(ahead_bus)-4 ...
            && bus_location(bus_No)-2 >= bus_location(after_bus)
            bus_list = [bus_list(1:i),bus_No,bus_list(i+1:end)];
            renew_list = bus_list;
            return 
        end
    end
end

