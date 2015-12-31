//
//  firstViewController.h
//  地图
//
//  Created by zhaicongcong on 4/15/14.
//  Copyright (c) 2014 zhaicongcong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface firstViewController : UIViewController
<UIImagePickerControllerDelegate,UINavigationBarDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,AVAudioRecorderDelegate,UITextViewDelegate>{
    
    AVAudioRecorder *recorder;
    NSTimer *timer;
    NSURL *urlPlay;
    NSMutableDictionary *jsonObjects;//存放每一个dictionary
}
@property(nonatomic,retain) UIImageView *picture;
@property (retain, nonatomic)  UIButton *record_btn;
@property (retain, nonatomic)  UIButton *playBtn;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (retain,nonatomic) UIButton *photo_button3;
@end
