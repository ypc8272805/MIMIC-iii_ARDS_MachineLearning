%%
%File Name:match_data_5_12.m
%Author:杨鹏程
%Version:v1.1
%Data:2017.05.12
%DESCRIPTION:
%           对提取的数据进行匹配
%           由于所有病人的临床数据都存储在chartevents中，而我们的实验需要知道当病人记录PaO2时其他的相关参数，所以就要以PaO2记录时间为准寻找此病人此时的所有相关数据，数据获取时，
%           我们将病人数据按照hadm_id单独存储。在匹配前，我们要对数据进行第一次筛选，按照诊断信息来筛选我们需要的病人。由于病人的所有诊断信息保存在diagnoses_icd中，且我们想要的
%           诊断id在icdall中，联合查询，获取我们需要的病人的hadm_id。最终获取了8262份病历（以hadm_id为准）
%           匹配好的结果按照hadm_id存储在mimicdata\matchdata\
%           每隔文件保存end_data、data_info、data_race、data_w、data_dig
%           end_data：为最终匹配的数据，n*19的矩阵，第一列为进入icu时间，其他依次为
%           data_info：来自于上一步的病人基本信息
%           data_race：种族
%           data_w：病人体重
%           data_dig：诊断信息
%%
%获取相关疾病患者的hadm_id
clear all;
conn = database('PostgreSQL30','postgres','19871115');
Pat_ID='select icd.hadm_id from mimiciii.diagnoses_icd icd where icd.icd9_code in (select mimiciii.icdall.icd9_code from mimiciii.icdall) group by icd.hadm_id';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
close(conn);
%%
%对相关数据做预处理
for file_num=1:length(data_ID)
    end_data=[];
    filename=strcat('D:\mimicdata\allpatientsdata\',num2str(data_ID(file_num,1)),'.mat');
    if exist(filename, 'file')>0
        data=matfile(filename);
        data_info=data.data_info;
        data_race=data.data_race;data_w=data.data_w;data_dig=data.data_dig;
        data_chart=data.data_Values;
        [data_chart_length,~]=size(data_chart);
        %对时间进行处理
        data_chart(:,9)=num2cell(datenum(data_chart(:,8))-min(datenum(data_chart(:,8))));
        %先处理体温数据,将itemid=223761的华氏度转换为摄氏度
        Temp_index=find(cell2mat(data_chart(:,3))==223761);
        [length_temp,~]=size(Temp_index);
        if length_temp>0
            for i=1:length_temp
                data_chart(Temp_index(i,1),5)=num2cell((cell2mat(data_chart(Temp_index(i,1),5))-32)/1.8);
            end
        end
        %对FiO2的单位进行调整，3420、223835都除以100
        for i=1:data_chart_length
            if cell2mat(data_chart(i,3))==3420 || cell2mat(data_chart(i,3))==223835
                data_chart(i,5)=num2cell(cell2mat(data_chart(i,5))/100);
            end
        end
        %处理格拉斯昏迷指数
        GSC_index=find(cell2mat(data_chart(:,7))>=19);
        [length_GSC,~]=size(GSC_index);
        if length_GSC>3
            GSC_temp=zeros(length_GSC,3);
            GSC_temp(:,1)=cell2mat(data_chart(GSC_index(1,1):end,9));
            GSC_temp(:,2)=cell2mat(data_chart(GSC_index(1,1):end,7));
            GSC_temp(:,3)=cell2mat(data_chart(GSC_index(1,1):end,5));
            data_GSC_group=zeros(length(unique(GSC_temp(:,1))),5);
            data_GSC_group(:,1)=unique(GSC_temp(:,1));
            for j=1:length_GSC
                time_index=find(data_GSC_group(:,1)==GSC_temp(j,1));
                data_GSC_group(time_index,GSC_temp(j,2)-17)=GSC_temp(j,3);
            end
            [zeros_x,~]=find(data_GSC_group(:,[2 3 4])==0);
            data_GSC_group(unique(zeros_x),:)=[];
            data_GSC_group(:,5)=data_GSC_group(:,2)+data_GSC_group(:,3)+data_GSC_group(:,4);
            data_chart(GSC_index(1,1):end,:)=[];
            [length_temp_GSC,~]=size(data_GSC_group);
            data_GSC_temp=zeros(length_temp_GSC,9);
            data_GSC_temp(:,9)=data_GSC_group(:,1);
            data_GSC_temp(:,5)=data_GSC_group(:,5);
            data_GSC_temp(:,7)=18;
            data_chart=[data_chart;num2cell(data_GSC_temp)];
        end
        %对呼吸机模式进行转换
        v_mode=find(cell2mat(data_chart(:,7))==1);
        [v_mode_length,~]=size(v_mode);
        mode={'Assist Control','SIMV+PS','SIMV', 'CMV', 'Pressure Control', 'Pressure Support' ,'Other/Remarks', 'CPAP', 'CPAP+PS', 'TCPCV'};
        for v_mode_index=1:v_mode_length
            [~,b]=ismember(data_chart(v_mode_index,4),mode);
            data_chart(v_mode_index,5)=num2cell(b);
        end
%%
        %对数据进行分组
        data_chart_temp=[cell2mat(data_chart(:,9)),cell2mat(data_chart(:,7)),cell2mat(data_chart(:,5))];
        data_chart_temp(:,2)=data_chart_temp(:,2)+1;
        [length_data_chart,~]=size(data_chart_temp);
        data_group=zeros(length(unique(data_chart_temp(:,1))),19);
        data_group(:,1)=unique(data_chart_temp(:,1));
        for k=1:length_data_chart
            if ~isnan(data_chart_temp(k,3))
                time_index=find(data_group(:,1)==data_chart_temp(k,1));
                data_group(time_index,data_chart_temp(k,2))=data_chart_temp(k,3);
            end
        end
%%
        %开始匹配
        if sum(data_group(:,8))~=0%判断是否有PaO2数据
            %对临时变量进行更新，注意temp中和data_group错了一位
            temp_1(1,1:18)=data_group(1,1);
            temp_1(2,1:18)=data_group(1,2:19);%临时变量，首先保存第一个点
            data_num=1;%实际匹配的点数
            [data_group_y,~]=size(data_group);%获取data_group的长度
            for k=2:data_group_y
                %对临时变量进行更新，注意temp中和data_group错了一位
                updata_index=find(data_group(k,2:19)>0);%向下开始遍历，找到下一列不为0的值，用来更新temp_1,让其实可存储最新的值
                for m=1:length(updata_index)
                    temp_1(1,updata_index(1,m))=data_group(k,1);
                    temp_1(2,updata_index(1,m))=data_group(k,updata_index(m)+1);
                end
                %遇到PaO2，也就是data_group的第5列有大于0的值
                if data_group(k,8)>0 && k<data_group_y
                    para=k+1;%从pao2下一行开始找
                    for n=1:11
                        while data_group(para,n+8)==0 && para<data_group_y
                            para=para+1;%没找到行号就加1
                        end
                        temp_2(1,n)=data_group(para,1);
                        temp_2(2,n)=data_group(para,n+8);
                        para=k+1;%把行号重置开始找下一个变量
                    end
                    %temp_1和temp_2作比较
                    %如果tepm_1中有0 说明没有保存，这时候就直接替换temp_2中的数据
                    temp_3=temp_1;
                    for down_index=1:11
                        if temp_3(1,down_index+7)==0
                            temp_3(1,down_index+7)=temp_2(1,down_index);
                            temp_3(2,down_index+7)=temp_2(2,down_index);
                        else
                            if abs(temp_3(1,down_index+7)-temp_3(1,7))>abs(temp_2(1,down_index)-temp_3(1,7))
                                temp_3(1,down_index+7)=temp_2(1,down_index);
                                temp_3(2,down_index+7)=temp_2(2,down_index);
                            end
                        end
                    end
                    %temp_3保存了比较好的数据，现在对数据的时间进行判断
                    for time_index=1:18
                        if time_index<=6
                            if abs(temp_3(1,time_index)-temp_3(1,7))>0.0417*24 && temp_3(2,time_index)~=0
                                temp_3(1,time_index)=0;
                                temp_3(2,time_index)=0;
                            end
                        else
                            if abs(temp_3(1,7)-temp_3(1,time_index))>0.0417
                                temp_3(1,time_index)=0;
                                temp_3(2,time_index)=0;
                            end
                        end
                    end
                    end_data(data_num,1)=temp_3(1,7);
                    end_data(data_num,2:19)=temp_3(2,:);
                    data_num=data_num+1;
                    temp_3=[];temp_2=[];
                end
            end
            if ~isempty(end_data)
                filename=strcat('D:\mimicdata\matchdata\',num2str(data_ID(file_num,1)),'.mat');
                save (filename,'end_data','data_info','data_race','data_w','data_dig');
                end_data=[];
            end
        end
    end
    %要清除一些局部变量，否则会在下次运算中出错
    clear  data_chart data_group data_num down_index end_data filename i j k Lia m match_table n num para Para para_index temp_1 temp_2 temp_3 time_index updata_index data_chart_y  data_group_y data_chart_length data_chart_temp GSC_index length_data_chart length_GSC length_temp Temp_index;
end