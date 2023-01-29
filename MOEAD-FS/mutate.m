function popm = mutate(pop, n_feature, X, Y,mul_rate)
% mutation operation
    individual.position = [];
    individual.cost = [];
    popm = repmat(individual, 1, 1);
    popm.position=pop.position;
      for i=1:n_feature
          tt=rand;
          if mul_rate(i)<tt
              popm.position(i)=0;
          end
      end
      
       cost = fitness(X, Y,  popm.position);

%         popm.position = position;
        popm.cost = cost;
end

