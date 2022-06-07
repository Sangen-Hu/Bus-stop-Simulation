%functionname: function description
function [newbus,newberth] = check_arrive_berth(bus_No,bus,berth,bus_location,berth_location)
    global run_step;
    global berth_num;
    for j = 1: berth_num
        if bus_location(bus_No) == berth_location(j)
            if j ~= 1 && berth(j-1).current_bus == 0 
                if berth(j-1).potential_bus ~= 0
                    bus(berth(j-1).potential_bus).target_berth = 0;
                    berth(j-1).potential_bus = 0;
                end  
                if bus(bus_No).target_berth ~= 0
                    berth(bus(bus_No).target_berth).potential_bus = 0;
                    berth(bus(bus_No).target_berth).current_bus = 0;
                end
                bus(bus_No).target_berth = j-1;
                berth(j-1).potential_bus = bus_No;
                newberth = berth;
                newbus = bus;
                return
            end
            if bus(bus_No).target_berth ~= 0 && j ~= bus(bus_No).target_berth
                berth(bus(bus_No).target_berth).potential_bus = 0;
            end
            berth(j).current_bus = bus_No;
            berth(j).potential_bus = bus_No;
            bus(bus_No).mission = 2; 
            bus(bus_No).berthNo = j;
            bus(bus_No).enter_berth = run_step;
            bus(bus_No).target_berth = 0;
            break;
        end
    end
    newberth = berth;
    newbus = bus;
end

