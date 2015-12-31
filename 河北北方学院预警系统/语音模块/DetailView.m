//
//  DetailView.m
//  YuYinDemo
//
//  Created by kys-2 on 14-3-23.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "DetailView.h"
#import "iflyMSC/IFlySpeechUser.h"
#import "UIPlaceHolderTextView.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "CheackWLan.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "Defines.h"

@interface DetailView ()

@end

@implementation DetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor=[UIColor whiteColor];
    }
    return self;
}
-(void)CreateUIView
{
    UIView *down=[[UIView alloc]init];
    down.frame=CGRectMake(0, ScreenHeight-160+64-44, ScreenWidth, 96);
    down.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"yuyin_btn_backImage.png"]];
    down.alpha=1.0f;
    //
    NSLog(@"1223=%f",ScreenHeight);
    UIButton *Yuyinbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    Yuyinbtn.frame=CGRectMake(ScreenWidth/2-35,13, 70, 70);
    //Yuyinbtn.center=down.center;
    Yuyinbtn.backgroundColor=[UIColor clearColor];
    [Yuyinbtn setImage:[UIImage imageNamed:@"yuyin _btn.png"] forState:UIControlStateNormal];
    //添加脉冲视图
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = Yuyinbtn.center;
    [down.layer insertSublayer:self.halo below:Yuyinbtn.layer];
    self.halo.radius=0.60*kMaxRadius;
    
    self.halo.backgroundColor = CommonColor.CGColor;
    
    [Yuyinbtn addTarget:self action:@selector(StartYuYin:) forControlEvents:UIControlEventTouchUpInside];
    //[down bringSubviewToFront:Yuyinbtn];
    [down addSubview:Yuyinbtn];
    [self.view addSubview:down];
    //
    //初始化 气泡视图
    bubbleData=[[NSMutableArray alloc]init];
    bubbleTable=[[UIBubbleTableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-160-44)];
    bubbleTable.backgroundColor=[UIColor clearColor];
    [bubbleTable setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yuyin_backImage.png"]]];
    [bubbleData addObject:[NSBubbleData dataWithText:@"欢迎使用北院语音助手" andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
    bubbleTable.bubbleDataSource=self;
    [self.view addSubview:bubbleTable];
    _popview = [[PopupView alloc] initWithFrame:CGRectMake(100, 300, 0, 0)];
    _popview.ParentView = self.view;
    //
    count=0;
    //
    UIPlaceHolderTextView *resultView = [[UIPlaceHolderTextView alloc] initWithFrame:
                                         CGRectMake(Margin*2, Margin*2, self.view.frame.size.width-Margin*4, 300)];
    resultView.layer.cornerRadius = 8;
    resultView.layer.borderWidth = 1;
    resultView.font = [UIFont systemFontOfSize:17.0f];
    resultView.placeholder = @"识别结果";
    resultView.editable = NO;
    _textView = resultView;

}
-(void)getNetworkStatus
{
    BOOL IsOk=[CheackWLan cheackWlan];
    if (IsOk==NO) {
        choiceView=[[UIView alloc]init];
        choiceView.frame=CGRectMake(0, 64, 320, 60);
        choiceView.backgroundColor=[UIColor yellowColor];
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(80, 64, 200, 35)];
        imgView.image=[UIImage imageNamed:@"xmlStarIcon.png"];
        
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(70,imgView.frame.size.height+64, 150,20);
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [titleBtn setTitle:@"亲,网络不给力哦" forState:UIControlStateNormal];
        [bubbleTable addSubview:titleBtn];

        [bubbleTable addSubview:imgView];
    }else if(IsOk==YES){
        choiceView.hidden=YES;
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self getNetworkStatus];
    [self CreateUIView];
    [self  InitListenling];
}
#pragma Clickdelegate
-(void)StartYuYin:(id)sender
{//开始语音识别
    count++;//记录次数
    _textView.text=@"";
    [_iflyRecognizerView start];
    NSLog(@"start listenning...");

}
-(void)showChoicebtn:(id)sender
{
    choiceView.hidden=NO;
}
-(void)ViewHide:(id)sender
{
    choiceView.hidden=YES;
}


#pragma YuYIN
-(void)InitListenling
{
    //初始化语音识别控件
    NSString *initString = [NSString stringWithFormat:@"appid=%@",APPID];
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center initParam:initString];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter:@"domain" value:@"iat"];
    [_iflyRecognizerView setParameter:@"asr_audio_path" value:@"asrview.pcm"];
    
}

