function r = is_possible_lane_change(bus_No,bus_list)
    global run_step;
    global bus_location;
    r = false;
    if isempty(bus_list)
        r = true;
        return
    elseif length(bus_list) == 1
        if (bus_location(bus_No,run_step-1) >= max(bus_location(bus_list(1),run_step-1),bus_location(bus_list(1),run_step)))...
            || (bus_location(bus_No,run_step-1) < max(bus_location(bus_list(1),run_step-1),bus_location(bus_list(1),run_step))-4)
            r = true;
            return
        end
    end
    for i = 1:length(bus_list)-1
        if max(bus_location(bus_list(length(bus_list)),run_step),bus_location(bus_list(length(bus_list)),run_step-1))-4 > bus_location(bus_No,run_step-1)  
            r = true;
            return
        end
        if max(bus_location(bus_list(1),run_step),bus_location(bus_list(1),run_step-1)) <= bus_location(bus_No,run_step-1) 
            r = true;
            return
        end            
        if (bus_location(bus_No,run_step-1) < max(bus_location(bus_list(i),run_step),bus_location(bus_list(i),run_step-1))-4 ... 
            && bus_location(bus_No,run_step-1) >= max(bus_location(bus_list(i+1),run_step),bus_location(bus_list(i+1),run_step-1)))
            r = true;
            return
        end
    end         
end 