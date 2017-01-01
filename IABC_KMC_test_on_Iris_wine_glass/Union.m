clear all
close all
clc
%%%%%%%%%%***********在926—926基础上加入了全局，收敛更快且稳定********%%%%%%%%%%%%%
%%%%%%%%***********929在原有基础上将length改为size(**,1)这样是为了兼容高维数据*********%%%%%
tic

%Colony=load('D:\桌面\第一篇组合部件\k-means   matlab\rand919.txt');
%Colony=load('D:\桌面\第一篇组合部件\matlabwork\Iris913.txt');
iteration=1;
for r=1:3
    if(iteration==1)
          Colony=load('D:\桌面\第一篇组合部件\matlabwork\Iris913.txt');
          ABCOpts = struct( 'ColonySize',  10, ...  
    'MaxCycles', 100,...  
    'Limit',   10, ... %925原来是100，现在改为50，这样变化更大
     'lb',  0, ... 
    'ub',  8, ... 
    'ObjFun' , 'Sphere', ... 
    'RunTime',1); 
ColonyNumber=6;%这里在测试data.txt数据集时群体规模要大点，但是在测试rand922和rand919时只要等于蜜源，即要求的解个个数即可
      end
    
    
      if(iteration==2)
          Colony=load('D:\桌面\第一篇组合部件\matlabwork\balancescale929.txt');
          ABCOpts = struct( 'ColonySize',  10, ...  
    'MaxCycles', 100,...  
    'Limit',   10, ... %925原来是100，现在改为50，这样变化更大
     'lb',  0, ... 
    'ub',  5, ... 
    'ObjFun' , 'Sphere', ... 
    'RunTime',1); 
ColonyNumber=6;%这里在测试data.txt数据集时群体规模要大点，但是在测试rand922和rand919时只要等于蜜源，即要求的解个个数即可
      end
      
       if(iteration==3)
          Colony=load('D:\桌面\第一篇组合部件\matlabwork\glass929.txt');
          ABCOpts = struct( 'ColonySize',  10, ...  
    'MaxCycles', 100,...  
    'Limit',   10, ... %925原来是100，现在改为50，这样变化更大
     'lb',  0, ... 
    'ub',  76, ... 
    'ObjFun' , 'Sphere', ... 
    'RunTime',1); 
ColonyNumber=12;%这里在测试data.txt数据集时群体规模要大点，但是在测试rand922和rand919时只要等于蜜源，即要求的解个个数即可
      end


%**************初始化阶段******************      包括初始化蜂群中引领蜂和跟随蜂

ColonyTotal=testmaxmindistance915(Colony,ColonyNumber);%引领蜂+跟随蜂 总个数
%%
%***********928参数初始化**********
FitEmpArray=zeros(1,ABCOpts.MaxCycles);%928为了最后显示每次得到的FitEmp的变化趋势，所以需要存储起来
[datarow,datacolumn]=size(Colony);
centerNum=size(ColonyTotal,1);%929在数据集维数比length小时用length是可以的，但是当维数很大时就要用size(ColonyTotal,1)
Bas=zeros(1,(size(ColonyTotal,1)/2));
kindNum=linspace(0,0,size(ColonyTotal,1)/2);
sum1=zeros(datacolumn,size(ColonyTotal,1)/2);
%%
%926*************start计算各个点的适应度***************
center=ColonyTotal;
[newCenter,class,classCounterDistance]=calculateClassDistance(Colony',center',datarow,centerNum);

total=0;
sumDistance=zeros(1,size(ColonyTotal,1)/2);
FitEmp=zeros(1,size(ColonyTotal,1)/2);
for i=1:(size(ColonyTotal,1)/2)
    total=length(find(classCounterDistance(:,2)==i));
    sumDistance(i)=sum(classCounterDistance(classCounterDistance(:,2)==i,1));
  if(sumDistance(i)==0)
     FitEmp(i)=0;
  else
   FitEmp(i)=total/sumDistance(i);
  end