#pragma mark delegate
- (void)onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
      [result appendFormat:@"%@",key];
    }
    if ([result length]) {
              _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text,result];
    }
}

- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *)error
{  [bubbleTable reloadData];
      //显示“我”发言的信息
    [bubbleData addObject:[NSBubbleData dataWithText:_textView.text andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeMine]];
    [bubbleTable reloadData];
    //
    NSRange range=[_textView.text rangeOfString:@"打电话"];
    NSRange range1=[_textView.text rangeOfString:@"发短信"];
    // NSLog(@"range====%@",range);
    if (range.length)
    {
        NSString *nameForThree=[[NSString alloc] init];
        if ([_textView.text hasPrefix:@"给"]) {
            if (_textView.text.length==7) {
            NSRange phoneRange=NSMakeRange(1, 2);
            nameForThree=[_textView.text substringWithRange:phoneRange];
             NSLog(@"进行打电话==%@",nameForThree);
                //当信息正确,处理打电话.....
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@打电话...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
                [bubbleTable reloadData];
                //进行打电话。。。。

        }else if (_textView.text.length==8)
        {//获取
            NSRange phoneRange=NSMakeRange(1, 3);
            nameForThree=[_textView.text substringWithRange:phoneRange];
             NSLog(@"进行打电话==%@",nameForThree);
            //当信息正确,处理打电话.....
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@打电话...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
            //进行打电话。。。。
            [bubbleTable reloadData];

        }else if (_textView.text.length==9)
        {//获取
            NSRange phoneRange=NSMakeRange(1, 4);
            nameForThree=[_textView.text substringWithRange:phoneRange];
            NSLog(@"进行打电话==%@",nameForThree);
            //当信息正确,处理打电话.....
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@打电话...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
            //进行打电话。。。。

        }else{
            [bubbleData addObject:[NSBubbleData dataWithText:@"真对不起，我没有听懂您在说什么，请重复一遍吧" andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
        }
            
        }else{
            [bubbleData addObject:[NSBubbleData dataWithText:@"您输入的语音格式不正确\n  正确的格式：给XXX打电话" andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];

        }
    }else if (range1.length){
        //发短信操作
        NSString *nameForThree=[[NSString alloc] init];
        if ([_textView.text hasPrefix:@"给"]) {
        if (_textView.text.length==7) {
            NSRange phoneRange=NSMakeRange(1, 2);
            nameForThree=[_textView.text substringWithRange:phoneRange];
            NSLog(@"进行发短信==%@",nameForThree);
           //信息  正确   发短信
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@发短信...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
            //进行发短信。。。。

        }else if (_textView.text.length==8)
        {//获取
            NSRange phoneRange=NSMakeRange(1, 3);
            nameForThree=[_textView.text substringWithRange:phoneRange];
            NSLog(@"进行发短信==%@",nameForThree);
            //信息  正确   发短信
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@发短信...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
            //进行发短信。。。。

        }else if (_textView.text.length==9)
        {//获取
            NSRange phoneRange=NSMakeRange(1, 4);
            nameForThree=[_textView.text substringWithRange:phoneRange];
            NSLog(@"进行发短信==%@",nameForThree);
            //信息  正确   发短信
            [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"系统开始给%@发短信...",nameForThree] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];
            //进行发短信。。。。

        }else{
           
            [bubbleData addObject:[NSBubbleData dataWithText:@"真对不起，我没有听懂您在说什么，请重复一遍吧" andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];

        }
        }else{
         [bubbleData addObject:[NSBubbleData dataWithText:@"您输入的语音格式不正确\n正确的格式：给XXX发短信" andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
            [bubbleTable reloadData];

        }

        //NSLog(@"发短信");
    }else {//识别之后信息进行新闻服务器搜索....
        [bubbleData addObject:[NSBubbleData dataWithText:[NSString stringWithFormat:@"正在搜索内容为 \n<%@>的新闻",_textView.text] andDate:[NSDate dateWithTimeIntervalSinceNow:395]  andType:BubbleTypeSomeoneElse]];
        [bubbleTable reloadData];
        [self SetRequestForNews];//进行新闻搜索请求
    }
    [bubbleTable reloadData];//刷新数据两次
    
    
    [self.view addSubview:_popview];
    //[_popview setText:[NSString stringWithFormat:@"识别结束,错误码:%d",[error errorCode]]];
    NSLog(@"errorCode:%d",[error errorCode]);
    //添加定时器用于解决 气泡视图显示不全
    NSTimer *connectionTimer;  //timer对象
    //实例化timer
    connectionTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(refreshData) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:connectionTimer forMode:NSDefaultRunLoopMode];
}
-(void)refreshData
    {
    [bubbleTable reloadData];
    
    }

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma search  For News
-(void)SetRequestForNews
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:_textView.text, @"newsSearch", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URL_NEWS]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailed:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceed:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
    [SVProgressHUD showWithStatus:@"正在进行新闻搜索,\n请稍等..."];
    self.view.userInteractionEnabled=NO;
}
//网络请求失败
- (void)ASIHttpRequestFailed:(ASIHTTPRequest *)request{
    //
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    
    NSError *error = [request error];
    [request setNumberOfTimesToRetryOnTimeout:2];
    NSString *errorStr=[error.userInfo valueForKey:@"NSLocalizedDescription"];
    if ([errorStr isEqualToString:@"The request timed out"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络请求超时，请重新连接" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=100;
        [alert show];
        alert.alpha=0.5;
        alert.backgroundColor=[UIColor cyanColor];
        
    }else if([errorStr isEqualToString:@"A connection failure occurred"]){
        [SVProgressHUD showErrorWithStatus:@"网络连接失败"];
    }
    NSLog(@"the error is1234 %@",errorStr);
}
//网络请求成功
- (void)ASIHttpRequestSuceed:(ASIHTTPRequest *)request{
    
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    
    NSData *responseData = [request responseData];
    jsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",jsonObjects);
    @try {
    if ([jsonObjects count])
    {
        if ([[jsonObjects valueForKey:@"Status"] isEqualToString:@"Fail"])
        {
            [self.view addSubview:_popview];
            [_popview setText:@"搜索新闻失败\n请重新操作"];
        }
        else if ([[jsonObjects valueForKey:@"Status"] isEqualToString:@"NoHaveNews"])
        {
            [self.view addSubview:_popview];
            [_popview setText:@"没有您想要的新闻\n请重新输入关键词!"];

        }
        else if (![[jsonObjects valueForKey:@"Status"]length] )
        {
           
            SearchForNews *newslist=[[SearchForNews alloc]init];
            newslist.title=@"新闻列表";
            newslist.NewsData=jsonObjects;
            newslist.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:newslist animated:YES];
        }
        else
        {
             [_popview setText:@"没有您想要的新闻\n请重新输入关键词!"];
        }
    }
    else
    {
        [self.view addSubview:_popview];
        [_popview setText:@"获取新闻数据为空!"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"搜索新闻列表==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"搜索新闻列表==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"搜索新闻列表");
    }
    

}
- (NSString *)tabImageName
{
	return @"yuyinunselect.png";
}

- (NSString *)tabTitle
{
	return self.title=@"语音助手";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
