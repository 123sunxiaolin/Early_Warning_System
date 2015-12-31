//
//  Defines.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-25.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#ifndef ___________Defines_h
#define ___________Defines_h

/********界面参数*/
#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define CommonColor [UIColor colorWithRed:11/255.0 green:90/255.0 blue:172/255.0 alpha:1.0]
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//网络IP
#define IP @"http://sc1.hebeinu.edu.cn"
//#define IP @"http://211.82.193.89:8080"
//http://sc1.hebeinu.edu.cn/school5/index.html
/********登录界面*/
#define URL_Login @"/school5/loginCheck.html"
/********注册界面*/
#define REGISTER @"/school5/requestCollGra.html"//获得学院
#define REGISTER2 @"/school5/requestProfession.html"//获得专业
#define REGISTER3 @"/school5/requestClass.html"//获得班级

#define STUDENTURL @"/school5/registerStudent.html"//学生注册
//辅导员
#define ASSISTANTfirst @"/school5/requestCollege.html"//获得学院
#define ASSISTANTsecond @"/school5/requestGrade.html"//获得年级
#define ASSISTANTMain @"/school5/registerHeadteacher.html"//辅导员提交
//普通教师
#define TEACHER @"/school5/registerTeacher.html"//教师提交

/*********语音助手*/
#define URL_NEWS @"/school5/newsSearch/client.html"

#define APPID @"531ff655"
#define Margin  5
#define kMaxRadius 160

/*********新闻模块*/
#define NEWS @"/school5/newsList/client.html"


/*********紧急情况模块*/
//Students
#define URL_Student @"/school5/emerStudent.html"//students

//Leaders
#define URLLeader @"/school5/emerGetLeader.html"//Leaders one
#define URLGetCollegeByLeaders @"/school5/requestCollege.html"//Leaders two   获得学院
#define URLGetHeaderTeachersBycollege @"/school5/emerGetHeadTeacherByCollegeName.html"//Leaders two   获得辅导员信息根据学院


#define URLGetGradeOrCollegeInLeaders @"/school5/requestCollGra.html"//获取学院和年级的信息在领导的身份中
#define URLGetProfessons @"/school5/requestProfession.html"//获得专业信息
#define URLGetClasses @"/school5/requestClass.html"
//获得班级信息

#define URLGetClassemates @"/school5/emerStudentAndTeacher.html"//提交班级信息获得班级的联系人

//headteachers
#define URLGetLeadersAndHeaders @"/school5/getHeadteacherLeader.html"//以辅导员身份登录获取领导和辅导员联系方式
#define URLGetClassesManagedByHeadteacher @"/school5/getGPC.html"//以辅导员身份登录获取辅导员所管辖的班级
#define URLGetClassByGradeId @"/school5/emerStudentAndTeacher.html"//以辅导员身份登录获取班级名单根据GradeId


/*********考勤模块*/

#define URLGetGradeAndColleges_CAO @"/school5/requestCollGra.html"//获取学院和年级的信息在领导的身份中
#define URLGetProfessons_CAO @"/school5/requestProfession.html"//获得专业信息
#define URLGetClasses_CAO @"/school5/requestClass.html"
#define URLSubmitClasses_CAO @"/school5/saveOutcome.html"
#define URLupdateStudentOut @"/school5/updateStudentOutcome.html"
//获得班级信息
#define URLGetLessons_CAO @"/school5/getClassName.html"
//获得班级课程信息
#define URLSubmitData_CAO @"/school5/checkStuCallOver.html"
//提交信息获得班级的人名单
#define URLForCheck_CAO @"/school5/checkOutcome.html"//查询

//快速查询
#define CaoQinUrlLeader @"/school5/checkOutcomeByCollegeName.html"//领导端

#define CaoQin_HeadTeacher @"/school5/checkOutcomeByGradeID.html"//辅导员端

#define CaoQin_DetailURl @"/school5/getStudentInformation.html"

/*********地图中心*/
#define Map_URLGetClassesManagedByHeadteacher @"/school5/mapOutNumber.html"//辅导员在地图模块获得所管辖的班级
#define Map_URLForStudentInfomations @"/school5/getLongLatByGrade.html"

/*********个人中心*/
//辅导员
#define  infoCenterCheck_headTeacher_Url @"/school5/headteacherShow.html"//个人信息查看
#define  infoCenterChange_headTeacher_Url @"/school5/headTeacherChange.html"
//学生
#define  infoCenterCheck_Student_Url @"/school5/studentShow.html"//个人信息查看
#define  infoCenterChange_Student_Url @"/school5/studentChange.html"
#define  infoCenterheadSculpture_Student_Url  @"/school5/uploadHeadSculpture.html"
//普通教师
#define  infoCenterCheck_Teacher_Url @"/school5/teacherShow.html"
#define  infoCenterChange_Teacher_Url @"/school5/teacherChange.html"
//领导
#define  infoCenterCheck_Leader_Url @"/school5/leaderShow.html"
#define  infoCenterChange_Leader_Url @"/school5/leaderChange.html"


//网络请求
#define Request_TimeOut @"网络请求超时，请重新连接网络"
#endif
