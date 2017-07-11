%用来提取数据，每隔病人的数据保存在一个文件中，用ID号作为文件名。保存三个变量，诊断信息、病人基本信息、chartevents数据
%2017.5.12
%新增加了变量
%这里不对病人的病例进行筛选了，提取所有病人的就诊信息，后期再找合适的病人数据
%提取病人的限制条件： 
%病人基本信息里要包括：种族 体重
clear all;
conn = database('PostgreSQL30','postgres','19871115');
%先要找到我需要的病案号，还是以ICD=51881为例 
Pat_ID='select adm.hadm_id from mimiciii.admissions adm';
Pat_ID_curs=exec(conn,Pat_ID);
Pat_ID_curs=fetch(Pat_ID_curs);
data_ID=cell2mat(Pat_ID_curs.Data);
%save ('D:/ARDS/data1/Pat_ID.mat','data');
%开始遍历ID，查询所有病人，每个病人以ID号保存起来
%Pat_Para_Value_SQL只是保存了我需要的病人的参数信息，我还需要病人的基本信息，如年龄、性别、种族、ICU入院日期等等
%icd51881 包含年龄、性别
%pat_icu有病人icu的所有信息：subject_id、hadm_id、 first_careunit、 intime outtime
%deathtime age gender
%现在我只需要用icd51881 与pat_icu 进行联合查询就可以的到病人的基本信息
for i=1:length(data_ID)
    %获取诊断信息
    Pat_dig_SQL=['select * from mimiciii.diagnoses_icd where hadm_id=' num2str(data_ID(i,1))];  
    %获取体重信息
    Pat_w_SQL=['select round(avg(patientweight)) from mimiciii.inputevents_mv input where input.hadm_id=' num2str(data_ID(i,1))];
    %从视图中获取病人基本信息
    Pat_info_SQL=['select * from mimiciii.pat_icu where hadm_id=' num2str(data_ID(i,1))];    
    %获取病人的种族信息，race在chartevents中
    Pat_race_SQL=['select value from mimiciii.chartevents cha where cha.itemid=' num2str(226545) '  and cha.hadm_id=' num2str(data_ID(i,1)) ' limit 1' ];
    %参数提取
    %这里提取了720 呼吸机设置参数 在value中是一个字符串变量 要注意
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
    i
end
close(conn);
