% % º∆À„capacity
% seq_std=std(each_capacity);
% seq_mean=mean(each_capacity);
% r=seq_std/(seq_mean*thres);
% r = round(r);
clear;
clc  
tic
run_num = 3;
service_cs_number = [0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
% service_cs_number = 0.01;
service_cs = 0;
each_capacity = zeros(1,run_num);
capacity_average = zeros(1,length(service_cs_number));
% capacity_average = zeros(1,8);
berth_number = 2;
overtaking_in = 0;
overtaking_out = 0;
thres = 0.001;
for m = 1: length(service_cs_number)
     service_cs = service_cs_number(m);
    for n = 1: run_num
        each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
        capacity_average(m) = capacity_average(m)+each_capacity(n);
        fprintf('1_n = %d\n',n);
    end
    capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
end
 toc
% seq_std=std(each_capacity);
% seq_mean=mean(each_capacity);
% r=seq_std/(seq_mean*thres);
% r = round(r);
xlswrite('capacity.xlsx',capacity_average',6,'A1');
% toc
berth_number = 2;
overtaking_in = 0;
overtaking_out = 1;
each_capacity = zeros(1,run_num);
capacity_average = zeros(1,length(service_cs_number));
for m = 1: length(service_cs_number)
      service_cs = service_cs_number(m);
    for n = 1: run_num
        each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
        capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('2_n = %d\n',n);
    end
    capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
end
xlswrite('capacity.xlsx',capacity_average',6,'B1');
% % toc
berth_number = 2;
overtaking_in = 1;
overtaking_out = 1;
each_capacity = zeros(1,run_num);
capacity_average = zeros(1,length(service_cs_number));
for m = 1: length(service_cs_number)
      service_cs = service_cs_number(m);
    for n = 1: run_num
        each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
        capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('2_n = %d\n',n);
    end
    capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
end
xlswrite('capacity.xlsx',capacity_average',6,'C1');
berth_number = 2;
overtaking_in = 1;
overtaking_out = 1;
each_capacity = zeros(1,run_num);
capacity_average = zeros(1,length(service_cs_number));
for m = 1: length(service_cs_number)
      service_cs = service_cs_number(m);
    for n = 1: run_num
        each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
        capacity_average(m) = capacity_average(m)+each_capacity(n);
        fprintf('2_n = %d\n',n);
    end
    capacity_average(m) = capacity_average(m) / run_num;
    fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
end
xlswrite('capacity.xlsx',capacity_average',6,'D1');
% overtaking_in = 1;
% overtaking_out = 1;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
% %         fprintf('3_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
% %     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity.xlsx',capacity_average',3,'D2');
toc
% berth_number = 3;
% overtaking_in = 0;
% overtaking_out = 0;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('1_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity.xlsx',capacity_average',1,'E1');
% overtaking_in = 0;
% overtaking_out = 1;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('2_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity.xlsx',capacity_average',1,'F1');
% overtaking_in = 1;
% overtaking_out = 0;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('2_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity.xlsx',capacity_average',1,'G1');
% overtaking_in = 1;
% overtaking_out = 1;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('3_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity.xlsx',capacity_average',1,'H1');
% berth_number = 4;
% overtaking_in = 1;
% overtaking_out = 1;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(1,length(service_cs_number));
% for m = 1: length(service_cs_number)
%       service_cs = service_cs_number(m);
%     for n = 1: run_num
%         each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%         capacity_average(m) = capacity_average(m)+each_capacity(n);
%         fprintf('1_n = %d\n',n);
%     end
%     capacity_average(m) = capacity_average(m) / run_num;
%     fprintf('capacity_average(%d) = %d\n',m,capacity_average(m));
% end
% xlswrite('capacity_blockbus.xlsx',capacity_average',1,'B1');
% clear;
% clc  
% tic
% run_num = 15;
% P = 0:0.1:1;
% Q = 0:0.1:1;
% service_cs = 0.3;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(length(P),length(Q));
% berth_number = 2;
% for m = 1: length(P)
%     overtaking_in = P(m);
%     for k = 1: length(Q)
%         overtaking_out = Q(k);
%       for n = 1: run_num
%           each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%           capacity_average(m,k) = capacity_average(m,k)+each_capacity(n);
%           fprintf('1_n = %d\n',n);
%       end
%      capacity_average(m,k) = capacity_average(m,k) / run_num;
%      fprintf('capacity_average(%d) = %d\n',m,capacity_average(m,k));
%     end
% end
% xlswrite('capacity_pq1.xlsx',capacity_average,1);
% service_cs = 0.8;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(length(P),length(Q));
% berth_number = 2;
% for m = 1: length(P)
%     overtaking_in = P(m);
%     for k = 1: length(Q)
%         overtaking_out = Q(k);
%       for n = 1: run_num
%           each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%           capacity_average(m,k) = capacity_average(m,k)+each_capacity(n);
%           fprintf('2_n = %d\n',n);
%       end
%      capacity_average(m,k) = capacity_average(m,k) / run_num;
%      fprintf('capacity_average(%d) = %d\n',m,capacity_average(m,k));
%     end
% end
% xlswrite('capacity_pq1.xlsx',capacity_average,2);
% service_cs = 0.3;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(length(P),length(Q));
% berth_number = 3;
% 
% for m = 1: length(P)
%     overtaking_in = P(m);
%     for k = 1: length(Q)
%         overtaking_out = Q(k);
%       for n = 1: run_num
%           each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%           capacity_average(m,k) = capacity_average(m,k)+each_capacity(n);
%           fprintf('3_n = %d\n',n);
%       end
%      capacity_average(m,k) = capacity_average(m,k) / run_num;
%      fprintf('capacity_average(%d) = %d\n',m,capacity_average(m,k));
%     end
% end
% xlswrite('capacity_pq1.xlsx',capacity_average,3);
% service_cs = 0.8;
% each_capacity = zeros(1,run_num);
% capacity_average = zeros(length(P),length(Q));
% berth_number = 3;
% for m = 1: length(P)
%     overtaking_in = P(m);
%     for k = 1: length(Q)
%         overtaking_out = Q(k);
%       for n = 1: run_num
%           each_capacity(n) = capacity_blockbus_clc(berth_number,service_cs,overtaking_in,overtaking_out);
%           capacity_average(m,k) = capacity_average(m,k)+each_capacity(n);
%           fprintf('4_n = %d\n',n);
%       end
%      capacity_average(m,k) = capacity_average(m,k) / run_num;
%      fprintf('capacity_average(%d) = %d\n',m,capacity_average(m,k));
%     end
% end
% xlswrite('capacity_pq1.xlsx',capacity_average,4);