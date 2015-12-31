//
//  Map_detail.m
//  地图模块
//
//  Created by kys-2 on 14-5-14.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Map_detail.h"
#import "DXAlertView.h"
#import "Defines.h"
@interface Map_detail ()

@end

@implementation Map_detail
@synthesize map_latitude;
@synthesize map_longitude;
@synthesize S_Number,S_UserName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    NSLog(@"dsfdff===%@",S_UserName);
    mapAnnotationsArr =[NSMutableArray array];
    //地图初始化
	mapViewMain=[[MKMapView alloc] init];
    mapViewMain.frame=CGRectMake(0, 44,ScreenWidth , ScreenHeight-44);
    mapViewMain.showsUserLocation=YES;//定位
    mapViewMain.delegate=self;
    [self.view addSubview:mapViewMain];
    
    //定位按钮
    UIButton *LocateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    LocateBtn.frame=CGRectMake(0, 0, 30, 30);
    UIImage *image=[UIImage imageNamed:@"map_btn.png"];
    [LocateBtn setImage:image forState:UIControlStateNormal];
    LocateBtn.tag=100;
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithCustomView:LocateBtn];
    self.navigationItem.rightBarButtonItem=right;
    [LocateBtn addTarget:self action:@selector(BtnPressedForMapDetail:) forControlEvents:UIControlEventTouchDown];
      //返回按钮
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    back.tag=101;
    [back addTarget:self action:@selector(BtnPressedForMapDetail:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;

    //加载大头针
    [self PutMkAnnSelected];
    [self MApTypeSegment];//切换地图类型
    

}
-(void)MApTypeSegment
{
    NSArray *segmentArr=[NSArray arrayWithObjects:@"地图",@"卫星",@"混合", nil];
    UISegmentedControl *MapTypeSeg=[[UISegmentedControl alloc]initWithItems:segmentArr];
    MapTypeSeg.frame=CGRectMake(60, ScreenHeight-50, 200, 44);
    MapTypeSeg.momentary=NO;
    MapTypeSeg.selectedSegmentIndex=0;
    [MapTypeSeg addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:MapTypeSeg];
    
}
-(void)selected:(id)sender
{
    
    UISegmentedControl *control=(UISegmentedControl *)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            mapViewMain.mapType=MKMapTypeStandard;
        }
        break;
        case 1:
        {
            mapViewMain.mapType=MKMapTypeSatellite;
        }
        break;
           case 2:
        {
            mapViewMain.mapType=MKMapTypeHybrid;
        }
            break;
        default:
            break;
    }
    
}

