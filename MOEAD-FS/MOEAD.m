function [best_member, F1] = MOEAD(X, Y,k)
    % parameter setting
    n_feature = size(X, 2);
    n_obj = 3;
    n_pop = min(round(n_feature / 20), 300);
    n_iter = 10;
    mul=zeros(1,n_feature);
      for i = 1:n_feature
         mul(i) = MItest(X(:,i),Y);
      end
      mul_rate=mul/max(mul);
       mul_rank=-sort(-mul);

    [W,n_pop]=UniformPoint(n_pop,n_obj);
    T = ceil(n_pop/10);
    
    B = pdist2(W,W);
    [~,B] = sort(B,2);
    B = B(:,1:T);
    
    individual.position = [];
    individual.cost = [];
    pop = repmat(individual, n_pop, 1);
    parfor i = 1:n_pop
        position = unifrnd(0, 1, 1, n_feature) > 0.5;
        pop(i).position = position;
        pop(i).cost = fitness(X, Y, position);
    end
      Z = min([pop.cost]', [], 1);
      F=nondominated_sort(pop);
      F1=pop(F{1});
      Fl = pop(F{end});
    for iter = 1:n_iter
        iter_start = clock;
        for i=1:n_pop
            Parents = B(i,randperm(size(B,2)));
             popc = crossover_pop(pop(Parents(1:2)),1,X,Y);
              Offspring=mutate_pop(popc,n_pop, X, Y,Fl);
             Z = min(Z, [Offspring.cost]');
              Zmax  = max( [pop.cost]', [], 1);
              pp=zeros(size(Parents,2),n_obj);
             for kk=1:size(Parents,2)
                 pp(kk,:) = pop(Parents(kk)).cost;
             end
              g_old = max(abs(pp-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(Parents,:),[],2);
              g_new = max(repmat(abs((Offspring.cost)'-Z)./(Zmax-Z),T,1).*W(Parents,:),[],2);
              
              pop(Parents(g_old>=g_new)) = Offspring;
        end

          F=nondominated_sort(pop);
          F1=pop(F{1});
          Fl = pop(F{end});

        iter_end = clock;
        avgfit = mean([F1.cost], 2);
        logger(['iter: ', num2str(iter), '/', num2str(n_iter), ' time: ', num2str(etime(iter_end, iter_start)), 's', ...
            ' fit: ', num2str(avgfit(1)), ', ', num2str(avgfit(2)), ', ', num2str(avgfit(3))]);
           if k==1
           si=size(F1,1);
           for ii=1:si
               result(ii,1:n_feature)=[F1(ii).position*1];
               result(ii,n_feature+1:n_feature+3)=[F1(ii).cost];
           end
           xlswrite('Prostate6033(moead).xls', result(:,n_feature+1:n_feature+3),iter);      % ��resultд�뵽wind.xls�ļ���
           end
    end
    best_member = solution_selection(F1);
end

function best_member = solution_selection(F1)
    n_F1 = numel(F1);
    best_member = F1(1);
    for i = 2:n_F1
        if F1(i).cost(1) < best_member.cost(1)
            best_member = F1(i);
        elseif F1(i).cost(1) == best_member.cost(1) && F1(i).cost(2) < best_member.cost(2)
            best_member = F1(i);
        end
    end
end