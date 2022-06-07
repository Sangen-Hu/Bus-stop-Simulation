function [available_berth] = check_vacant_berth(bus,berth)

    global berth_num;
    available_berth = 0;
    for k = berth_num:-1:1
        if berth(k).potential_bus == 0 && (berth(k).current_bus == 0 || (berth(k).current_bus ~= 0 && bus(berth(k).current_bus).speed ~= 0))
            available_berth = available_berth+1;
            continue;
        else
            break;
        end
    end 
    return
end 