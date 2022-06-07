function renew_list = combine_bus(bus_No,bus_list,bus_location)
    if isempty(bus_list)
        bus_list(1) = bus_No;
        renew_list = bus_list;
        return
    elseif length(bus_list) == 1
        if bus_location(bus_No) <= bus_location(bus_list(1))
            if bus_location(bus_No) == bus_location(bus_list(1)) && bus_No < bus_list(1)
                   bus_list(2) = bus_list(1);
                   bus_list(1) = bus_No;
            else
                  bus_list(2) = bus_No;
            end
        elseif bus_location(bus_No) > bus_location(bus_list(1))
            bus_list(2) = bus_list(1);
            bus_list(1) = bus_No;
        end
        renew_list = bus_list;
        return 
    end
    for i = 1:length(bus_list)-1   
        if (bus_location(bus_list(length(bus_list)))) >= bus_location(bus_No)  
            if bus_location(bus_list(length(bus_list))) == bus_location(bus_No) && bus_No < bus_list(length(bus_list))
                bus_list = [bus_list(1:length(bus_list)-1),bus_No,bus_list(end)];
            else    
                bus_list(length(bus_list)+1) = bus_No;
            end
            renew_list = bus_list;
            return
        end
        if bus_location(bus_list(1)) <= bus_location(bus_No) 
            if bus_location(bus_list(1)) == bus_location(bus_No) && bus_No > bus_list(1)
                bus_list = [bus_list(1),bus_No,bus_list(2:end)];
            else    
                bus_list = [bus_No,bus_list(1:end)];
            end
            renew_list = bus_list;
            return
        end     
        ahead_bus = bus_list(i);
        after_bus = bus_list(i+1);
        if bus_location(bus_No) < (bus_location(ahead_bus)) && bus_location(bus_No) >= bus_location(after_bus)
            if bus_location(bus_No) == bus_location(after_bus) && bus_No > after_bus
                bus_list = [bus_list(1:i+1),bus_No,bus_list(i+2:end)];
            else
                bus_list = [bus_list(1:i),bus_No,bus_list(i+1:end)];
            end
            renew_list = bus_list;
            return 
        end
    end
end

