function [best_member, F1_new] = MT_PSO(X,Y,k)
    % parameter setting
    n_feature = size(X, 2);
    pool=ones(1,n_feature);
    group=1;
%     task_size=[];
    n_iter = 100;
    [idx, weight] = relieff(X,Y,1);%weigth是1~n每个特征为的权重，idx是根据weigth排序后的结果。
%     for i=1:size(weight,2)
%         task_size(i,1)=i;
%         task_size(i,2)=weight(1,i);
%     end
%     task=sortrows(task_size,2);

       %divide group

%            [task_map,task_size,pool]=clusting_task(X,n_feature,fea_rank,pool);
            %[task_map,task_size,pool]=divide_two_tasks(X,n_feature,idx,weight,pool);
            [task_map,task_size,pool]=divide_tasks(X,n_feature,idx,weight,pool);

     task_num=size(task_size,1); 
     task_pop=ceil(100/task_num);
     selected_feature=task_size(1);
     n_pop = task_pop*task_num;
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
        
        [pop(i).cost,pop(i).position] = fitness3(X, Y, pop(i));
        pop(i).task_mark=ii;
        task_pop(ii,j)=i;
     end
     
 pbest=[];
 gbest=ones(task_num,n_feature+1);
 for i=1:n_pop
     pbest(i,1:n_feature)=pop(i).position;
     pbest(i,n_feature+1)=pop(i).cost;
     k=pop(i).task_mark;
     if pop(i).cost<gbest(k,n_feature+1)
         gbest(k,1:n_feature)=pop(i).position;
         gbest(k,n_feature+1)=pop(i).cost;
     end
 end
 c1=1.49445;
 c2=c1;
 c3=c1;
 max_m=10;%最大未变化次数
 m=0;
 %gbest_old=gbest(:,n_feature+1);
 count=ones(1,task_num);
for iter = 1:n_iter
    iter_start = clock;
   v=zeros(n_pop,n_feature);
   rmp=0.6;
   w=0.9-0.5*(iter/n_iter);
   new_gbest=ones(task_num,n_feature+1);
   for i=1:n_pop
       if rand>rmp
       t_task=pop(i).task_mark;
       t_task2=t_task;
       for chose_bestg=1:task_num
           if chose_bestg ~=t_task && gbest(chose_bestg,n_feature+1)<gbest(t_task2,n_feature+1)
               t_task2=chose_bestg;
           end
       end
       cr=unifrnd(0,1,1,n_feature);
       aaa=ones(1,n_feature);
       gbest_new=cr.*gbest(t_task,1:n_feature)+(aaa-cr).*gbest(t_task2,1:n_feature);
       %if count(1,t_task)>=5 && change_finess==gbest(t_task,n_feature+1)
       if count(1,t_task)>=6
            %task_change=[]
            task_change=mean(gbest(:,1:n_feature));
            %[change_finess,~]=fitness4(X, Y, task_change);
            gbest_new=task_change;
            %gbest(j,n_feature+1)=change_finess;
            %count(1,j)=1;   
        end
       v(i,:)=w*v(i,:)+c1*rand*(pbest(i,1:n_feature))+c2*rand*(gbest_new-pop(i).position);
       %v(i,:)=w*v(i,:)+c1*rand*(pbest(i,1:n_feature))+c2*rand*(gbest(t_task,1:n_feature)-pop(i).position)+c3*rand*(gbest(t_task2,1:n_feature)-pop(i).position);
        position=pop(i).position+v(i,:);
        position=jiaozheng(position,n_feature,pop(i).task_mark);
        [p_fitness,~]=fitness4(X, Y, position);
%        pop(i).position=position;
%      [pop(i).cost,pop(i).position] = fitness3(X, Y, pop(i));
        pop(i).position=position;
        pop(i).cost=p_fitness;
        pop(i).task_mark=t_task;
%        if rand<0.5
%            pop(i).task_mark=1;
%        else
%            pop(i).task_mark=2;
%        end
       else
       t_task=pop(i).task_mark;
        v(i,:)=w*v(i,:)+c1*rand*(pbest(i,1:n_feature))+c2*rand*(gbest(t_task,1:n_feature)-pop(i).position);
       position=pop(i).position+v(i,:);
       position=jiaozheng(position,n_feature,pop(i).task_mark);
          [p_fitness,~]=fitness4(X, Y, position);
          pop(i).position=position;
          pop(i).cost=p_fitness;
%           pop(i).position=position;
%           [pop(i).cost,pop(i).position] = fitness3(X, Y, pop(i));
       end
       if pop(i).cost<pbest(i,1+n_feature)
           pbest(i,1:n_feature)=pop(i).position;
           pbest(i,n_feature+1)=pop(i).cost;
       end
     if pop(i).cost<new_gbest(t_task,n_feature+1)
         new_gbest(t_task,1:n_feature)=pop(i).position;
         new_gbest(t_task,n_feature+1)=pop(i).cost;
     end
     if iter==n_iter
         pop(i).position=pbest(i,1:n_feature);
         pop(i).cost=pbest(i,n_feature+1);
     end
   end
   for j=1:task_num  
       if new_gbest(j,n_feature+1)==gbest(j,n_feature+1)
           count(1,j)=count(1,j)+1;
       end
       if new_gbest(j,n_feature+1)<gbest(j,n_feature+1)
          gbest(j,:)=new_gbest(j,:);
          count(1,j)=1;
       end
%         if count(1,j)==6
%             %task_change=[]
%             ttt=1;
%             task_change=mean(gbest(:,1:n_feature));
%             [change_finess,~]=fitness4(X, Y, task_change);
%             gbest(j,1:n_feature)=task_change;
%             gbest(j,n_feature+1)=change_finess;
%             count(1,j)=1;   
%         end
   end
        % analysis
        iter_end = clock;
        avgfit=mean(pbest(:,n_feature+1));
        logger(['iter: ', num2str(iter), '/', num2str(n_iter), ' time: ', num2str(etime(iter_end, iter_start)), 's', ...
            ' fit: ', num2str(avgfit)]);
end



%  F=nondominated_sort(pop);
 F1_num=size(pop,1);
 F1_new=repmat(lastp,F1_num,1);
 for aa=1:F1_num
      F1_new(aa).position = unifrnd(0, 1, 1, n_feature) > 0.5;
     for j=1:n_feature     
        if (pop(aa).position(j)>0.6)
            F1_new(aa).position(j)=1;
        else
            F1_new(aa).position(j)=0;
        end
     end
     if sum(F1_new(aa).position)==0
         F1_new(aa).position(1)=true;
     end
     F1_new(aa).cost = fitness(X, Y, F1_new(aa).position);
     if aa==1
         best_member=F1_new(aa);
     end
     if F1_new(aa).cost<best_member.cost
         best_member=F1_new(aa);
     end
 end
end

