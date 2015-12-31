//
//  firstViewController.m
//  地图
//
//  Created by zhaicongcong on 4/15/14.
//  Copyright (c) 2014 zhaicongcong. All rights reserved.
//

#import "firstViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"
#import "Defines.h"
#import "iToast.h"
#import "SVProgressHUD.h"

#define UrlForsendpicture @"/school5/mapInStudent.html"
#define Url1 @"/school5/longLatImageInput1.html"

@interface firstViewController ()
{
    UITextView *describe_text;
    BOOL isFullScreen;
     BOOL IsShowAlert;
     UIImageView *imageView;
    UIImage * image;
    NSString *musicUrl;
    UIButton *Send_button;
     UILabel *wordCount;
    UILabel *titleLable;
    NSString *text;
     //UIButton *makeSoundButton;
}
@end

@implementation firstViewController

@synthesize playBtn = luyin_playBtn;
@synthesize record_btn;
@synthesize photo_button3=photo_button3;

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
    //背景图片
    self.view.backgroundColor=[UIColor cyanColor];
    UIImageView *tupian=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    tupian.image=[UIImage imageNamed:@"map_backImage.png"];
    [self.view addSubview:tupian];
    //题目
    titleLable=[[UILabel alloc] init];
    titleLable.frame=CGRectMake(self.view.frame.size.width/2-40,20 , 80, 20);
    titleLable.textColor=[UIColor redColor];
    titleLable.text=@"发送消息";
    [self.view addSubview:titleLable];
    //相册的按钮
   photo_button3=[UIButton buttonWithType:UIButtonTypeCustom];
    
    photo_button3.frame=CGRectMake(5, self.view.frame.size.height/3+20, self.view.frame.size.width/4-10,self.view.frame.size.height/4-5);
    photo_button3.backgroundColor=[UIColor clearColor];
    [photo_button3 setImage:[UIImage imageNamed:@"map_photoBtn.png"] forState:UIControlStateNormal];
        [photo_button3.layer setCornerRadius:5.0];
    [photo_button3 addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    ////返回按钮
    UIButton *return_button5=[UIButton buttonWithType:UIButtonTypeCustom];
    return_button5.frame=CGRectMake( self.view.frame.size.width-50,20, 40, 30);
    [return_button5 setImage:[UIImage imageNamed:@"map_return.png"] forState:UIControlStateNormal];
    
    [return_button5 addTarget:self action:@selector(pass) forControlEvents:UIControlEventTouchDown];
    //描述现场情况的Text
    describe_text.delegate=self;
    describe_text=[[UITextView alloc] initWithFrame:CGRectMake(5, 64, self.view.frame.size.width-10, self.view.frame.size.height/3-35-14)];
    describe_text.font=[UIFont fontWithName:@"Arial" size:18.0];
    describe_text.backgroundColor=[UIColor whiteColor];
    describe_text.text=@"现场情况:";
    text=[[NSString alloc] init];
    describe_text.layer.contents = (id)[UIImage imageNamed:@"map_textBack.png"].CGImage;
    [describe_text.layer setCornerRadius:5.0];
    describe_text.alpha=1.0;
    wordCount=[[UILabel alloc] initWithFrame:CGRectMake(220, describe_text.frame.size.height-20, 100, 20)]; 
    wordCount.textColor=[UIColor redColor];
    wordCount.text=[NSString stringWithFormat:@"%d/120",wordCount.text.length+5];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];//监听键盘
    [describe_text addSubview:wordCount];
    
    
    UIToolbar * topView = [[UIToolbar alloc]
                           initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView
     setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem * btnSpace =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self
     action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self
                                    action:@selector(quxiaojianpan)];
    NSArray * buttonsArray = [NSArray
                              arrayWithObjects:btnSpace, doneButton, nil];
    
    
    [topView setItems:buttonsArray]; 
    
    [describe_text setInputAccessoryView:topView];
    
    //picture .........
    _picture=[[UIImageView alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height/12*7+20, self.view.frame.size.width-10, self.view.frame.size.height/4-5)];
    _picture.image=[UIImage imageNamed:@"map_Image.png"];
    //向服务端发送信息的按钮
    Send_button=[UIButton buttonWithType:UIButtonTypeCustom];
    Send_button.backgroundColor=[UIColor clearColor];
    Send_button.frame=CGRectMake(5, self.view.frame.size.height/6*5+20, self.view.frame.size.width-10, self.view.frame.size.height/6-25);
    [Send_button.layer setCornerRadius:5.0];
    [Send_button setImage:[UIImage imageNamed:@"map_sendBtn.png"] forState:UIControlStateNormal];
    [Send_button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchDown];
    //录音按钮
    [self audio];
    self.record_btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [record_btn setImage:[UIImage imageNamed:@"map_recordBtn.png"] forState:UIControlStateNormal];
    record_btn.frame=CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/3+20, self.view.frame.size.width/4*3-5, self.view.frame.size.height/8-5);
    record_btn.backgroundColor=[UIColor clearColor];
    [record_btn.layer setCornerRadius:5.0];
    record_btn.backgroundColor=[UIColor yellowColor];
    [self.record_btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.record_btn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.record_btn addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
    [self.view addSubview:record_btn];
    //播放按钮
    self.playBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"map_playBtn.png"] forState:UIControlStateNormal];
    self.playBtn.backgroundColor=[UIColor blackColor];
    self.playBtn.frame=CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/24*11+20,self.view.frame.size.width/4*3-5, self.view.frame.size.height/8-5);
    [self.playBtn.layer setCornerRadius:5.0];
    [self.playBtn addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:luyin_playBtn];
     
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 63, 107, 128)];
    [self.view addSubview:Send_button];
    [self.view addSubview:describe_text];
    
    //[self.view addSubview:Carema_Button1];
    [self.view addSubview:photo_button3];
    [self.view addSubview:return_button5];
    [self.view addSubview:imageView];
    [self.view addSubview:_picture];
}
-(void)textViewDidChange:(UITextView *)textView{
    textView=describe_text;
    NSInteger number = [textView.text length];
    if (number > 120) {
        IsShowAlert =YES;
    }if (IsShowAlert) {
        [describe_text resignFirstResponder];
        UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"您已超字数" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [AlerVIew show];
        IsShowAlert=NO;
        //textView.text = [textView.text substringToIndex:120];
        // number = 120;
    }
    wordCount.text=[NSString stringWithFormat:@"%d/120",number];
     text=describe_text.text;
}

