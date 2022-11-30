function search_range = range_init(weight,n_feature,knee_point)
search_range=ones(1,n_feature);
fmin=min(weight);
for i=1:n_feature
    if weight(i)<0
        search_range(i)=0.7;
    elseif weight(i)<knee_point
        high=(weight(i)-fmin)/(knee_point-fmin);
        high=high*0.3+0.7;
        search_range(i)=high;
    end
end

end

