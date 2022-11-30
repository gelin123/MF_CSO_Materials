function pop = subset_updata(pop,n_pop,selected_feature,n_feature)
num_change=floor(0.05*selected_feature);
mark=0;
subset=[];
for i=1:n_pop
    if pop(i).task_mark==1
        mark=mark+1;
        if mark==1
            for j=1:n_feature
                
            end
        end
    end
end
end

