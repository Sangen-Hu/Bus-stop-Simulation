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
%-----定义公交车属性的结构体-----%
bus = struct('mission',{},... % 1：进站 2：服务中 3：buffer区 4：离开
             'lane_No',{},... % 1：stop_lane 2：passing_lane
             'current_lane',{},...
             'service_time',{},...
             'speed',{},...   % 实时速度
             'berthNo',{},... % 停靠berth编号
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

%-----定义公交车位属性的结构体-----%
%------service_bus_id:车位被占用的车辆编号
%------available_time_berth:车辆在车位服务完的时间
%------status:0：不能通过红绿灯  1能通过红绿灯
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
bus_overtaking_in = unifrnd (0,1,1,bus_num);%产生超车进入车位概率服从均匀分布
bus_overtaking_out = unifrnd (0,1,1,bus_num);%产生超车驶离车位概率服从均匀分布
% -------2. rule set-------%
thres_overtaking_in = 0;    %超车进入下游空余车位的概率阈值
thres_overtaking_out = 1;   %上游bus超车驶出车位的概率阈值
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
unit_movlength = 40; % 以moveup_headway时间为一个berth长度，为精细化，将berth细分多个单元
delate_arry = [];
bus(1).start_run = 1;
temp_berth_assigned = 0;
%-----初始化--------%
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

% 初始化berth的位置
for count = 1: berth_num
    berth_location(count) = 40*(berth_num-count+1);
% berth的状态初始化  
    berth(count).potential_bus = 0;
    berth(count).current_bus = 0;
    berth(count).block = 0;
end
%-----初始时刻的状态--------% 
current_time = bus_arrival_time(1);
bus_count = 2;
run_step = 1;
bus_location(1) = 0;
time_step = moveup_headway/unit_movlength;
% lag_delay = 2 * time_step; %bus机械延迟时间
lag_delay = back_headway;
bus_time_interval = 0;
bus_queue_list(1) = 1;
bus(1).enter_queue = 1;
while 1
    if bus_count <= bus_num && bus_time_interval >= moveup_headway && current_time >= bus_arrival_time(bus_count)
        if isempty(bus_queue_list) ~= 1  %如果车队里没有车，则到达的车不需要加上反应时间
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
            if berth_num ~= 1  % 当超过1个berth的时候，要每次check berth的状态
                berth = check_berth_state(bus_lane_list,bus,berth,bus_location,berth_location,adjacent_lane_list);
            end
            if bus(bus_running_list(i)).mission == 1 % 首先判断该辆车的任务 如果为1：表示进站
               if bus(bus_running_list(i)).target_berth == 0 || bus(bus_running_list(i)).lane_No == 2
                    [temp_berth_assigned,bus,berth] = update_target_berth(bus_running_list(i),bus,berth,bus_location,bus_lane_list,berth_location,berth_num,lag_delay,thres_overtaking_in);
                    if temp_berth_assigned == 0 
                        if bus(bus_running_list(i)).target_berth ~= 0  %当bus没有分配到berth的时候，之前分配的berth清零
                            berth(bus(bus_running_list(i)).target_berth).potential_bus = 0;
                        end
                        bus(bus_running_list(i)).target_berth = 0;
                    else
                        bus(bus_running_list(i)).target_berth = temp_berth_assigned;
                    end   
                end
                if bus(bus_running_list(i)).target_berth == 0  %如果没有berth，bus等待
                    if bus_location(bus_running_list(i)) == 0  % 在stop入口处等待的时候加上
                        bus(bus_running_list(i)).reaction_time = back_headway; %hsg 
                        if bus(bus_running_list(i)).wait_berth_start ~= 0  %记录开始等待时间
                            bus(bus_running_list(i)).wait_berth_start = run_step;
                        end
                    else
                        bus(bus_running_list(i)).reaction_time = lag_delay; %hsg 
                    end
                    bus(bus_running_list(i)).speed = 0;
                    bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                    continue;
                end
                if bus(bus_running_list(i)).lane_No == 2  %该车借助超车道进入berth
                    if bus_location(bus_running_list(i)) < berth_location(bus(bus_running_list(i)).target_berth)
                        if bus(bus_running_list(i)).current_lane ~= bus(bus_running_list(i)).lane_No
                            bus(bus_running_list(i)).current_lane = 2;
                            adjacent_lane_list(length(adjacent_lane_list)+1) = bus_running_list(i); 
                            bus_lane_list(bus_lane_list == bus_running_list(i)) = [];
                        end
                        if is_possible_procede(bus_running_list(i),adjacent_lane_list,bus,berth,bus_location,berth_location) %判断是否前进
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                        else
                            bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            bus(bus_running_list(i)).speed = 0;
                        end
                        if bus_location(bus_running_list(i)) > berth_location(bus(bus_running_list(i)).target_berth+1) && berth(bus(bus_running_list(i)).target_berth).current_bus == 0
                            berth(bus(bus_running_list(i)).target_berth).current_bus = bus_running_list(i);  %提前锁定berth
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
                else  %bus(bus_running_list(i)).lane_No == 1:该车不可以超车进入，在lane-1中顺序进站
                    if bus(bus_running_list(i)).current_lane ~= bus(bus_running_list(i)).lane_No
                        if bus(bus_running_list(i)).current_lane == 2 % 原先是在超车道的，则此时需要换道进来
                            if is_possible_overtaking_in(bus_running_list(i),bus_lane_list,bus_location)
                                if bus(bus_running_list(i)).reaction_time <= 0  % 因为bus离开berth的时间是4个t,而反应时间是3个t，因此，当可以换道进来的时候，经过4个t的时间了，所以看bus离开的时间有没有超过反应时间
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
                            if isempty(find(bus_lane_list == bus_running_list(i))) == 1 % 如果该车不在bus_lane_list中，则需要加入
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
                            berth(bus(bus_running_list(i)).target_berth).current_bus = bus_running_list(i);  %提前锁定berth
                        end   
                        if bus_location(bus_running_list(i)) == berth_location(bus(bus_running_list(i)).target_berth)%(bus(bus_running_list(i)).speed == 0 || bus_location(bus_running_list(i),run_step) == berth_location(1))
                            [bus,berth] = check_arrive_berth(bus_running_list(i),bus,berth,bus_location,berth_location);
                            bus_location_plot(bus_running_list(i),run_step-bus(bus_running_list(i)).start_run+1) = bus_location(bus_running_list(i));
                            continue;
                        end
                    end
                end
            end
            if bus(bus_running_list(i)).mission == 2 % 首先判断该辆车的任务 如果为2：表示服务中
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
                    if bus_location(bus_running_list(i)) == berth_location(1)  %当最下游的berth的bus出站，直接离开stop
                        bus(bus_running_list(i)).mission = 4;
                    end 
                end
            end
            if bus(bus_running_list(i)).mission == 3 % 首先判断该辆车的任务 如果为3：表示出站  
                if bus(bus_running_list(i)).current_lane == 1  % bus在 lane-1，车道
                    if bus(bus_running_list(i)).pro_overtaking_out <= thres_overtaking_out  %如果车可以超车出去，如果此时没有反应时间且顺序可以出站，则先顺序出站
                        if bus(bus_running_list(i)).reaction_time <= 0 && is_possible_procede(bus_running_list(i),bus_lane_list,bus,berth,bus_location,berth_location)
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);
                            bus(bus_running_list(i)).lanechange_time = 0;
                        else  % 如果此时不能顺序出站，看是否可以超车出站                       
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
                                   bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step; % 如果前面一辆车走了，开始反应时间倒计时
                               end
                           else
                               bus(bus_running_list(i)).lanechange_time = back_headway; %hsg
                               bus(bus_running_list(i)).speed = 0;
                               bus(bus_running_list(i)).reaction_time = bus(bus_running_list(i)).reaction_time - time_step;% 如果前面一辆车走了，开始反应时间倒计时
                           end
                        end
                    else  % 不能超车出去
                        if is_possible_procede(bus_running_list(i),bus_lane_list,bus,berth,bus_location,berth_location)
                            [bus,berth,bus_location] = move_forward(bus_running_list(i),bus,berth,bus_location,berth_location,berth_num,bus_running_list);                
                        else
                            bus(bus_running_list(i)).reaction_time = back_headway; %hsg
                            bus(bus_running_list(i)).speed = 0;
                        end 
                    end
                else
                    if bus(bus_running_list(i)).current_lane == 2  % bus超车出去在 lane-2，车道
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
            if bus(bus_running_list(i)).mission == 4  % 任务5：bus离开交叉口后，继续行驶一段距离
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
    %重新调整bubus_running_list中的bus更新的顺序，保证从最下游往上游更新，
    %主要是防止后面的车辆插入到前面，此时更新的顺序从最下游往上游
    %delate_arry = bus_lane_list; 临时保存bus_lane_list的车辆位置
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
%     %延误时间有三部分：（1）到达Queue位置停车-从Queue位置启动 （2）到达stop入口处停车-从入口处启动
%     %（3）服务完-离开stop,这里会减掉从berth离开stop的move-up时间
%     average_delay = average_delay + (bus(k).start_run - bus(k).enter_queue)*time_step + (bus(k).wait_berth_end-bus(k).wait_berth_start)*time_step...
%         + ((bus(k).end_step-4)-bus(k).service_finished)*time_step-(bus(k).berthNo-1)*unit_movlength*time_step;%一个berth四格，每格移动时间time_step
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