#pragma  mark 录音的动画
#pragma mark 播放录音
-(void)playRecordSound:(id)sender{
    [describe_text resignFirstResponder];
    if (self.avPlay.playing) {
        [self.avPlay pause];
        return;
        
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlPlay error:nil];
    self.avPlay=player;
    [self.avPlay play];
    
}
-(void)btnDown:(id)sender
{
    [describe_text resignFirstResponder];
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
    //设置定时检测
    timer =[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    
}
-(void)btnUp:(id)sender{
    double cTime = recorder.currentTime;
    if (cTime > 0) {
        //如果时间<2 不发送
        NSLog(@"发出去");
        
    }else{
        //删除记录文件
        [recorder deleteRecording];
        //删除存储的
    }
    [recorder stop];
    [timer invalidate];
    [imageView setImage:[UIImage imageNamed:nil]];
}
-(void)btnDragUp:(id)sender{
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    NSLog(@"取消发生");
    
}
-(void)audio{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数 1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数 8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //录音文件的URL
    musicUrl =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"nnn.aac"];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",musicUrl]];
    NSLog(@"录音===%@",musicUrl);
    
    urlPlay = url;
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled=YES;
    recorder.delegate=self;
    
}
#pragma  mark 录音的动画
- (void)detectionVoice
{
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}
#pragma mark 录音启动图片
- (void) updateImage
{
    [imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
}
#pragma mark 返回地图
-(void)pass{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 添加相机的方法
-(void)addCarema
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;  //是否可编辑
        //摄像头
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	[picker dismissViewControllerAnimated:YES completion:^{}];
    //得到图片
     image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage:image withName:@"currentImage.png"];
    //图片文件的URL
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];

    NSLog(@"相片====%@",fullPath);
    
    isFullScreen = NO;
    [self.picture setImage:savedImage];
    
    self.picture.tag = 100;

    //图片存入相册
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)quxiaojianpan{
    [describe_text resignFirstResponder];
}
#pragma mark 取消键盘  放缩选择的图片
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [describe_text resignFirstResponder];
    isFullScreen = !isFullScreen;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    CGPoint imagePoint = self.picture.frame.origin;
    //touchPoint.x ，touchPoint.y 就是触点的坐标
    // 触点在imageView内，点击imageView时 放大,再次点击时缩小
    if(imagePoint.x <= touchPoint.x && imagePoint.x +self.picture.frame.size.width >=touchPoint.x && imagePoint.y <=  touchPoint.y && imagePoint.y+self.picture.frame.size.height >= touchPoint.y)
    {
        // 设置图片放大动画
        [UIView beginAnimations:nil context:nil];
        // 动画时间
        [UIView setAnimationDuration:0.3];
        
        if (isFullScreen) {
            // 放大尺寸
            self.picture.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [UIView animateWithDuration:1.5 animations:^
            {
                //缩放效果
                
                describe_text.transform=CGAffineTransformMakeScale(0.2, 0.2);
                luyin_playBtn.transform=CGAffineTransformMakeScale(0.2, 0.2);
                self.record_btn.transform=CGAffineTransformMakeScale(0.2, 0.2);
                photo_button3.transform=CGAffineTransformMakeScale(0.2, 0.2);
                Send_button.transform=CGAffineTransformMakeScale(0.2, 0.2);
                describe_text.alpha=0.0;
                luyin_playBtn.alpha=0.0;
                self.record_btn.alpha=0.0;
                photo_button3.alpha=0.0;
                Send_button.alpha=0.0;
                
            }completion:^(BOOL finished)
             {
                 [describe_text removeFromSuperview];
                 [luyin_playBtn removeFromSuperview];
                 [self.record_btn removeFromSuperview];
                 [photo_button3 removeFromSuperview];
                 [Send_button removeFromSuperview];
             }];
            
            
        }
        else {
            // 缩小尺寸
            self.picture.frame = CGRectMake(5, self.view.frame.size.height/12*7+20, self.view.frame.size.width-10, self.view.frame.size.height/4-5);
            [self.view addSubview:describe_text];
            [self.view addSubview:luyin_playBtn];
            [self.view addSubview:self.record_btn];
            //[self.view addSubview:photo_button3];
            //向服务端发送信息的按钮
            Send_button=[UIButton buttonWithType:UIButtonTypeCustom];
         
            Send_button.frame=CGRectMake(5, self.view.frame.size.height/6*5+20, self.view.frame.size.width-10, self.view.frame.size.height/6-25);
           
                      [Send_button setImage:[UIImage imageNamed:@"map_sendBtn.png"] forState:UIControlStateNormal];
            Send_button.alpha=1.0;
            [Send_button.layer setCornerRadius:5.0];
            [Send_button addTarget:self action:@selector(Send) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:Send_button];
            //相册的按钮
            photo_button3=[UIButton buttonWithType:UIButtonTypeCustom];
            photo_button3.frame=CGRectMake(5, self.view.frame.size.height/3+20, self.view.frame.size.width/4-10,self.view.frame.size.height/4-5);
            [photo_button3.layer setCornerRadius:5.0];
            photo_button3.alpha=1.0;
            [photo_button3 addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
            [photo_button3 setImage:[UIImage imageNamed:@"map_photoBtn.png"] forState:UIControlStateNormal];
            [self.view addSubview:photo_button3];
            //描述现场情况的Text
            describe_text=[[UITextView alloc] initWithFrame:CGRectMake(5, 64, self.view.frame.size.width-10, self.view.frame.size.height/3-35-14)];
            
            describe_text.font=[UIFont fontWithName:@"Arial" size:18.0];
            describe_text.backgroundColor=[UIColor whiteColor];
            NSLog(@"-%@--%@-",describe_text.text,text);
            if ([text isEqual:@""]) {
                describe_text.text=@"现场情况:";
            }else{
                describe_text.text=text;

            }
                    describe_text.layer.contents = (id)[UIImage imageNamed:@"map_textBack.png"].CGImage;
            
            UIToolbar * topView = [[UIToolbar alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 30)];
            [topView
             setBarStyle:UIBarStyleDefault];
            
            UIBarButtonItem * btnSpace =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self
             action:nil];
            UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self
                                            action:@selector(quxiaojianpan)];
            NSArray * buttonsArray = [NSArray
                                      arrayWithObjects:btnSpace, doneButton, nil];
           
            
            [topView setItems:buttonsArray]; 
           
            [describe_text setInputAccessoryView:topView];

            [self.view addSubview:describe_text];
            wordCount.textColor=[UIColor redColor];
            wordCount.text=[NSString stringWithFormat:@"%d/120",wordCount.text.length];
        
            [describe_text addSubview:wordCount];
            self.record_btn=[UIButton buttonWithType:UIButtonTypeCustom];
            [record_btn setImage:[UIImage imageNamed:@"map_recordBtn.png"] forState:UIControlStateNormal];
            record_btn.alpha=1.0;
            [record_btn.layer setCornerRadius:5.0];
            record_btn.backgroundColor=[UIColor yellowColor];
            record_btn.frame=CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/3+20, self.view.frame.size.width/4*3-5, self.view.frame.size.height/8-5);
            [self.record_btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
            [self.record_btn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
            [self.record_btn addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
            [self.view addSubview:record_btn];
            self.playBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.playBtn setImage:[UIImage imageNamed:@"map_playBtn.png"] forState:UIControlStateNormal];
            [self.playBtn.layer setCornerRadius:5.0];
            self.playBtn.backgroundColor=[UIColor blackColor];
            self.playBtn.alpha=1.0;
            self.playBtn.frame=CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/24*11+20,self.view.frame.size.width/4*3-5, self.view.frame.size.height/8-5);
            
            [self.playBtn addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:luyin_playBtn];
        }
        // commit动画
        [UIView commitAnimations];
        
    }
    
}
#pragma mark - actionsheet delegate 判断是否支持相机与相册功能
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
       
    }
}
- (void)chooseImage:(id)sender {
    //[self.tabBarController.tabBar setHidden:YES];
     [describe_text resignFirstResponder];
     UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择" ,nil];
    }
    
    sheet.tag = 255;
    [sheet showInView:self.view];
    
}