-(void)PutMkAnnSelected
{//添加指定位置上得大头针
    CLLocationCoordinate2D coordinateSelected;
    coordinateSelected.latitude=[map_latitude doubleValue];//学生的纬度
    coordinateSelected.longitude=[map_longitude doubleValue];
    map_ann1 = [[WXAnation alloc] initWithCoordinate2D:coordinateSelected];
    map_ann1.title =S_UserName ;
    map_ann1.subtitle = S_Number;
    //设置一下显示范围
    MKCoordinateSpan span = {1,1};
    MKCoordinateRegion region = {coordinateSelected,span};
    [mapViewMain setRegion:region animated:YES];
    
    [mapAnnotationsArr addObject:map_ann1];
    [mapViewMain addAnnotations:mapAnnotationsArr];//这里需要修改
}
#pragma mark - MKAnnotationView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"Annotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        //设置是否显示标题视图
        annotationView.canShowCallout = YES;
        
    }

      return annotationView;

}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // Initialize each view
    for (MKPinAnnotationView *mkaview in views)
    {
        // 当前位置 的大头针设为紫色，并且没有右边的附属按钮
        if ([mkaview.annotation.title isEqualToString:@"我的位置:"])
        {
            // 其他位置的大头针设为红色，右边添加附属按钮
            mkaview.pinColor = MKPinAnnotationColorGreen;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            button.tag=103;
            [button addTarget:self action:@selector(BtnPressedForMapDetail:) forControlEvents:UIControlEventTouchUpInside];
            mkaview.rightCalloutAccessoryView = button;
            mkaview.leftCalloutAccessoryView=nil;
            
            
        }
        else
        {
        
            mkaview.pinColor = MKPinAnnotationColorPurple;
            //rughtView
            UIButton *rightbtn=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightbtn.tag=102;
            [rightbtn addTarget:self action:@selector(BtnPressedForMapDetail:) forControlEvents:UIControlEventTouchUpInside];
            mkaview.rightCalloutAccessoryView = nil;
            mkaview.leftCalloutAccessoryView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_person"]];

        }
    }
}
#pragma mark 按钮点击事件
-(void)BtnPressedForMapDetail:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {//定位
            if ([CLLocationManager locationServicesEnabled])
            { // 检查定位服务是否可用
                map_locationManager = [[CLLocationManager alloc] init];
                map_locationManager.delegate = self;
                map_locationManager.distanceFilter=0.5;
                map_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                [map_locationManager startUpdatingLocation]; // 开始定位
            }
            mapViewMain.showsUserLocation=YES;
            //添加定时器
            for (int i=0; i<4; i++)
            {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(reLoacate) userInfo:nil repeats:NO];
            }
        }
            break;
        case 101:
        {//返回按钮的方法
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            case 102:
        {//查看学生的详细信息
//            UIActionSheet *InfoChoice=[[UIActionSheet alloc]initWithTitle:@"查看学生消息" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的录音",@"现场实拍",@"情况描述",@"位置信息", nil];
//            InfoChoice.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
//            [InfoChoice showInView:self.view];
        }
            break;
            case 103:
        {//点击显示用户和学生之间的距离
            DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"小提示" contentText:DistanceStr leftButtonTitle:nil rightButtonTitle:@"好"];
            [alert show];

        }
            break;
        default:
            break;
    }
}
#pragma mark --ActionSheetDelegate
/*-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {//录音
            [self showAlert:@"我的录音" withTitle:@"tips"];
            
        }
            break;
            case 1:
        {//照片
            [self showAlert:@"现场实拍" withTitle:@"tips"];
        }
            break;
            case 2:
        {//现场描述
            [self showAlert:@"由于火车晚点，我可能不能及时到校，请辅导员老师帮我请半天假。" withTitle:@"现场描述"];
            
        }
            break;
            case 3:
        {//位置信息
            [self showAlert:@"河北省张家口市桥东区钻石南路11号" withTitle:@"位置信息"];
        }
            break;
        default:
            break;
    }
}
-(void)showAlert:(NSString*)info withTitle:(NSString *)title
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:info delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];

}*/
-(void)reLoacate
{
    if ([CLLocationManager locationServicesEnabled])
    { // 检查定位服务是否可用
        map_locationManager = [[CLLocationManager alloc] init];
        map_locationManager.delegate = self;
        map_locationManager.distanceFilter=0.5;
        map_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [map_locationManager startUpdatingLocation]; // 开始定位
    }
    mapViewMain.showsUserLocation=YES;
}
#pragma mark  定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self SetMapPoint:newLocation.coordinate];//定位后缩进距离
    //地理信息反解码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
     {
         if (placemarks.count >0   )
         {
             CLPlacemark * plmark = [placemarks objectAtIndex:0];
             //NSString * country = plmark.country;
            // NSString * plmark1    = plmark.subLocality;
             //NSString * city1   = plmark.administrativeArea;
             
             NSLog(@"%@",plmark.name);
             locationStr=[NSString stringWithFormat:@"%@",plmark.name];
         }
     }];
    
    //添加定位后的大头针
    UserLocation=mapViewMain.userLocation;//获得权限
    map_annForUser=[[WXAnation alloc]initWithCoordinate2D:UserLocation.coordinate];
    map_annForUser.title=@"我的位置:";
    map_annForUser.subtitle=locationStr;
    [mapAnnotationsArr addObject:map_annForUser];
    [mapViewMain addAnnotations:mapAnnotationsArr];
    /*MKUserLocation *ann=[[MKUserLocation alloc]init];
    ann.title=@"我的位置：";
    ann.subtitle=locationStr;
    [mapAnnotationsArr addObject:ann];
    [mapViewMain addAnnotations:mapAnnotationsArr];*/
    
    
    
    if (newLocation.horizontalAccuracy>=0)
    {
        CLLocation *Stud=[[CLLocation alloc]initWithLatitude:[map_latitude doubleValue]longitude:[map_longitude doubleValue]];
        CLLocationDistance delta=[newLocation distanceFromLocation:Stud];
        if (delta>=1000) {
            DistanceStr=[NSString stringWithFormat:@"距离该学生\n约为%f千米",delta/1000];
            NSLog(@"distance==%f千米",delta/1000);
        }else
        {
            NSLog(@"距离===%f米",delta);
            DistanceStr=[NSString stringWithFormat:@"距离该学生约为%f米",delta];

            
        }
    }


}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"定位错误==%@",[error description]);
    if ([error description])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"定位失败\n请检查网络重新操作" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation
{//定位后缩进距离
    MKCoordinateSpan span = {0.1,0.1};
    MKCoordinateRegion region = {myLocation,span};
    [mapViewMain setRegion:region animated:YES];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
