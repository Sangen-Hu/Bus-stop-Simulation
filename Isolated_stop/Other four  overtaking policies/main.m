tic
% clearvars -except bus_arrival_headway bus_arrival_time bus_service_time bus_overtaking_in bus_overtaking_out
% global bus;
% global berth;
global berth_num;
global back_headway;
global moveup_headway;
% global berth_location;
% global bus_location;
global run_step;
global lag_delay;
global time_step;
% global adjacent_lane_list;
% global bus_lane_list;
% global bus_service_time;
% global bus_running_list;
global thres_overtaking_in;
global thres_overtaking_out
bus_stop_capacity = 0;
average_delay = 0;
%-----���幫�������ԵĽṹ��-----%
bus = struct('mission',{},... % 1����վ 2�������� 3��buffer�� 4���뿪
             'lane_No',{},... % 1��stop_lane 2��passing_lane
             'current_lane',{},...
             'service_time',{},...
             'speed',{},...   % ʵʱ�ٶ�
             'berthNo',{},... % ͣ��berth���
             'pro_overtaking_in',{},...
             'pro_overtaking_out',{},...
             'target_berth',{},...
             'enter_queue',{},...
             'start_run',{},...
             'enter_berth',{},...
             'end_step',{},...
             'service_finished',{},...
             'reaction_time',{},...
             'lanechange_time',{},...
             'wait_berth_start',{},...
             'wait_berth_end',{});

%-----���幫����λ���ԵĽṹ��-----%
%------service_bus_id:��λ��ռ�õĳ������
%------available_time_berth:�����ڳ�λ�������ʱ��
%------status:0������ͨ�����̵�  1��ͨ�����̵�
berth = struct('block',{},'current_bus',{},'potential_bus',{}); 

% -------simulation parameters------------%
% -------1. bus initiate parameters-------%
bus_num = 10;        % simulation bus number
bus_flow_rate = 36000; % unit: vehicles/hour
lambda_bus = 1/(bus_flow_rate/3600);
bus_arrival_headway = exprnd(lambda_bus,1,bus_num); % pre-generate all buses arrival time
bus_service_meantime = 24.84; % unit: second
bus_service_variation = 0.01; % namely cs
bus_service_alpha = 1/(bus_service_variation^2); % service time follows Gamma distribution ~ alpha parameter                                
bus_service_beta = (bus_service_variation^2)/(1/bus_service_meantime); % service time follows Gamma distribution ~ bata parameter 
if bus_service_variation ~= 0
    bus_service_time = gamrnd(bus_service_alpha,bus_service_beta,1,bus_num); % pre-generate all buses service time
else 
    bus_service_time = unifrnd (bus_service_meantime,bus_service_meantime,1,bus_num);
end
bus_overtaking_in = unifrnd (0,1,1,bus_num);%�����������복λ���ʷ��Ӿ��ȷֲ�
bus_overtaking_out = unifrnd (0,1,1,bus_num);%��������ʻ�복λ���ʷ��Ӿ��ȷֲ�
% -------2. rule set-------%
thres_overtaking_in = 0;    %�����������ο��೵λ�ĸ�����ֵ
thres_overtaking_out = 1;   %����bus����ʻ����λ�ĸ�����ֵ
berth_num = 2;
jam_spacing = 12;
back_speed = 27 / 3.6;
moveup_speed = 20 / 3.6;
moveup_headway = jam_spacing / moveup_speed;
back_headway = jam_spacing / back_speed;
% -------4. output parameters-------%
last_bus_endtime = 0;
bus_arrival_time = zeros(1,bus_num);
berth_location = zeros(1,berth_num);
bus_location = zeros(bus_num,1); 
bus_location_plot = zeros(bus_num,200); 
bus_running_list = [];
bus_lane_list = [];
adjacent_lane_list = [];
bus_queue_list = [];
unit_movlength = 40; % ��moveup_headwayʱ��Ϊһ��berth���ȣ�Ϊ��ϸ������berthϸ�ֶ����Ԫ
delate_arry = [];
bus(1).start_run = 1;
temp_berth_assigned = 0;
%-----��ʼ��--------%
for n = 1:bus_num
    if n == 1
        bus_arrival_time(1) = bus_arrival_headway(1);
    else    
        bus_arrival_time(n) = bus_arrival_time(n-1)+bus_arrival_headway(n);
    end