-(void)openPicLibrary
{
    //相册是可以用模拟器打开的
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;//是否可以编辑
        
        //打开相册选择照片
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
//选中图片进入的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 发送文件的方法
-(void)Send{
    [SVProgressHUD showWithStatus:@"正在发送..."];
    [describe_text resignFirstResponder];
    NSString *location=[[NSUserDefaults standardUserDefaults] objectForKey:@"Location"];
    NSString *lat=[[NSUserDefaults standardUserDefaults]objectForKey:@"lat"];
    NSString *lon=[[NSUserDefaults standardUserDefaults] objectForKey:@"lon"];
    NSString *word=describe_text.text;
    NSArray *imagePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *imagePath=[[imagePathArray objectAtIndex:0] stringByAppendingPathComponent:@"currentImage.png"];
    
   NSArray *musicPathArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *musicPath=[[musicPathArray objectAtIndex:0] stringByAppendingPathComponent:@"nnn.aac"];
    NSLog(@"%@",musicPath);
       NSData *musicDta=[NSData dataWithContentsOfFile:musicPath];
    NSString *MusicString=[musicDta base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//录音转码base64Encoding
   
    
    NSData *imageData=[NSData dataWithContentsOfFile:imagePath];
    NSString* pictureDataString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//图片转码成为base64Encoding
    
    
    NSDictionary *MusicDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:@"aac",@"fileExtension",MusicString,@"speech", nil];
    NSArray *MusicArray=[[NSArray alloc] initWithObjects:MusicDictionary, nil];
    
    
    NSDictionary *imageDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:@"png",@"fileExtension",pictureDataString,@"picture", nil];
    NSArray *pictureArray=[[NSArray alloc] initWithObjects:imageDictionary, nil];
    NSArray *Keyarray=[[NSArray alloc] initWithObjects:@"picture",@"speech", nil];
    
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"userNickname",lat,@"latitude",lon,@"longitude",location,@"geography",word,@"word",Keyarray,@"fileKind",pictureArray,@"picture",MusicArray,@"speech",nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,UrlForsendpicture]];
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
    
  }
//网络请求失败
- (void)ASIHttpRequestFailed:(ASIHTTPRequest *)request{
    
    [SVProgressHUD showErrorWithStatus:@"发送失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceed:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    jsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",jsonObjects);
    NSString *Alert=[jsonObjects valueForKey:@"Status"];
    @try {
    if ([jsonObjects count])
    {
       if ([Alert isEqualToString:@"Success"]) {
        [SVProgressHUD showSuccessWithStatus:@"发送成功"];
        [iToast make:@"发送成功" duration:800];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [SVProgressHUD dismiss];
        UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"发送失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [AlerVIew show];
    }
    }
    else
    {
        [SVProgressHUD dismiss];
        UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"数据返回为空\n请重新操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [AlerVIew show];
        

    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"数据返回为空==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"数据返回为空==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"数据返回");
    }
}


@end
