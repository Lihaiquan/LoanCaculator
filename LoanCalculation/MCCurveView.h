//
//  MCCurveView.h
//  MingCe
//
//  Created by haoliqiang on 16/12/13.
//  Copyright © 2016年 private team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCCurveView : UIView
@property(nonatomic,strong)NSArray *dataArr;
@property(nonatomic,assign)int type;//0一周 1 一月 2 三个月 3 一年，4创建以来

- (void)markViewDisappear;
@end
