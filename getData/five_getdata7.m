clear all;
load 'D:\mimicdata\10para\data7.mat'
PaO2=data_point_7(:,8);
FiO2=data_point_7(:,5);
SpO2=data_point_7(:,9);
MAP=data_point_7(:,10);
PF=PaO2./FiO2;
Log_PF=log10(PF);
SF=SpO2./FiO2;
Log_SF=log10(SF);
OI=((FiO2*100).*MAP)./PaO2;
OSI=((FiO2*100).*MAP)./SpO2;
data_point_7(:,21)=PF;
data_point_7(:,22)=SF;
data_point_7(:,23)=OI;
data_point_7(:,24)=OSI;
data_point_7(:,25)=Log_PF;
data_point_7(:,26)=Log_SF;

for i=1:length(data_point_7)
    filename = strcat('D:\mimicdata\matchdata_16\',num2str(data_point_7(i,20)),'.mat');
    load(filename)
    %27列 年龄
    class(cell2mat(data_info(9)))
    if cell2mat(data_info(9))>100
        data_point_7(i,27)=90;
    else
        data_point_7(i,27)=cell2mat(data_info(9));
    end
    %性别
    gender=cell2mat(data_info(5));
    switch gender
        case 'F'
            data_point_7(i,28)=1;
        case 'M'
            data_point_7(i,28)=0;
    end
     
end

index=1;
for i=1:length(data_point_7)
    if data_point_7(i,9)>=50  && data_point_7(i,3)>=5 && data_point_7(i,9)<=96
        data(index,:)=data_point_7(i,:);
        index=index+1;
    end
end
%%对数据进行随机化处理
% [length_data,~]=size(data);
% vector = randperm(length_data);
% random_data=zeros(size(data));
% for i=1:length_data
%    random_data(i,:)=data(vector(i),:);
% end
% data=random_data;
%%
% num100=0;num200=0;num300=0;
% for i=1:length(data)
%     if data(i,21)>300
%         
%         target_t(i,1)=1;%三分类使用
%         target_t_net(i,:)=[1 0 0];
%         target_t_300(i,:)=1;%PF=300二分类使用
%         target_t_200(i,:)=1;%PF=200二分类使用
%         num300=num300+1;
%         data300(num300,:)=data(i,:);
%     elseif data(i,21)<=300 && data(i,21)>200
%         
%         target_t(i,1)=2;
%         target_t_net(i,:)=[0 1 0];
%         target_t_300(i,:)=2;
%         target_t_200(i,:)=1;
%         num200=num200+1;
%         data200(num200,:)=data(i,:);
%     else
%         
%         target_t(i,1)=3;
%         target_t_net(i,:)=[0 0 1];
%         target_t_300(i,:)=2;
%         target_t_200(i,:)=2;
%         num100=num100+1;
%         data100(num100,:)=data(i,:);
%     end
% end
% t_data=[data300(1:409,:);data200(1:409,:);data100(1:409,:)];
% v_data=[data300(410:584,:);data200(410:584,:);data100(410:584,:)];
t_data=data(1:5864,:);
v_data=data(5865:end,:);

save('D:\mimicdata\method\line_fit\data_7\data7_limit_unbanlance.mat','v_data','t_data')
