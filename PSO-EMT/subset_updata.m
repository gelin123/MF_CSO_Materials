function pop = subset_updata(pop,n_pop,selected_feature,n_feature)
num_change=floor(0.05*selected_feature);
mark=0;
subset=[];
for i=1:n_pop
    if pop(i).task_mark==1
        mark=mark+1;
        mark_set=zeros(1,n_feature);
        count0=0;
        count1=1;
        if mark==1
            while count0<10 && count1<10
                kk=randi([1,n_feature]);
                if mark_set(kk)==0
                    if pop(i).taskfea(kk)==0 && count0<10
                        pop(i).taskfea(kk)=1;
                        count0=count0+1;
                    elseif pop(i).taskfea(kk)==1 && count1<10
                        pop(i).taskfea(kk)=0;
                        count1=count1+1;
                    end
                end
            end
        end
    end
end
end

