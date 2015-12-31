//
//  myViewController.m
//  map
//
//  Created by zhaicongcong on 4/17/14.
//  Copyright (c) 2014 zhaicongcong. All rights reserved.
//

#import "myViewController.h"
#import "MapAnnotationExample.h"
#import "AHReach.h"
@interface myViewController (){
    MKMapView *m_map;
    MKUserLocation *map_user;
     VPPMapHelper *map_mh;
    NSString *string;
    NSTimer *map_timer;
}
@property(nonatomic, strong)  UITextField *addressField;
@property(nonatomic, strong) NSArray *reaches;
@end

@implementation myViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *SendInfo=[UIButton buttonWithType:UIButtonTypeCustom];
    SendInfo.frame=CGRectMake(0, 20, 40, 30);
    SendInfo.backgroundColor=[UIColor clearColor];
    [SendInfo addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [SendInfo setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [SendInfo setTitle:@"发送" forState:UIControlStateNormal];
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithCustomView:SendInfo];
    self.navigationItem.rightBarButtonItem=right;

    UIButton *locateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    locateBtn.frame=CGRectMake(0, 5, 20,20);
    locateBtn.backgroundColor=[UIColor clearColor];
    [locateBtn addTarget:self action:@selector(dingwei:) forControlEvents:UIControlEventTouchUpInside];
    [locateBtn setImage:[UIImage imageNamed:@"locate_btn.png"] forState:UIControlStateNormal];
    [locateBtn setImage:[UIImage imageNamed:@"locate_btn_hinghlight.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *left=[[UIBarButtonItem alloc]initWithCustomView:locateBtn];
    self.navigationItem.leftBarButtonItem=left;
    //地图初始化
	m_map=[[MKMapView alloc] init];
    m_map.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
    [self.view addSubview:m_map];
    //定位按钮
    m_map.showsUserLocation=YES;
    //网络连接
	_addressField.text = @"<No updates yet>";
	struct sockaddr_in addr;
	memset(&addr, 0, sizeof(struct sockaddr_in));
	addr.sin_len = sizeof(struct sockaddr_in);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(80);
	inet_aton("173.194.43.0", &addr.sin_addr);
    
	AHReach *addressReach = [AHReach reachForAddress:&addr];
	[addressReach startUpdatingWithBlock:^(AHReach *reach) {
		[self updateAvailabilityField:self.addressField withReach:reach];
	}];
	[self updateAvailabilityField:self.addressField withReach:addressReach];
	self.reaches = [NSArray arrayWithObjects:addressReach, nil];

    }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)updateAvailabilityField:(UITextField *)field withReach:(AHReach *)reach {
    if ([reach isReachableViaWiFi]||[reach isReachableViaWWAN]) {
        m_map.showsUserLocation=YES;
        map_timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(Timer) userInfo:nil repeats:YES];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未连接网络" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)Timer{
    if (map_user.coordinate.latitude==0) {
        NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(dingwei:) userInfo:nil repeats:NO];
        timer=nil;
    }
}

-(void)dingwei:(id)sender{
    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter=0.5;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation]; // 开始定位
    }
    
    NSLog(@"GPS 启动");
    
    
    m_map.showsUserLocation=YES;//定位
    map_user=m_map.userLocation
    ;
    CLLocationCoordinate2D coordinate1=map_user.location.coordinate;
    //大头针的数组
       NSMutableArray * arr = [NSMutableArray array];
	MapAnnotationExample *ann = [[MapAnnotationExample alloc] init];
	ann.coordinate = coordinate1;
    NSString *map_location=[[NSUserDefaults standardUserDefaults] objectForKey:@"Location"];
	ann.title = map_location;
	ann.pinAnnotationColor = MKPinAnnotationColorPurple;
	ann.opensWhenShown = YES;
	[arr addObject:ann];
    map_mh = [VPPMapHelper VPPMapHelperForMapView:m_map pinAnnotationColor:MKPinAnnotationColorGreen centersOnUserLocation:NO showsDisclosureButton:YES delegate:self];
    m_map.showsUserLocation=YES;
    map_mh.userCanDropPin=YES;
    [map_mh setMapAnnotations:arr];
    [m_map setCenterCoordinate:coordinate1 animated:YES];
   
    
}
#pragma mark  定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D mylocation = newLocation.coordinate;//手机GPS
    
    
    mylocation = [self zzTransGPS:mylocation];
    
    //显示大头针坐标
    [self SetMapPoint:mylocation];
    
    /////////获取位置信息
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
     {
         if (placemarks.count >0   )
         {
             CLPlacemark * plmark = [placemarks objectAtIndex:0];
             NSString * country = plmark.country;
             NSString * plmark1    = plmark.subLocality;
             NSString * city1   = plmark.administrativeArea;
             
             NSLog(@"%@-%@-%@-%@",country,city1,plmark1,plmark.name);
             string=[NSString stringWithFormat:@"%@",plmark.name];
             NSLog(@"%@",plmark.name);
             
             [[NSUserDefaults standardUserDefaults]setObject:string forKey:@"Location"];
             
             [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",map_user.coordinate.latitude] forKey:@"lat"];
             
             [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",map_user.coordinate.longitude] forKey:@"lon"];
         }
         
         //NSLog(@"%@",placemarks);
         
     }];
    
}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
}

-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(yGps.latitude*10);
    TenLog = (int)(yGps.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
    NSLog(@"%@",sql);
    int offLat=0;
    int offLog=0;
        yGps.latitude = yGps.latitude+offLat*0.0001;
    yGps.longitude = yGps.longitude + offLog*0.0001;
    return yGps;
    
    
}
#pragma mark 定位拉近的距离
-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation
{
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=map_user.location.coordinate;
    [m_map setZoomEnabled:YES];
    [m_map setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [m_map setRegion:theRegion animated:YES];
}
#pragma mark 切换到另一个界面
-(void)open:(id<MKAnnotation>)annotation{
    firstViewController *camer=[[firstViewController alloc] init];
    camer.hidesBottomBarWhenPushed=YES;
    camer.title=@"发送消息";
    [self.navigationController pushViewController:camer animated:YES];
    
}
- (NSString *)tabImageName
{
	return @"mapunselect.png";
}

- (NSString *)tabTitle
{
	return self.title=@"地图";
}

@end
