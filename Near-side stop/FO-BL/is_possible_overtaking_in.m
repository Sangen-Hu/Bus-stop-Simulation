function r = is_possible_overtaking_in(bus_No,bus_list,bus_location)
    r = false;
    if isempty(bus_list)
        r = true;
        return
    elseif length(bus_list) == 1
        if (bus_location(bus_No)-4 >= bus_location(bus_list(1)))...
            || (bus_location(bus_No) <= bus_location(bus_list(1))-4) 
            r = true;
            return
        end
    end
    for i = 1:length(bus_list)-1
        if bus_location(bus_list(length(bus_list)))-4 >= bus_location(bus_No)  
            r = true;
            return
        end
        if bus_location(bus_list(1)) <= bus_location(bus_No)-4 
            r = true;
            return
        end            
        if bus_location(bus_No) <= bus_location(bus_list(i))-4 ... 
            && bus_location(bus_No)-4 >= bus_location(bus_list(i+1))
            r = true;
            return
        end
    end         
end 