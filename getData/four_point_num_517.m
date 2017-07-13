%%
%File Name:point_num_517.m
%Author:杨鹏程
%Version:v1.1
%Data:2017.05.17
%DESCRIPTION:
%           由于之前数据都存储在单个文件中，不方便分析，现在要将数据汇总在一起
%           后续试验中我们使用到了dataGSC.mat、data7.mat两个数据文件，这两个数据文件的区别就在于
%           共同拥有的参数不同，dataGSC条件更多一些，自然数据就少一些，
%           dataGSC.mat 2576个病例，15939数据点
%           PEEP SET ,FiO2,PaO2,SpO2,MAP,TV o,RR o,TEMP,HR,GCS
%           data7.mat 2996 26657
%           FiO2,PaO2,SpO2,MAP,RR o,HR,GCS
clear all;
conn = database('PostgreSQL30','postgres','19871115');
Pat_ID='select icd.hadm_id from mimiciii.diagnoses_icd icd where icd.icd9_code in (select mimiciii.icdall.icd9_code from mimiciii.icdall) group by icd.hadm_id';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
close(conn);
point_nums=1;point_nums_1=1;point_nums_GSC=1;point_nums_3y=1;point_nums_7=1;
for file_num=1:length(data_ID)
    filename=strcat('D:\mimicdata\matchdata_16\',num2str(data_ID(file_num,1)),'.mat');
    if exist(filename, 'file')>0
        data=matfile(filename);
        end_data=data.end_data;
        [length_end_data,~]=size(end_data);
        for i=1:length_end_data
            if end_data(i,3)~=0 && (end_data(i,5)~=0 || end_data(i,7)~=0) && end_data(i,8)~=0 && end_data(i,9)~=0 && end_data(i,10)~=0 && end_data(i,11)~=0 && end_data(i,12)~=0 && end_data(i,13)~=0 && end_data(i,14)~=0 
                data_point(point_nums,1:19)=end_data(i,:);data_point(point_nums,20)=data_ID(file_num,1);
                point_nums=point_nums+1;
            end
            if end_data(i,3)~=0 && end_data(i,5)~=0  && end_data(i,8)~=0 && end_data(i,9)~=0 && end_data(i,10)~=0 && end_data(i,11)~=0 && end_data(i,12)~=0 && end_data(i,13)~=0 && end_data(i,14)~=0 
                data_point_A(point_nums_1,1:19)=end_data(i,:);data_point_A(point_nums_1,20)=data_ID(file_num,1);
                point_nums_1=point_nums_1+1;
            end
            if end_data(i,3)~=0 && end_data(i,5)~=0  && end_data(i,8)~=0 && end_data(i,9)~=0 && end_data(i,10)~=0 && end_data(i,11)~=0 && end_data(i,12)~=0 && end_data(i,13)~=0 && end_data(i,14)~=0 && end_data(i,19)~=0
                data_point_GSC(point_nums_GSC,1:19)=end_data(i,:);data_point_GSC(point_nums_GSC,20)=data_ID(file_num,1);
                point_nums_GSC=point_nums_GSC+1;
            end
            if end_data(i,3)~=0 && end_data(i,5)~=0  && end_data(i,8)~=0 && end_data(i,9)~=0 && end_data(i,10)~=0 && end_data(i,11)~=0 && end_data(i,12)~=0 && end_data(i,13)~=0 && end_data(i,14)~=0 && end_data(i,19)~=0 && end_data(i,17)~=0
                data_point_3y(point_nums_3y,1:19)=end_data(i,:);data_point_3y(point_nums_3y,20)=data_ID(file_num,1);
                point_nums_3y=point_nums_3y+1;
            end
            if end_data(i,5)~=0  && end_data(i,8)~=0 && end_data(i,9)~=0 && end_data(i,10)~=0  && end_data(i,12)~=0  && end_data(i,14)~=0 && end_data(i,19)~=0
                data_point_7(point_nums_7,1:19)=end_data(i,:);data_point_7(point_nums_7,20)=data_ID(file_num,1);
                point_nums_7=point_nums_7+1;
            end
        end
    end
end
patient_id=unique(data_point(:,20));
save('D:/mimicdata/10para/data.mat','patient_id','data_point')
patient_id_A=unique(data_point_A(:,20));
save('D:/mimicdata/10para/data1.mat','patient_id_A','data_point_A')
patient_id_GSC=unique(data_point_GSC(:,20));
save('D:/mimicdata/10para/dataGSC.mat','patient_id_GSC','data_point_GSC')
patient_id_3y=unique(data_point_3y(:,20));
save('D:/mimicdata/10para/data3y.mat','patient_id_3y','data_point_3y')
patient_id_7=unique(data_point_7(:,20));
save('D:/mimicdata/10para/data7.mat','patient_id_7','data_point_7')