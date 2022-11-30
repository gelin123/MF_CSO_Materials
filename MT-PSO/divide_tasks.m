function [task,task_size,pool] = divide_task(X,n_feature,idx,weight,pool)
     for i=1:size(weight,2)
         task_size(i,1)=i;
         task_size(i,2)=weight(1,i);
     end
     relieff_task=sortrows(task_size,2);
     task=[];
     task_size=[];
     for i =1:n_feature
          if (isnan(weight(i)))
              weight(i)=-999999;     
           end
     end
     x1 = 1;
     y1 = relieff_task(1,2);
     x2 = size(relieff_task,1);
     y2 = relieff_task(x2,2);
     k = (y1-y2)/(x1-x2);
     b = y1-k*x1;
     d = zeros(size(relieff_task,1),1);
     for i = 1:size(d,1)
         d(i) = abs(k*i+b-relieff_task(i,2))/sqrt(k*k+1);
     end
     [~,kneepoint_idx] = max(d);
     %plot(sort(relieff_task,2))
     kneepoint=relieff_task(kneepoint_idx,2);
     importance=[];
     k=1;
     kk=1;
     unimportance=[];
     for i=1:n_feature
         if weight(i)>kneepoint
            importance(k)=weight(i);
            k=k+1;
         else
             unimportance(kk)=weight(i);
             kk=kk+1;
         end
     end
     p=mean(importance)/(mean(importance)+mean(unimportance));
      if (p>1)
          p=0.9;
      end
%      if (isnan(p))
%          p=0.5;     
%      end
      if (p<0)
          p=0.1;
      end
     feature_set=ones(1,n_feature);
     time=0;
     import_num=0;
     import_sum=size(importance,2);
     while import_num<import_sum
         time=time+1;
         if time>1 && task_size(time-1,1)==0
             time=time-1;
         end
         task_size(time,1)=0;
         for i=1:n_feature
             if weight(i)>kneepoint
                 p_rand=rand;
                 if p_rand<=p && feature_set(1,i)==1
                     task(time,i)=1;
                     task_size(time,1)=task_size(time,1)+1;
                     feature_set(1,i)=0;
                     import_num=import_num+1;
                 else
                     task(time,i)=0;
                 end
             else
                 p_rand=rand;
                 if p_rand<1-p && feature_set(1,i)==1
                     task(time,i)=1;
                     task_size(time,1)=task_size(time,1)+1;
                     feature_set(1,i)=0;
                 else
                     task(time,i)=0;
                 end
             end
         end
     end
     aa=1;
end