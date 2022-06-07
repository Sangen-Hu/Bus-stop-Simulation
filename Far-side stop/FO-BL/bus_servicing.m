function [newbus,newberth] = bus_servicing(bus_No,bus,berth,bus_location,berth_location,run_step,time_step)
%     global run_step;
%     global time_step;
   	if bus(bus_No).service_time > 0
       	bus(bus_No).service_time = bus(bus_No).service_time - time_step;
%         bus_location(bus_No, run_step) = bus_location(bus_No, run_step-1); 
%         bus(bus_No).speed = 0;
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
        %ȷ������ʱ���ڷ����ڲ��ܼ�Ϊ�㣬���л�е��ʱ�ǲ��ܼ�Ϊ�㣬���ǰ��˳���վ���󳵻�����Ӧʱ��Ϊ��е��ʱ��
        %���ǰ��Ҳ�ǻ�����ȥ��Ϊ�˱�֤��ȫ���룬�󳵻�����Ӧʱ��Ϊ�ش�ʱ��ͻ�е��ʱ������
%         bus(bus_No).lanechange_time = max(lag_delay,bus(bus_No).lanechange_time);
%         bus(bus_No).reaction_time = max(lag_delay,bus(bus_No).reaction_time); %ȷ����Ӧʱ���ڷ����ڲ��ܼ�Ϊ�㣬��е��ʱ�ǲ��ܼ�Ϊ��
        if bus_location(bus_No) == berth_location(1)  %�������ε�berth��bus��վ��ֱ���뿪stop
%             bus(bus_No).reaction_time = lag_delay;
            bus(bus_No).mission = 4;
        end 
    end
    newbus = bus;
    newberth = berth;
end