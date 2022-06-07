function r = is_possible_leavesignal(green_time,cycle_length,current_time)

    r = false;
    if mod(current_time,cycle_length) <= green_time 
        r = true;
    end
end