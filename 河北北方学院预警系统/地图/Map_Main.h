//
//  Map_Main.h
//  地图模块
//
//  Created by kys-2 on 14-5-11.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person_Cell.h"
#import <AVFoundation/AVFoundation.h>
@class AudioPlayer;
@interface Map_Main : UIViewController<UITableViewDataSource,UITableViewDelegate,MapPersonCellDelegate,AVAudioPlayerDelegate>
{
    UITableView *PersonTable;
    //网络请求
    NSMutableDictionary *JsonClassmates;
    CGSize titleSize;
    NSString *currentTime;//当前时间
    
    AudioPlayer *Map_audioPlayer;
     NSArray *itemArray;
    NSArray *_urls;
    
    
}

@property (nonatomic,strong)NSString *GradeId;
@property (nonatomic,strong)NSString *contentString;

-(void)BackToFrontView;
//网络请求
-(void)RequestForClassmatesInfoByGrade;
//计算字符串的大小
-(CGSize)GetSizeFromString:(NSString *)string;
@end
