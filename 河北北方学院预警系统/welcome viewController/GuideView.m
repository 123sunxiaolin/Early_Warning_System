//
//  GuideView.m
//  记忆留痕
//
//  Created by kys-2 on 14-10-8.
//  Copyright (c) 2014年 sxl. All rights reserved.
//

#import "GuideView.h"
#import "defines.h"
@interface GuideView ()

@end

@implementation GuideView
@synthesize guideScrollView,pageControl,guide_imageView;
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
    self.view.backgroundColor=[UIColor whiteColor];
    guideScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    guideScrollView.pagingEnabled = YES;     //每次移动一页
    guideScrollView.bounces=NO;
    guideScrollView.showsVerticalScrollIndicator = NO;   //不显示垂直滚动条
    guideScrollView.showsHorizontalScrollIndicator = NO; //不显示水平滚动条
    guideScrollView.delegate=self;
    guideScrollView.backgroundColor=[UIColor clearColor];
    guideScrollView.contentSize=CGSizeMake(ScreenWidth*3, ScreenHeight);
    [self.view addSubview:guideScrollView];
    
    //插入图片
    NSArray *imageArray=[NSArray arrayWithObjects:@"welcome_alarm.png",@"welcome_dianming.png" ,@"welcome_functions.png",nil];
    for (int i=0; i<3; i++) {
        guide_imageView=[[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth*i, 0, ScreenWidth, ScreenHeight)];
        guide_imageView.image=[UIImage imageNamed:[imageArray objectAtIndex:i]];
        [guideScrollView addSubview:guide_imageView];
    }
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(guideScrollView.frame.origin.x,guideScrollView.frame.origin.y+guideScrollView.frame.size.height-20 , ScreenWidth, 20)];
    pageControl.hidesForSinglePage = YES;
    pageControl.userInteractionEnabled = NO;
    pageControl.backgroundColor=[UIColor clearColor];
    pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
    pageControl.numberOfPages = 3; //总页码
    pageControl.currentPage = 0;    //当前页码
    [self.view addSubview:pageControl];
    
    //添加取消按钮
    UIButton *startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame=CGRectMake(660, ScreenHeight-70, 280, 50);
    startBtn.backgroundColor=[UIColor redColor];
    startBtn.layer.masksToBounds=YES;
    startBtn.layer.cornerRadius=5.0;
    startBtn.titleLabel.font=[UIFont boldSystemFontOfSize:20];
    startBtn.titleLabel.textColor=[UIColor whiteColor];
    startBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
    [startBtn setTitle:@"开始体验吧!" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(send_ChangeFunction) forControlEvents:UIControlEventTouchUpInside];
    [guideScrollView addSubview:startBtn];

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    pageControl.currentPage=floor(scrollView.contentOffset.x/scrollView.frame.size.width);;
}
-(void)send_ChangeFunction
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setValue:@"firstload" forKey:@"loadtag"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"welcomeview" object:self userInfo:dic];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
