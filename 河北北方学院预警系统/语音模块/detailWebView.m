//
//  detailWebView.m
//  NEwsDEmo
//
//  Created by kys-2 on 14-3-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "detailWebView.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
@interface detailWebView ()

@end

@implementation detailWebView
@synthesize URlAddress;
#pragma secondREquest  FOR webViewContent
/*-(void)getSecondNewsContent
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://211.82.193.74:8080/school5/news/5/client.html"]];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestSecondFailed:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSecondSuceed:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestSecondFailed:(ASIHTTPRequest *)request{
    
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSecondSuceed:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    SecondContent=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",SecondContent);
}
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView *detail=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 460+[self.hight intValue]+50)];
    detail.backgroundColor=[UIColor colorWithRed:0.77 green:1.0 blue:0.66 alpha:1.0];
    detail.delegate=self;
    detail.scalesPageToFit=YES;//自动适合大小
    [detail loadRequest:[NSURLRequest requestWithURL:URlAddress]];
   // [detail loadHTMLString:@"你好啊" baseURL:nil];
    activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    activity.backgroundColor=[UIColor blackColor];
    [activity setCenter:self.view.center];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.hidesWhenStopped=YES;
    [detail addSubview:activity];
    [self.view addSubview:detail];
    NSLog(@"333333===%@",URlAddress);
    
    //[self getSecondNewsContent];
    
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    activity= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    activity.backgroundColor=[UIColor blackColor];
    [activity setCenter:self.view.center];
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.hidesWhenStopped=YES;
    //[detail addSubview:activity];
    //[self.view addSubview:detail];
    [view addSubview:activity];
    [activity startAnimating];
    
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
    [activity stopAnimating];
    activity.hidden=YES;
    //[activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    NSLog(@"webViewDidFinishLoad");
    
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activity stopAnimating];
    //[activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
   // NSLog(@"webViewDidFinishLoad");
    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alterview show];
    NSLog(@"%@",[error description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