end
%%
%*********928按照适应度值大小筛选出引领蜂和跟随蜂
FitEmpClass=sortrows([FitEmp;1:ColonyNumber/2]');
% Onlooker=ColonyTotal(FitEmpClass(1:size(ColonyTotal,1)/2,2),:);
% Employed=setdiff(ColonyTotal,Onlooker,'rows');
%****************为了让FitEmp能和后面的FitEmp2行列一致，在这里按照Employed取其FitEmp值即：
% FitEmp=FitEmpClass(size(FitEmpClass)/2+1:size(FitEmpClass,1),1)';
Employed=ColonyTotal(FitEmpClass(1:size(ColonyTotal,1)/2,2),:);

 %%
 %*************927加上此段，主要是对分配好的Employed重新计算FitEmp这样保证更加精确，因为前面的FitEmp是在有Colony
 %Total个中心点的情况下求解的，但是加上之后迭代相对显的不是很稳定************
%     center=Employed;
%        centerNum=size(ColonyTotal,1)/2;
%        centerNum=size(ColonyTotal,1)/2;%这里是4个，因为这里要算的是引领蜂的类从属关系，前面是比较是比较ColonyTotal的适应度大小
%        [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',center',datarow,centerNum);
%        total=0;
%        sumDistance=zeros(1,size(ColonyTotal,1)/2);
%        FitEmp=zeros(1,size(ColonyTotal,1)/2);
%        for k=1:(size(ColonyTotal,1)/2)
%            total=length(find(classCounterDistance(:,2)==k));
%            sumDistance(k)=sum(classCounterDistance(classCounterDistance(:,2)==k,1));
%           if(sumDistance(k)==0)
%              FitEmp(k)=0;
%           else
%              FitEmp(k)=total/sumDistance(k);
%           end
%        end
    %%  103保证在结果图中的完整性，即一开始的FitEmp也会显示在结果图中
    %为了保持一致性，所以这里设置Cycle=1，下面的Cycle=1改为Cycle=2
        Cycle=1;
        FitEmpArray(Cycle)=sum(FitEmp); 
%%
%*****************全局**************
%   FitArrayCounterNumber=[FitEmp;1:length(ColonyTotal)/2]';%923先将Employed中的元素即引领蜂进行挨个编号
%   maxFitArray=sortrows(FitArrayCounterNumber);%将FitArrayCounterNumber数组按照行即适应度值大小从大到小排列，序号也跟随变化，形成新数组maxFitArray
  Employed_Best=Employed(size(Employed,1),:);%找出maxFitArray中最后一个元素即适应度值最大者所对应的的角标在Employed中找到对应点的位置坐标
  Employed_SecondBest=Employed(size(Employed,1)-1,:);

%*************end计算适应度，并排序和赋值**************

%%

    Cycle=2;
    y=1;
    while (Cycle <= ABCOpts.MaxCycles&&((length(find((Employed(:,1))==999))<5)))
      %% Employed Bee
        Employed2=Employed;
       for i=1:size(ColonyTotal,1)/2
        Param2Change=fix(rand*datacolumn)+1;%对应于j
        neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于k
        neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于p
            while(neighbour==i||neighbour1==i||neighbour==neighbour1)
                neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;
                neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;
            end;
        Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(neighbour,Param2Change)-Employed(neighbour1,Param2Change))*(rand-0.5)*2+(Employed_Best(1,Param2Change)-Employed(i,Param2Change))*(rand-0.5)*2;
           if (Employed2(i,Param2Change)<ABCOpts.lb)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;
           if (Employed2(i,Param2Change)>ABCOpts.ub)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;
     
       %926*******************start对邻域搜索的点进行重新分类，并计算适应度*****************
       center=Employed2;
       centerNum=size(ColonyTotal,1)/2;
       centerNum=size(ColonyTotal,1)/2;%这里是4个，因为这里要算的是引领蜂的类从属关系，前面是比较是比较ColonyTotal的适应度大小
       [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',center',datarow,centerNum);
       total2=0;
       sumDistance2=zeros(1,size(ColonyTotal,1)/2);
       FitEmp2=zeros(1,size(ColonyTotal,1)/2);
       for k=1:(size(ColonyTotal,1)/2)
           total2=length(find(classCounterDistance(:,2)==k));
           sumDistance2(k)=sum(classCounterDistance(classCounterDistance(:,2)==k,1));
          if(sumDistance2(k)==0)
             FitEmp2(k)=0;
          else
             FitEmp2(k)=total2/sumDistance2(k);
          end
       end
     %******************贪婪算法，比较当前和更新后位置的适应度，谁更优****************************
     [Employed FitEmp Bas]=GreedySelection(Employed,Employed2,FitEmp,FitEmp2,Bas,i);
      end;
      NormFit=FitEmp/sum(FitEmp);
      %926*******************end对邻域搜索的点进行重新分类，并计算适应度*****************
      
      
      %*******************全局*********************
        FitArrayCounterNumber=[FitEmp;1:size(ColonyTotal,1)/2]';
        maxFitArray=sortrows(FitArrayCounterNumber);
        Employed_Best=Employed(maxFitArray(size(maxFitArray,1),2),:);
        Employed_SecondBest=Employed(maxFitArray(size(maxFitArray,1)-1,2),:);

      
      %% Onlooker Bee
      Employed2=Employed;
      i=1;
      t=0;
      while(t<size(ColonyTotal,1)/2) 
        if(rand<NormFit(i))
         t=t+1;
         Param2Change=fix(rand*datacolumn)+1;
         neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于k
         neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于p
            while(neighbour==i||neighbour1==i||neighbour==neighbour1)
                neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;
                neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;
            end;
        %Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(i,Param2Change)-Employed(neighbour,Param2Change))*(rand-0.5)*2;
        Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(neighbour,Param2Change)-Employed(neighbour1,Param2Change))*(rand-0.5)*2+(Employed_Best(1,Param2Change)-Employed(i,Param2Change))*(rand-0.5)*2;
        % Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(i,Param2Change)-Employed(neighbour,Param2Change))*(rand-0.5)*2;
           if (Employed2(i,Param2Change)<ABCOpts.lb)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;
           if (Employed2(i,Param2Change)>ABCOpts.ub)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;  
     %***************得出新搜索到的位置，对数据集中所有元素进行一次新的所属类的分配
       center=Employed2;
       [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',center',datarow,centerNum);
     %*****************计算适应度*******************
       total2=0;
       sumDistance2=zeros(1,size(ColonyTotal,1)/2);
       FitEmp2=zeros(1,size(ColonyTotal,1)/2);
       for k=1:(size(ColonyTotal,1)/2)
           total2=length(find(classCounterDistance(:,2)==k));
           sumDistance2(k)=sum(classCounterDistance(classCounterDistance(:,2)==k,1));
          if(sumDistance2(k)==0)
             FitEmp2(k)=0;
          else
             FitEmp2(k)=total2/sumDistance2(k);
          end
       end;
     %******************贪婪算法，比较当前和更新后位置的适应度，谁更优****************************
     [Employed FitEmp Bas]=GreedySelection(Employed,Employed2,FitEmp,FitEmp2,Bas,i);%924之前一直写的是i,但是是错误的，因为这里的i已经在上面被for i=1:length(Colony)/2使用了，
        end;
        i=i+1;
        if (i==(size(ColonyTotal,1)/2)+1)  %如果超出范围，将i至1
         i=1;
        end;   
      end;
      
      %*******************全局*********************
        FitArrayCounterNumber=[FitEmp;1:size(ColonyTotal,1)/2]';
        maxFitArray=sortrows(FitArrayCounterNumber);
        Employed_Best=Employed(maxFitArray(size(maxFitArray,1),2),:);
        Employed_SecondBest=Employed(maxFitArray(size(maxFitArray,1)-1,2),:);
      
      
      %% Scout phase
        ind=find(Bas==max(Bas));%找到没有被更新次数最多的那个食物源Xi，并把次数和limit比较
        ind=ind(end);
        if (Bas(ind)>ABCOpts.Limit)
         Bas(ind)=0;
         neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于k
         neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;%对应于p
            while(neighbour==i||neighbour1==i||neighbour==neighbour1)
                neighbour=fix(rand*(size(ColonyTotal,1)/2))+1;
                neighbour1=fix(rand*(size(ColonyTotal,1)/2))+1;
            end;
        %Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(i,Param2Change)-Employed(neighbour,Param2Change))*(rand-0.5)*2;
        Employed2(i,Param2Change)=Employed(i,Param2Change)+(Employed(neighbour,Param2Change)-Employed(neighbour1,Param2Change))*(rand-0.5)*2+(Employed_Best(1,Param2Change)-Employed(i,Param2Change))*(rand-0.5)*2;
           % Employed2(ind,Param2Change)=Employed(ind,Param2Change)+(Employed(ind,Param2Change)-Employed(neighbour,Param2Change))*(rand-0.5)*2;

           if (Employed2(i,Param2Change)<ABCOpts.lb)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;
           if (Employed2(i,Param2Change)>ABCOpts.ub)
              Employed2(i,Param2Change)=Employed(i,Param2Change);
           end;
      
       %926*******************start对邻域搜索的点进行重新分类，并计算适应度*****************
       center=Employed2;
       centerNum=size(ColonyTotal,1)/2;%这里是4个，因为这里要算的是引领蜂的类从属关系，前面是比较是比较ColonyTotal的适应度大小
       [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',center',datarow,centerNum,sum1,kindNum);
       total2=0;
       sumDistance2=zeros(1,size(ColonyTotal,1)/2);
       FitEmp2=zeros(1,size(ColonyTotal,1)/2);
       for i=1:(size(ColonyTotal,1)/2)
           total2=length(find(classCounterDistance(:,2)==i));
           sumDistance2(i)=sum(classCounterDistance(classCounterDistance(:,2)==i,1));
          if(sumDistance2(i)==0)
             FitEmp2(i)=0;
          else
             FitEmp2(i)=total2/sumDistance2(i);
          end
       end
     %******************贪婪算法，比较当前和更新后位置的适应度，谁更优****************************
     [Employed FitEmp Bas]=GreedySelection(Employed,Employed2,FitEmp,FitEmp2,Bas);
      %926*******************end对邻域搜索的点进行重新分类，并计算适应度*****************
        end
      %%  k-means过程对邻域搜索到的点进行一次聚类，得出聚类中心
       %*********************使用k-means进行聚类，找出合适的新的聚类中心赋给Employed*************
       kindNum=linspace(0,0,size(ColonyTotal,1)/2);
       [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',Employed',datarow,centerNum,sum1,kindNum);
       %********928之前没有加上这一句，导致算的newCenter不是最终Employed对应的中心点，所以需要对筛选后的Emplo
       %yed进行一次中心点迭代计算，这样得到的数据更精确************
       step=10;
      while (sum(sum(newCenter'~=Employed)))&&step
        Employed=newCenter'; 
        times=10-step+1;
        sum1=zeros(datacolumn,centerNum);
        [newCenter,class,classCounterDistance]=calculateClassDistance(Colony',Employed',datarow,centerNum,sum1,kindNum);
        step=step-1;
      end
        Employed=newCenter';
        %Employed(isnan(Employed)==1)=999; 
       %% 更新FitEmp过程，没有这段代码，程序的运行情况也很好
        %********************928理论上这样更准确，因为在下一次循环中用到的FitEmp还是上面的式子算得的FitEmp
        %，这个并不准确，因为针对新的位置要重新计算其适应度，来作为下一次的FitEmp*********
        total=0;
       sumDistance=zeros(1,size(ColonyTotal,1)/2);
       FitEmp=zeros(1,size(ColonyTotal,1)/2);
       for k=1:(size(ColonyTotal,1)/2)
           total=length(find(classCounterDistance(:,2)==k));
           sumDistance(k)=sum(classCounterDistance(classCounterDistance(:,2)==k,1));
          if(sumDistance(k)==0)
             FitEmp(k)=0;
          else
             FitEmp(k)=total/sumDistance(k);
          end
       end
        
    
      fprintf('第%d次所产生的Employed新数组：\n',Cycle);
      disp(Employed);    
      disp('FitEmp的值为：');
      disp(FitEmp);
      FitEmpArray(Cycle)=sum(FitEmp);  
      Cycle=Cycle+1;  

      
    end;
    
    
    hold on;
    title('Iris、Balance-scale、Glass数据集适应度值变化趋势');
    xlabel('迭代次数（cycles）');
    ylabel('适应度（fitness）');%103
    if(iteration==1)
            semilogy(FitEmpArray,'k-');%928用于绘制FitEmp值在循环MaxCycles之后的变化趋势
    end;
    if(iteration==2)
        semilogy(FitEmpArray,'k:');
    end;
    if(iteration==3)
        semilogy(FitEmpArray,'k-.');
    end;
    legend('Iris','Balance-scale','Glass');
    
    
    %plot(FitEmpArray);
    
    
    
    %% 绘制结果图
% uniqueNumber=unique(class)';
%  m=1;
%  figure;
% for iuniquelength=1:4
%    
%     hold on;
%     if(mod(m,4)==1)
%     plot(Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),1),Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),2),'r*');
%     m=m+1;
%     continue;
%     end
%      if(mod(m,4)==2)
%     plot(Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),1),Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),2),'b+');
%     m=m+1;
%     continue;
%      end
%      if(mod(m,4)==3)
%     plot(Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),1),Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),2),'g>');
%     m=m+1;
%     continue;
%      end
%      if(mod(m,4)==0)
%     plot(Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),1),Colony(classCounterDistance(:,2)==uniqueNumber(iuniquelength),2),'kp');
%     m=m+1;
%     continue;
%      end
%      hold on;
%      grid;
%      break;
% end
   
iteration=iteration+1;


end;
toc
