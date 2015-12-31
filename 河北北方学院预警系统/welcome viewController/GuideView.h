//
//  GuideView.h
//  记忆留痕
//
//  Created by kys-2 on 14-10-8.
//  Copyright (c) 2014年 sxl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideView : UIViewController<UIScrollViewDelegate>
@property (nonatomic,strong)UIScrollView *guideScrollView;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)UIImageView *guide_imageView;
@end
