%%
%File Name:getdata_5_12.m
%Author:杨鹏程
%Version:v1.1
%Data:2017.05.12
%DESCRIPTION:
%           按照admissions.hadm_id字段从数据库中提取病的信息并保存在mimicdata\allpatientsdata\hadm_id.mat文件中
%           每个文件中保存一下变量：
%           data_info:病人基本信息，是从数据库pat_icu视图中获取的，具体包括的信息可参见pat_icu视图，在此不一一列举；
%           data_dig:来自diagnoses_icd表，病人的全部诊断信息，每个病人有多个诊断信息。
%           data_Value:提取的病人的具体参数信息。联合chartevents、para_updata（此表中存储了我们在本次是验证所关心的itemid，当然这些itemid都是反复核对的）、icustays（用于保证所有参数都是在进入ICU记录的）三个表。
%               包括字段：subject_id、hadm_id、itemid、value、valuenum、valueuom、para_flag、charttime
%           data_w：病人体重信息
%           data_race：种族信息
%           通过次方法，整理了55796份病例数据。
%%
%连接数据库
clear all;
conn = database('PostgreSQL30','postgres','19871115');
Pat_ID='select adm.hadm_id from mimiciii.admissions adm';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
%%
%执行SQL语句
for i=1:length(data_ID)
    %获取诊断信息
    Pat_dig_SQL=['select * from mimiciii.diagnoses_icd where hadm_id=' num2str(data_ID(i,1))];  
    %获取体重信息
    Pat_w_SQL=['select round(avg(patientweight)) from mimiciii.inputevents_mv input where input.hadm_id=' num2str(data_ID(i,1))];
    %从视图中获取病人基本信息
    Pat_info_SQL=['select * from mimiciii.pat_icu where hadm_id=' num2str(data_ID(i,1))];    
    %获取病人的种族信息，race在chartevents中
    Pat_race_SQL=['select value from mimiciii.chartevents cha where cha.itemid=' num2str(226545) '  and cha.hadm_id=' num2str(data_ID(i,1)) ' limit 1' ];
    %参数提取，这里提取了720 呼吸机设置参数 在value中是一个字符串变量 要注意
    Pat_Para_Value_SQL =[ 'select distinct cha.subject_id,cha.hadm_id,cha.itemid,cha.value,cha.valuenum,cha.valueuom,para_id.para_flag,cha.charttime'...
        ' from mimiciii.chartevents cha'...
        ' inner join mimiciii.para_update para_id'...
        ' on cha.itemid=para_id.para_code'...
        ' inner join mimiciii.icustays icu'...
        ' on icu.hadm_id=cha.hadm_id'...
        ' where cha.hadm_id=' num2str(data_ID(i,1)) ' and cha.itemid in (select para_code from mimiciii.para_update )'...
        ' and cha.itemid=para_id.para_code '...
        ' and cha.charttime>icu.intime'...
        ' and cha.charttime<icu.outtime'...
        ' order by para_id.para_flag,cha.charttime ;'];
    %执行pat_dig_sql
    Pat_dig_value=exec(conn,Pat_dig_SQL);
    Pat_dig_value=fetch(Pat_dig_value);
    data_dig=Pat_dig_value.Data;
    %执行Pat_w_SQL
    Pat_w_value=exec(conn,Pat_w_SQL);
    Pat_w_value=fetch(Pat_w_value);
    data_w=Pat_w_value.Data;
    %执行pat_info_sql
    Pat_info_value=exec(conn,Pat_info_SQL);
    Pat_info_value=fetch(Pat_info_value);
    data_info=Pat_info_value.Data;
    data_info=data_info';
    %执行Pat_race_SQL
    Pat_race_value=exec(conn,Pat_race_SQL);
    Pat_race_value=fetch(Pat_race_value);
    data_race=Pat_race_value.Data;
    %执行pat_ipara_value_sql
    Pat_Values = exec(conn,Pat_Para_Value_SQL);
    Pat_Values = fetch(Pat_Values);
    data_Values=Pat_Values.Data;
    if length(data_Values)>1 && length(data_info)>1 && length(data_dig)>1
    filename=strcat('D:/mimicdata/allpatientsdata/',num2str(data_ID(i,1)),'.mat');
    save (filename,'data_info','data_dig','data_Values','data_w','data_race');
    end
end
close(conn);
