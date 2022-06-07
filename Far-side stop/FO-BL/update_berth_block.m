function [newberth] = update_berth_block(berth_No,berth)
    global berth_num;
    for k = 1:berth_num
        if k < berth_No
            berth(k).block_in = berth(k).block_in + 1;  
        elseif k > berth_No
            berth(k).block_out = berth(k).block_out + 1; 
        end
    end
    newberth = berth;
end