function r = is_possible_leavesignal(green_time,cycle_length,current_time)

    r = false;
    if mod(current_time,cycle_length) <= green_time %2020/9/10mod(current_time-time_step,cycle_length)
        r = true;
    end
end