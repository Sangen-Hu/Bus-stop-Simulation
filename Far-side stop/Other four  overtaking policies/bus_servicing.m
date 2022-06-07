function [newbus,newberth] = bus_servicing(bus_No,bus,berth,bus_location,berth_location,run_step,time_step)

   	if bus(bus_No).service_time > 0
       	bus(bus_No).service_time = bus(bus_No).service_time - time_step;

        if bus(bus_No).reaction_time > 0
            bus(bus_No).reaction_time = bus(bus_No).reaction_time - time_step;
        end
        if bus(bus_No).lanechange_time > 0
            bus(bus_No).lanechange_time = bus(bus_No).lanechange_time - time_step;
        end
    else
       	bus(bus_No).mission = 3;
        bus(bus_No).current_lane = 1;
       	berth(bus(bus_No).berthNo).potential_bus = 0;
        bus(bus_No).service_finished = run_step-1;

        if bus_location(bus_No) == berth_location(1)  
            bus(bus_No).mission = 4;
        end 
    end
    newbus = bus;
    newberth = berth;
end