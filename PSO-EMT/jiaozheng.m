function position = jiaozheng(position,n_feature,search_range,mark)
if mark==1
    search_range=ones(1,n_feature);
end
for i=1:n_feature
    if position(i)<0
        position(i)=0;
    end
    if position(i)>search_range(i)
        position(i)=search_range(i);
    end
    
end


end

