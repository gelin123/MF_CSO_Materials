function [best_member, F1_new] = CSO(X,Y,k)
    % parameter setting
    n_feature = size(X, 2);
    pool=ones(1,n_feature);
    group=1;
    task_size=[];
    n_iter = 10;
    mul=zeros(1,n_feature);
          task_map=ones(1,n_feature);
     task_num=1 ;
     
     
     n_pop = 120*task_num;
    individual.taskfea=[];
    individual.position = [];
    individual.cost = [];
    individual.task_mark=[];
    lastp.position=[];
    lastp.cost=[];
    pop = repmat(individual, n_pop, 1);
    

     for i = 1:n_pop
        ii=1;
        position = rand(1,n_feature);
        pop(i).taskfea=task_map(ii,:);
        pop(i).position = position;
        [pop(i).cost,pop(i).position] = fitness2(X, Y, pop(i));
        pop(i).task_mark=ii;
        task_pop(1,i)=i;
     end
     

for iter = 1:n_iter
    iter_start = clock;
    winner_all=[];
    loser_all=[];
    v=zeros(n_pop,n_feature);
    for task_t=1:task_num
    winner=[];
    loser=[];
    task_in=task_pop(task_t,:);%��task�еĸ���
    p_num=size(task_in,2);
    p=randperm(size(task_in,2));%���Һ����
    p_new=task_in(:,p);
    run_time=1;
   while(run_time~=(p_num+1))
        [win,lose]=compare(pop,p_new,run_time);
        winner=[winner;win];
        loser=[loser;lose];
        run_time=run_time+2;
    end
    winner_all=[winner_all;winner];
    loser_all=[loser_all;loser];
    end
    transp=0.5
    loser_num=size(loser_all,1);
    for learn_time=1:loser_num
            win=winner_all(learn_time);
            lose=loser_all(learn_time);
            new_v=rand*v(win,:)+rand*(pop(win).position-pop(lose).position);
            loser_position=pop(lose).position+new_v+rand*(new_v-v(lose,:));
            v(lose,:)=new_v;
            pop(lose).position=loser_position;
       [pop(lose).cost,~] = fitness2(X, Y, pop(lose));
    end
     [winner_offspring,pop]=PM(winner_all,n_feature,X,Y,pop);
        iter_end = clock;
        avgfit=mean([pop.cost]);
        logger(['iter: ', num2str(iter), '/', num2str(n_iter), ' time: ', num2str(etime(iter_end, iter_start)), 's', ...
            ' fit: ', num2str(avgfit(1))]);
end
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
         best_nember=F1_new(aa);
     end
 end
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
function [childern,pop] = PM(winner,n_feature,X,Y,pop)
     parent=pop(winner);
    N=size(parent,1);%��Ⱥ��С
    D=n_feature;
    individual.taskfea=[];
    individual.position = [];
    individual.cost = [];
    individual.task_mark=[];
    childern = repmat(individual, N, 1);
    disM=20;
    for i=1:N
        Offspring(i,:)=parent(i).position;
    end
     Lower = repmat(0,N,D);
     Upper = repmat(1,N,D);
     Site  = rand(N,D) < 1/D;
     mu    = rand(N,D);
     temp  = Site & mu<=0.5;
     Offspring       = min(max(Offspring,Lower),Upper);
     Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                              (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
     temp = Site & mu>0.5; 
     Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
     (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
     for i=1:N
         childern(i).taskfea=parent(i).taskfea;
         childern(i).position=Offspring(i,:);
          childern(i).task_mark=parent(i).task_mark;
          [childern(i).cost,~] = fitness2(X, Y, childern(i));
          if childern(i).cost(1)>parent(i).cost(1)
             pop(winner(i)).position=parent(i).position;
             pop(winner(i)).cost=parent(i).cost;
          else
              pop(winner(i)).position=childern(i).position;
             pop(winner(i)).cost=childern(i).cost;
          end
     end

end