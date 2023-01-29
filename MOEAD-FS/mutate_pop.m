function popm = mutate_pop(pop,n_pop, X, Y,Fl)
% mutation operation
%     individual.position = [];
%     individual.cost = [];
%     popm = repmat(individual, n_mutation, 1);
    popm=pop;
    for k = 1:n_pop


        
%         % no mutation retry
%          p = pop(randi(numel(pop)));
%          position = quick_bit_mutate(p.position);
           if rand<0.5
               popm.position(k)=~popm.position(k);
           end
         
    end
          cost = fitness(X, Y, popm.position);

% 

         popm.cost = cost;
end