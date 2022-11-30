function [best_member, F1_new] = multitask(X,Y,k)
    % parameter setting
    n_feature = size(X, 2);
    pool=ones(1,n_feature);
%     n_obj = 3;
    group=1;
    task_size=[];
%     n_pop = min(round(n_feature / 20), 300); 
%     n_pop = 30;
    n_iter = 70;
    mul=zeros(1,n_feature);
      for i = 1:n_feature
         %X1=X(:,i);
         mul(i) = MItest(X(:,i),Y);
      end
       [mul_rank,pos]=sort(mul);
       mul_rank1=fliplr(mul_rank);
       pos1=fliplr(pos);
%        plot(mul_rank1);
       fea_rank=[pos1',mul_rank1'];
       
       %divide group
%        while (sum(pool)~=0)
%            [task,pool]=divide_task(X,n_feature,fea_rank,pool);
           [task_map,task_size,pool]=clusting_task(X,n_feature,fea_rank,pool);
%            if group==1
%                task_map=task;
%            else
%                task_map=[task_map task];
%            end
%            task_size=[task_size;sum(task)];
%            group=group+1;

%        end
%        task_map=task_map';
% 
     task_num=10;
     
     
     n_pop = 30*task_num;
    individual.taskfea=[];
    individual.position = [];
    individual.cost = [];
    individual.task_mark=[];
    lastp.position=[];
    lastp.cost=[];
    pop = repmat(individual, n_pop, 1);
    
    j=0;
     for i = 1:n_pop
        ii=mod(i,task_num);
        if ii==1
            j=j+1;
        end
        if ii==0
            ii=task_num;
        end
        position = rand(1,n_feature);
        pop(i).taskfea=task_map(ii,:);
        pop(i).position = position;
        [pop(i).cost,pop(i).position] = fitness2(X, Y, pop(i));
        pop(i).task_mark=ii;
        task_pop(ii,j)=i;
     end
     
 %CSO   
for iter = 1:n_iter
    iter_start = clock;
    winner_all=[];
    loser_all=[];
    v=zeros(n_pop,n_feature);
    %for each task
    for task_t=1:task_num
    winner=[];
    loser=[];
    task_in=task_pop(task_t,:);%该task中的个体
    p_num=size(task_in,2);
    p=randperm(size(task_in,2));%打乱后的数
    p_new=task_in(:,p);
    run_time=1;
    %compare
   while(run_time~=(p_num+1))
%         a=pop(p_new(run_time));
%         b=pop(p_new(run_time+1));
        [win,lose]=compare(pop,p_new,run_time);
        winner=[winner;win];
        loser=[loser;lose];
        run_time=run_time+2;
    end
    winner_all=[winner_all;winner];
    loser_all=[loser_all;loser];
    end
    transp=0.5;% 迁移概率p=0.5
    loser_num=size(loser_all,1);
%CSO进化
    for learn_time=1:loser_num
        if transp<rand
            %迁移
            win=winner_all(learn_time);
            lose=loser_all(learn_time);
            while (pop(win).task_mark==pop(lose).task_mark)&&(pop(win).cost(1)<=pop(lose).cost(1))
                rand_win=randperm(size(winner_all,1));%打乱后的数
                win=winner_all(rand_win(1),:);
            end
            new_v=rand*v(win,:)+rand*(pop(win).position-pop(lose).position);
            loser_position=pop(lose).position+new_v+rand*(new_v-v(lose,:));
            v(lose,:)=new_v;
            pop(lose).position=loser_position;
        else
            %不迁移
            win=winner_all(learn_time);
            lose=loser_all(learn_time);
            new_v=rand*v(win,:)+rand*(pop(win).position-pop(lose).position);
            loser_position=pop(lose).position+new_v+rand*(new_v-v(lose,:));
            v(lose,:)=new_v;
            pop(lose).position=loser_position;
        end
       [pop(lose).cost,~] = fitness2(X, Y, pop(lose));
    end
          F=nondominated_sort(pop);
          F1=pop(F{1});
          Fl = pop(F{end});
        % analysis
        iter_end = clock;
        avgfit = mean([F1.cost], 2);
        logger(['iter: ', num2str(iter), '/', num2str(n_iter), ' time: ', num2str(etime(iter_end, iter_start)), 's', ...
            ' fit: ', num2str(avgfit(1)), ', ', num2str(avgfit(2)), ', ', num2str(avgfit(3))]);
end
 F=nondominated_sort(pop);
 F1=pop(F{1});
 F1_num=size(F1,1);
 F1_new=repmat(lastp,F1_num,1);
 for aa=1:F1_num
      F1_new(aa).position = unifrnd(0, 1, 1, n_feature) > 0.5;
     for j=1:n_feature     
        if (F1(aa).position(j)>0.5)
            F1_new(aa).position(j)=1;
        else
            F1_new(aa).position(j)=0;
        end
     end
     if sum(F1_new(aa).position)==0
         F1_new(aa).position(1)=true;
     end
     F1_new(aa).cost = fitness(X, Y, F1_new(aa).position);
 end
 best_member = solution_selection(F1_new);
end

function best_member = solution_selection(F1)
    n_F1 = numel(F1);
    best_member = F1(1);
    for i = 2:n_F1
        if F1(i).cost(1) < best_member.cost(1)
            best_member = F1(i);
        elseif F1(i).cost(1) == best_member.cost(1) && F1(i).cost(2) < best_member.cost(2)
            best_member = F1(i);
        elseif F1(i).cost(1) == best_member.cost(1) && F1(i).cost(2) == best_member.cost(2)&&F1(i).cost(3) < best_member.cost(3)
            best_member = F1(i);
        end
    end
end
