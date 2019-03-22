//
//  MCmarkLineView.h
//  MingCe
//
//  Created by 名策 on 2017/1/10.
//  Copyright © 2017年 private team. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TradeLineZuHeColor   RGBCOLOR(234, 115, 28)

#define TradeLineHuShenColor RGBCOLOR(23, 124, 250)//沪深

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define ALPHACOLOR(c,a) [(c) colorWithAlphaComponent:(a)]
#define lerp(a,b,p) (a + (b - a) * (p))
#define TradeLineColor RGBCOLOR(153, 153, 153)//盈亏曲线
typedef enum {
    DoubleLine,
    SingleLine,
    
} MarkType;

@class MCReturnRate;

@interface MCMarkLineView : UIView
@property (nonatomic,strong)MCReturnRate *returnRate;
@property (nonatomic,assign)MarkType type;
@property (nonatomic,strong)NSArray *titleArr;
- (void)setX:(CGFloat)x withReturnY:(CGFloat)returnY refReturnY:(CGFloat)refReturnY;


@end
