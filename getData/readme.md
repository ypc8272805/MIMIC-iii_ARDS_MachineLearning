# 获取数据
## 1、获取数据的访问权限，并获取数据
  具体可以访问以下网站：
    https://mimic.physionet.org/
    https://github.com/MIT-LCP/mimic-code/
  可以在以上两个网站中获得mimic-iiii的相关信息
## 2、在本地构建数据库，方便数据的提取
  mimic网站提供了在window平台创建数据库的具体方法，如果感兴趣可以按照以下网站尝试操作一下，当然，在本地构建数据库相比直接访问csv文件要便利的多。
  https://mimic.physionet.org/tutorials/install-mimic-locally-windows/
## 3、从数据库获取项目所需要的信息
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
  ### 3.2 