%     if bus_service_variation ~= 0
%         bus(n).service_time = gamrnd(bus_service_alpha,bus_service_beta); % pre-generate all buses service time
%     else
%         bus(n).service_time = unifrnd (bus_service_meantime,bus_service_meantime);
%     end
    bus(n).service_time = bus_service_time(n);
    bus(n).pro_overtaking_in = unifrnd (0,1);
    bus(n).pro_overtaking_out = unifrnd (0,1);
    bus(n).berthNo = 0;
    bus(n).current_lane = 0;
    bus(n).lane_No = 1;
    bus(n).target_berth = 0;
    bus(n).reaction_time = 0;
    bus(n).mission = 1;
    bus(n).service_finished = 0;
    bus(n).lanechange_time = 0;
    bus(n).wait_berth_start = 0;
    bus(n).wait_berth_end = 0;
end

% ��ʼ��berth��λ��
for count = 1: berth_num
    berth_location(count) = 40*(berth_num-count+1);
% berth��״̬��ʼ��  
    berth(count).potential_bus = 0;
    berth(count).current_bus = 0;
    berth(count).block = 0;
end
%-----��ʼʱ�̵�״̬--------% 
current_time = bus_arrival_time(1);
bus_count = 2;
run_step = 1;
bus_location(1) = 0;
time_step = moveup_headway/unit_movlength;
% lag_delay = 2 * time_step; %bus��е�ӳ�ʱ��
lag_delay = back_headway;
bus_time_interval = 0;
bus_queue_list(1) = 1;
bus(1).enter_queue = 1;
while 1
    if bus_count <= bus_num && bus_time_interval >= moveup_headway && current_time >= bus_arrival_time(bus_count)
        if isempty(bus_queue_list) ~= 1  %���������û�г����򵽴�ĳ�����Ҫ���Ϸ�Ӧʱ��
            bus(bus_count).reaction_time = back_headway;
        end
        bus_queue_list(length(bus_queue_list)+1) = bus_count;
        bus(bus_count).enter_queue = run_step;
        bus_count = bus_count+1;
        bus_time_interval = 0;
    end
    run_step = run_step+1;
    current_time = current_time+time_step;
    bus_time_interval = bus_time_interval+time_step;
    if run_step == 56
    end
    if isempty(bus_queue_list) ~= 1
       if isempty(bus_running_list) || bus_location(bus_running_list(length(bus_running_list))) >= 40 
           if bus(bus_queue_list(1)).reaction_time > 0
               bus(bus_queue_list(1)).reaction_time = bus(bus_queue_list(1)).reaction_time - time_step;
           else
               bus_running_list(length(bus_running_list)+1) = bus_queue_list(1);
               bus(bus_queue_list(1)).start_run = run_step-1;
               bus_location(bus_queue_list(1)) = 0;
               bus_location_plot(bus_queue_list(1),1) = 0;
               bus(bus_queue_list(1)).speed = 1;
               bus_queue_list(1) = []; 
           end
       else
           bus(bus_queue_list(1)).reaction_time = back_headway; %hsg
           bus(bus_queue_list(1)).speed = 0;
       end 
    end 
    for i = 1: length(bus_running_list)
        if i <= length(bus_running_list)
            if berth_num ~= 1  % ������1��berth��ʱ��Ҫÿ��check berth��״̬
                berth = check_berth_state(bus_lane_list,bus,berth,bus_location,berth_location,adjacent_lane_list);
            end
            if bus(bus_running_list(i)).mission == 1 % �����жϸ����������� ���Ϊ1����ʾ��վ
               if bus(bus_running_list(i)).target_berth == 0 || bus(bus_running_list(i)).lane_No == 2
                    [temp_berth_assigned,bus,berth] = update_target_berth(bus_running_list(i),bus,berth,bus_location,bus_lane_list,berth_location,berth_num,lag_delay,thres_overtaking_in);
                    if temp_berth_assigned == 0 
                        if bus(bus_running_list(i)).target_berth ~= 0  %��busû�з��䵽berth��ʱ��֮ǰ�����berth����
                            berth(bus(bus_running_list(i)).target_berth).potential_bus = 0;
                        end
                        bus(bus_running_list(i)).target_berth = 0;
                    else
                        bus(bus_running_list(i)).target_berth = temp_berth_assigned;
                    end   
                end
                if bus(bus_running_list(i)).target_berth == 0  %���û��berth��bus�ȴ�
                    if bus_location(bus_running_list(i)) == 0  % ��stop��ڴ��ȴ���ʱ�����
                        bus(bus_running_list(i)).reaction_time = back_headway; %hsg 
                        if bus(bus_running_list(i)).wait_berth_start ~= 0  %��¼��ʼ�ȴ�ʱ��
                            bus(bus_running_list(i)).wait_berth_start = run_step;
                        end
                    else
                        bus(bus_running_list(i)).reaction_time = lag_delay; %hsg 
                    end
                    bus(bus_running_list(i)).speed = 0;
                    bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                    continue;
                end
                if bus(bus_running_list(i)).lane_No == 2  %�ó���������������berth
                    if bus_location(bus_running_list(i)) < berth_location(bus(bus_running_list(i)).target_berth)
                        if bus(bus_running_list(i)).current_lane ~= bus(bus_running_list(i)).lane_No
                            bus(bus_running_list(i)).current_lane = 2;
                            adjacent_lane_list(length(adjacent_lane_list)+1) = bus_running_list(i); 
                            bus_lane_list(bus_lane_list == bus_running_list(i)) = [];
                        end
                        if is_possible_procede(bus_running_list(i),adjacent_lane_list,bus,berth,bus_location,berth_location) %�ж��Ƿ�ǰ��
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                        else
                            bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            bus(bus_running_list(i)).speed = 0;
                        end
                        if bus_location(bus_running_list(i)) > berth_location(bus(bus_running_list(i)).target_berth+1) && berth(bus(bus_running_list(i)).target_berth).current_bus == 0
                            berth(bus(bus_running_list(i)).target_berth).current_bus = bus_running_list(i);  %��ǰ����berth
                        end   
                        if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth) %(bus(bus_running_list(i)).speed == 0 || bus_location(bus_running_list(i),run_step) == berth_location(1))
                            if is_possible_overtaking_in(bus_running_list(i),bus_lane_list,bus_location)
                               bus(bus_running_list(i)).lane_No = 1;
                               bus(bus_running_list(i)).current_lane = 1;
                               bus_lane_list = lane_change(bus_running_list(i),bus_lane_list,bus_location);
                               adjacent_lane_list(adjacent_lane_list == bus_running_list(i)) = [];
                               [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                            else
                               bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            end  
                        end
                        bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                        continue;
                    else
                        if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth)
                           bus(bus_running_list(i)).speed = 0;
                           if bus_location(bus_running_list(i)) > berth_location(bus(bus_running_list(i)).target_berth+1) && berth(bus(bus_running_list(i)).target_berth).current_bus == 0
                               berth(bus(bus_running_list(i)).target_berth).current_bus = bus_running_list(i);
                           end 
                           if is_possible_overtaking_in(bus_running_list(i),bus_lane_list,bus_location) 
                               if bus(bus_running_list(i)).reaction_time >= 0
                                   bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step;  
                                   if bus(bus_running_list(i)).reaction_time <= 0
                                       bus(bus_running_list(i)).lane_No = 1;
                                       bus(bus_running_list(i)).current_lane = 1;
                                       bus_lane_list = lane_change(bus_running_list(i),bus_lane_list,bus_location);
                                       adjacent_lane_list(adjacent_lane_list == bus_running_list(i)) = [];
                                       [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                                   end
                               end
                           else
                               bus(bus_running_list(i)).reaction_time = back_headway; %hsg 
                           end
                           bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                           continue;
                        end
                    end   
                else  %bus(bus_running_list(i)).lane_No == 1:�ó������Գ������룬��lane-1��˳���վ
                    if bus(bus_running_list(i)).current_lane ~= bus(bus_running_list(i)).lane_No
                        if bus(bus_running_list(i)).current_lane == 2 % ԭ�����ڳ������ģ����ʱ��Ҫ��������
                            if is_possible_overtaking_in(bus_running_list(i),bus_lane_list,bus_location)
                                if bus(bus_running_list(i)).reaction_time <= 0  % ��Ϊbus�뿪berth��ʱ����4��t,����Ӧʱ����3��t����ˣ������Ի���������ʱ�򣬾���4��t��ʱ���ˣ����Կ�bus�뿪��ʱ����û�г�����Ӧʱ��
                                    bus(bus_running_list(i)).current_lane = 1;
                                    bus_lane_list = lane_change(bus_running_list(i),bus_lane_list,bus_location);
                                    adjacent_lane_list(adjacent_lane_list == bus_running_list(i)) = [];
                                    if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth)%(bus(bus_running_list(i)).speed == 0 || bus_location(bus_running_list(i),run_step) == berth_location(1))
                                        [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                                        bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                                        continue;
                                    end
                                else
                                    bus(bus_running_list(i)).speed = 0;
                                    bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step; %hsg 
                                end
                            else
                                bus(bus_running_list(i)).speed = 0;
                                bus(bus_running_list(i)).reaction_time = back_headway; %hsg 
                                bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                                continue;
                            end
                        else
                            bus(bus_running_list(i)).current_lane = 1;
                            if isempty(find(bus_lane_list == bus_running_list(i))) == 1 % ����ó�����bus_lane_list�У�����Ҫ����
                                bus_lane_list(length(bus_lane_list)+1) = bus_running_list(i);
                            end
                        end
                    end
                    if bus(bus_running_list(i)).current_lane == 1
                        if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth)
                            [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                            bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                            continue;
                        end
                        if is_possible_procede(bus_running_list(i),bus_lane_list,bus,berth,bus_location,berth_location)
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                        else 
                            bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            bus(bus_running_list(i)).speed = 0;
                        end
                        if bus_location(bus_running_list(i)) > berth_location(bus(bus_running_list(i)).target_berth)-40 && berth(bus(bus_running_list(i)).target_berth).current_bus == 0
                            berth(bus(bus_running_list(i)).target_berth).current_bus = bus_running_list(i);  %��ǰ����berth
                        end   
                        if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth)%(bus(bus_running_list(i)).speed == 0 || bus_location(bus_running_list(i),run_step) == berth_location(1))
                            [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                            bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                            continue;
                        end
                    end
                end
            end
            if bus(bus_running_list(i)).mission == 2 % �����жϸ����������� ���Ϊ2����ʾ������
                bus(bus_running_list(i)).speed = 0;
%                 [bus,berth] = bus_servicing(bus_running_list(i),bus,berth,bus_location,berth_location);
                if round(bus(bus_running_list(i)).service_time,4) > 0
                    bus(bus_running_list(i)).service_time = bus(bus_running_list(i)).service_time - time_step;
                    if bus(bus_running_list(i)).reaction_time > 0
                        bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step;
                    end
                    if bus(bus_running_list(i)).lanechange_time > 0
                        bus(bus_running_list(i)).lanechange_time = bus(bus_running_list(i)).lanechange_time - time_step;
                    end
                else
                    bus(bus_running_list(i)).mission = 3;
                    bus(bus_running_list(i)).current_lane = 1;
                    berth(bus(bus_running_list(i)).berthNo).potential_bus = 0;
                    bus(bus_running_list(i)).service_finished = run_step-1;
                    if bus_location(bus_running_list(i)) == berth_location(1)  %�������ε�berth��bus��վ��ֱ���뿪stop
                        bus(bus_running_list(i)).mission = 4;
                    end 
                end
            end
            if bus(bus_running_list(i)).mission == 3 % �����жϸ����������� ���Ϊ3����ʾ��վ  
                if bus(bus_running_list(i)).current_lane == 1  % bus�� lane-1������
                    if bus(bus_running_list(i)).pro_overtaking_out <= thres_overtaking_out  %��������Գ�����ȥ�������ʱû�з�Ӧʱ����˳����Գ�վ������˳���վ
                        if bus(bus_running_list(i)).reaction_time <= 0 && is_possible_procede(bus_running_list(i),bus_lane_list,bus,berth,bus_location,berth_location)
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                            bus(bus_running_list(i)).lanechange_time = 0;
                        else  % �����ʱ����˳���վ�����Ƿ���Գ�����վ                       
                           if is_possible_overtaking_out(bus_running_list(i),adjacent_lane_list,bus_location)
                               if bus(bus_running_list(i)).lanechange_time <= 0
                                   bus(bus_running_list(i)).reaction_time = 0;
                                   adjacent_lane_list = lane_change(bus_running_list(i),adjacent_lane_list,bus_location);
                                   bus(bus_running_list(i)).current_lane = 2;
                                   bus_lane_list(bus_lane_list == bus_running_list(i)) = [];
                                   if is_possible_procede(bus_running_list(i),adjacent_lane_list,bus,berth,bus_location,berth_location)
                                       [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                                   else
                                       bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                                       bus(bus_running_list(i)).speed = 0;
                                   end
                               else
                                   bus(bus_running_list(i)).speed = 0;
                                   bus(bus_running_list(i)).lanechange_time = bus(bus_running_list(i)).lanechange_time-time_step; %hsg
                                   bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step; % ���ǰ��һ�������ˣ���ʼ��Ӧʱ�䵹��ʱ
                               end
                           else
                               bus(bus_running_list(i)).lanechange_time = back_headway; %hsg
                               bus(bus_running_list(i)).speed = 0;
                               bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step;% ���ǰ��һ�������ˣ���ʼ��Ӧʱ�䵹��ʱ
                           end
                        end
                    else  % ���ܳ�����ȥ
                        if is_possible_procede(bus_running_list(i),bus_lane_list,bus,berth,bus_location,berth_location)
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);                
                        else
                            bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            bus(bus_running_list(i)).speed = 0;
                        end 
                    end
                else
                    if bus(bus_running_list(i)).current_lane == 2  % bus������ȥ�� lane-2������
                       if is_possible_procede(bus_running_list(i),adjacent_lane_list,bus,berth,bus_location,berth_location)
                           [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                       else
                           bus(bus_running_list(i)).reaction_time = back_headway;  %hsg
                           bus(bus_running_list(i)).speed = 0;
                       end
                    end
                end
                if bus_location(bus_running_list(i)) == berth_location(1) 
                    bus(bus_running_list(i)).mission = 4;
                    bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                    continue;
                end
            end
            if bus(bus_running_list(i)).mission == 4  % ����5��bus�뿪����ں󣬼�����ʻһ�ξ���
                if bus(bus_running_list(i)).reaction_time > 0
                    bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step;
                    bus(bus_running_list(i)).speed = 0; 
                else
                    bus_location(bus_running_list(i)) = bus_location(bus_running_list(i)) + 1;
                    bus(bus_running_list(i)).speed = 1;
                    if bus(bus_running_list(i)).current_lane == 1 && berth(1).current_bus == bus_running_list(i) 
                        berth(1).current_bus = 0;
                        if berth(2).current_bus ~= 0 && bus(berth(2).current_bus).speed == 0 
                            bus(berth(2).current_bus).reaction_time = back_headway;
                            bus(berth(2).current_bus).lanechange_time = back_headway;
                        end
                    end
                end
                if bus_location(bus_running_list(i)) >= berth_location(1) + 40
                    delate_arry(length(delate_arry)+1) = bus_running_list(i);
                    bus(bus_running_list(i)).speed = 0;
                    bus(bus_running_list(i)).end_step = run_step;
                end
            end
            bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
        end
    end
    if isempty(delate_arry) ~= 1
        for k = 1:length(delate_arry)
            if k <= length(delate_arry) && delate_arry(k) ~= 0
                adjacent_lane_list(adjacent_lane_list == delate_arry(k)) = [];
                bus_lane_list(bus_lane_list == delate_arry(k)) = [];
                bus_running_list(bus_running_list == delate_arry(k)) = []; 
                delate_arry(k) = 0;
            end
        end
        delate_arry = [];
    end
    %���µ���bubus_running_list�е�bus���µ�˳�򣬱�֤�������������θ��£�
    %��Ҫ�Ƿ�ֹ����ĳ������뵽ǰ�棬��ʱ���µ�˳���������������
    %delate_arry = bus_lane_list; ��ʱ����bus_lane_list�ĳ���λ��
    if isempty(adjacent_lane_list) ~= 1
        if isempty(bus_lane_list) ~= 1
            delate_arry = bus_lane_list;
            for k = 1:length(adjacent_lane_list)
                delate_arry = combine_bus(adjacent_lane_list(k),delate_arry,bus_location);
            end
            bus_running_list(1:length(delate_arry))  = delate_arry;
            delate_arry = [];
        else
            bus_running_list(1:length(adjacent_lane_list)) = adjacent_lane_list;
        end
    else
        bus_running_list(1:length(bus_lane_list)) = bus_lane_list;
    end
    delate_arry = [];
    if bus_count > bus_num && isempty(bus_running_list) && isempty(bus_queue_list)  
        last_bus_endtime = current_time;
        break;
    end
end  
% ------output capacity------------%
bus_stop_capacity = bus_num / ((last_bus_endtime - bus_arrival_time(1))/3600)
% for k = 1:bus_num 
%     %����ʱ���������֣���1������Queueλ��ͣ��-��Queueλ������ ��2������stop��ڴ�ͣ��-����ڴ�����
%     %��3��������-�뿪stop,����������berth�뿪stop��move-upʱ��
%     average_delay = average_delay + (bus(k).start_run - bus(k).enter_queue)*time_step + (bus(k).wait_berth_end-bus(k).wait_berth_start)*time_step...
%         + ((bus(k).end_step-4)-bus(k).service_finished)*time_step-(bus(k).berthNo-1)*unit_movlength*time_step;%һ��berth�ĸ�ÿ���ƶ�ʱ��time_step
% end
% average_delay = average_delay/bus_num
draw = 1;
if draw == 1
    figure(1)
    %plot  buffer
    x = [0,current_time];
    for count = 1:berth_num
        y_berth = [berth_location(count), berth_location(count)];
        plot(x,y_berth,'k--');
        hold on;
    end
    hold on;
    %plot  bus trajectory
    current_time = bus_arrival_time(1);
    for k = 1:bus_num
        for n = 1:bus(k).end_step-bus(k).start_run
            if n >= bus(k).enter_berth-bus(k).start_run+1 && n <= bus(k).service_finished-bus(k).start_run
                line([(n-1)*time_step+current_time+bus(k).start_run*time_step,n*time_step+current_time+bus(k).start_run*time_step],[bus_location_plot(k,n),bus_location_plot(k,n+1)],'linewidth',2,'color','r');
            else
                line([(n-1)*time_step+current_time+bus(k).start_run*time_step,n*time_step+current_time+bus(k).start_run*time_step],[bus_location_plot(k,n),bus_location_plot(k,n+1)],'linewidth',1);
            end    
        end
        hold on
    end
end
toc