//
//  Map_detail.h
//  地图模块
//
//  Created by kys-2 on 14-5-14.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WXAnation.h"
@interface Map_detail : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UIActionSheetDelegate>//
{
    MKMapView *mapViewMain;//设置地图
    MKUserLocation *UserLocation;//用户的地理位置
    //VPPMapHelper *_map_mh;//
    WXAnation *map_ann1;//大头针1
    WXAnation *map_annForUser;//大头针2
    CLLocationManager *map_locationManager;//定位管理器
    NSMutableArray *mapAnnotationsArr;//存放大头针
    NSString *locationStr;//定位后显示用户位置信息
    NSString *DistanceStr;//显示与学生的距离
    
}
@property (nonatomic,strong)NSString *S_UserName;//学生姓名
@property (nonatomic,strong)NSString *S_Number;//学生学号
@property (nonatomic,strong)NSString *map_longitude;//经度
@property (nonatomic,strong)NSString *map_latitude;//纬度
-(void)PutMkAnnSelected;//显示指定学生的位置
-(void)reLoacate;//定时器调用
-(void)MApTypeSegment;//选择地图类型
//点击方法
-(void)BtnPressedForMapDetail:(UIButton *)sender;
-(void)selected:(id)sender;
@end
