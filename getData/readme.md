# 获取数据
## 1.获取数据的访问权限，并获取数据
  具体可以访问以下网站:
    https://mimic.physionet.org/
    https://github.com/MIT-LCP/mimic-code/
  可以在以上两个网站中获得mimic-iiii的相关信息
## 2.在本地构建数据库，方便数据的提取
  mimic网站提供了在window平台创建数据库的具体方法，如果感兴趣可以按照以下网站尝试操作一下，当然，在本地构建数据库相比直接访问csv文件要便利的多。
  https://mimic.physionet.org/tutorials/install-mimic-locally-windows/
## 3.从数据库获取项目所需要的信息
  ### 3.1 获取相关疾病病人的病例号
    本项目只需要提取ARDS患者相关病例号，根据ARDS的相关定义，在d_icd_diagnoses.long_title中人工去寻找ARDS相关的疾病，最终我们确定了以下的相关疾病：
    
    icd9_code       short_title                     long_title
    "5184";"Acute lung edema NOS";"Acute edema of lung, unspecified"
    "51851";"Ac resp flr fol trma/srg";"Acute respiratory failure following trauma and surgery"
    "5187";"Transfsn rel ac lung inj";"Transfusion related acute lung injury (TRALI)"
    "51881";"Acute respiratry failure";"Acute respiratory failure"
    "86121";"Lung contusion-closed";"Contusion of lung without mention of open wound into thorax"
    "86130";"Lung injury NOS-open";"Unspecified injury of lung with open wound into thorax"
    "86131";"Lung contusion-open";"Contusion of lung with open wound into thorax"
    "86132";"Lung laceration-open";"Laceration of lung with open wound into thorax"
    
    其实在数据库中寻找可能急性发作ARDS的患者的过程中，也存在很多问题，以上几种疾病也不能全部包括我们想要的所有病人，如果有好的建议希望大家可以交流。
### 3.2 提取 相关的无创参数用于辨识ARDS
  这一部分需要做大量的文献调研工作，来确定哪一些无创参数与ARDS有相关性，当然为了后续实验的方便，在一开始可以尽量选择尽可能多的参数，这样后续只需要选择自己需要的就可以了，具体提取的参数可以参见文件： getData/参数汇总.xlsx
  此文件有详细的内容，下面讲一下如何阅读这张表：
  我将我需要的参数分成了以下几类：
  病人基本信息
  呼吸机设置参数
  监护仪测量参数
  呼吸机测量参数
  血气分析参数
  
  在具体从数据库查询的过程中，又分成两类：
  #### 第一类是参数下有具体itemid的，也就是有数字的
  这一部分变量在数据库中全部存储在chartevents表中，一个参数对应多个itemid是由于mimic数据的原因，由于各个医院或者是整理数据库的工作人员，不一定能够很好地区分大小写或者每种生理参数缩写与全称的区别，造成了一个生理参数会有多个itemid，所以这个提醒大家，在以后的工作中，你要是想要提取摸一个变量，一定要仔细筛查，关于参数汇总这个表中的所有参数，都是人工找的，找到后又通过仔细分析来排除异常itemid的。
  #### 第二类参数就是提供的是表名的而不是itemid，这一类参数在提取具体数值的时候下去访问我写的具体的表去查找
  注：关于参数汇总.xlsx
  绿色：提示大家要注意单位转换，同一个参数对应多个itemid，每隔itemid对应的真实数据的单位不是统一的，这个要在处理的过程中转换单位
  黄色：由于格拉斯哥昏迷指数（GCS）由三部分组成，在mimic数据库中，198对应的是将三部分加起来的值，而220739--E 223900--V 223901--M，要将这三个值相加才是一个GCS值。
 
	

