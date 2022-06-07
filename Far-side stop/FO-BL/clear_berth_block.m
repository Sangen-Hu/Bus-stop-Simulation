function [newbus,newberth] = clear_berth_block(berth_No,bus,berth)
    global berth_num;
    global back_headway;
    for k = 1:berth_num
        if k < berth_No
            berth(k).block_in = berth(k).block_in - 1;  
        elseif k > berth_No
            berth(k).block_out = berth(k).block_out - 1;
            if berth(k).current_bus ~= 0 && berth(k).block_out == 0
                bus(berth(k).current_bus).lanechange_time = back_headway;
            end
        end
    end
    newbus = bus;
    newberth = berth;
end