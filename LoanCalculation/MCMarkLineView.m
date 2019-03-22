//
//  MCmarkLineView.m
//  MingCe
//
//  Created by 名策 on 2017/1/10.
//  Copyright © 2017年 private team. All rights reserved.
//

#import "MCMarkLineView.h"
#import "MCReturnRate.h"
#import "UIView+FrameChange.h"
#import "UIView+Toast.h"




#define KPointWidth 5

@interface MCMarkLineView () {
    CGFloat oldMarkY;
    CGFloat _x;
    CGFloat _y1;
    CGFloat _y2;
}

@property (nonatomic,strong)UIView *markView;
@property (nonatomic,strong)UILabel *datelabel;
@property (nonatomic,strong)UILabel *returnRateLabel;
@property (nonatomic,strong)UILabel *refReturnlabel;
@property (nonatomic,strong)UILabel *zTitileLabel;
@property (nonatomic,strong)UILabel *hTitleLabel;


@end

@implementation MCMarkLineView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _markView = [[UIView alloc] initWithFrame:CGRectMake(6, 0, 110, 50)];
        _markView.backgroundColor = UIColorFromRGB(0x1a1c20);
        _markView.layer.borderColor = [UIColor blackColor].CGColor;
        _markView.layer.borderWidth = 0.5;
        _markView.layer.cornerRadius = 5.0;
        [self addSubview:_markView];
        
        _datelabel = [[UILabel alloc] initWithFrame:CGRectMake(10,2 , 90, 15)];
        _datelabel.backgroundColor = [UIColor clearColor];
        _datelabel.textColor = UIColorFromRGB(0x7c7e94);
        _datelabel.font = [UIFont systemFontOfSize:9];
        [_markView addSubview:_datelabel];
        
        _zTitileLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 30, 20)];
        _zTitileLabel.backgroundColor = [UIColor clearColor];
        _zTitileLabel.textColor = TradeLineZuHeColor;
        _zTitileLabel.text = @"等本息:";
        CGSize size = [_zTitileLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
        CGRect frame = _zTitileLabel.frame;
        frame.size.width = size.width;
        _zTitileLabel.frame = frame;
        _zTitileLabel.font = [UIFont systemFontOfSize:10];
        [_markView addSubview:_zTitileLabel];
        
        
        _returnRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + size.width, 15 , 90, 20)];
        _returnRateLabel.backgroundColor = [UIColor clearColor];
        _returnRateLabel.textColor = [UIColor whiteColor];
        _returnRateLabel.font = [UIFont systemFontOfSize:10];
        [_markView addSubview:_returnRateLabel];
        
        _hTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 30, 20)];
        _hTitleLabel.backgroundColor = [UIColor clearColor];
        _hTitleLabel.textColor =  TradeLineHuShenColor;
        
        _hTitleLabel.text = @"等本金";
        size = [_hTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}];
        _hTitleLabel.width = size.width;
        _hTitleLabel.font = [UIFont systemFontOfSize:10];
        [_markView addSubview:_hTitleLabel];
        
        _refReturnlabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + size.width, 30 , 90, 20)];
        _refReturnlabel.backgroundColor = [UIColor clearColor];
        _refReturnlabel.textColor = [UIColor whiteColor];
        _refReturnlabel.font = [UIFont systemFontOfSize:10];
        [_markView addSubview:_refReturnlabel];
        
    }
    return self;
}

- (void)setTitleArr:(NSArray *)titleArr {
    _titleArr = titleArr;
    _zTitileLabel.text = _titleArr[0];
    _hTitleLabel.text = _titleArr[1];
}

- (void)setType:(MarkType)type {
    _type = type;
    if (_type == SingleLine) {
        _markView.height = 42;
        _datelabel.y = 5;
        _zTitileLabel.y = CGRectGetMaxY(self.datelabel.frame);
        _returnRateLabel.y = CGRectGetMaxY(self.datelabel.frame);
        _hTitleLabel.hidden = YES;
        _refReturnlabel.hidden = YES;
        _zTitileLabel.text = @"净值";
    } else {
        _markView.height = 50;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawCoordinateLinesBeginPoint:CGPointMake(_x, 16) endPoint:CGPointMake(_x, rect.size.height - 26)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画圆点
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context,  [UIColor  whiteColor].CGColor);
    CGContextAddArc(context, _x, _y1, 4.5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    //画圆点
    CGRect myOval = {_x - 4, _y1-4, 8, 8};
    CGContextSetFillColorWithColor(context, TradeLineZuHeColor.CGColor);
    CGContextAddEllipseInRect(context, myOval);
    CGContextFillPath(context);
    
    if (_type == DoubleLine) {
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context,  [UIColor  whiteColor].CGColor);
        CGContextAddArc(context, _x , _y2, 4.5, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke);
        
        //画圆点
        CGRect myOval2 = {_x - 4, _y2-4, 8, 8};
        CGContextSetFillColorWithColor(context, TradeLineHuShenColor.CGColor);
        CGContextAddEllipseInRect(context, myOval2);
        CGContextFillPath(context);
        
    }
}

- (void)drawCoordinateLinesBeginPoint:(CGPoint)bPoint endPoint:(CGPoint)ePoint {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置虚线颜色
    CGContextSetStrokeColorWithColor(currentContext,  TradeLineZuHeColor.CGColor);
    //设置虚线宽度
    CGContextSetLineWidth(currentContext, 0.5);
    //设置虚线绘制起点
    CGContextMoveToPoint(currentContext, bPoint.x, bPoint.y);
    //设置虚线绘制终点
    CGContextAddLineToPoint(currentContext, ePoint.x, ePoint.y);
    //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制2个点
    CGFloat arr[] = {3, 1};
    //下面最后一个参数“2”代表排列的个数。
    CGContextSetLineDash(currentContext, 0, arr, 2);
    //画线
    CGContextDrawPath(currentContext, kCGPathStroke);
    CGContextStrokePath(currentContext);
    CGContextSetLineDash(currentContext, 0, NULL, 0);
    
}

- (void)setReturnRate:(MCReturnRate *)returnRate {
    _returnRate = returnRate;
    if (_type == DoubleLine) {
        _datelabel.text = [NSString stringWithFormat:@"第%d月值",returnRate.date];
        if (_titleArr.count == 3) {
            _datelabel.text = [NSString stringWithFormat:@"%d%@",returnRate.date,_titleArr[2]];
        }
        
        _returnRateLabel.text = [NSString stringWithFormat:@"%.2f",returnRate.returnRate ];
        
    } else {
        _datelabel.text = [NSString stringWithFormat:@"%@",returnRate.fundDate];
        _returnRateLabel.text = [NSString stringWithFormat:@"%.3f",returnRate.returnRate];
        
    }
    _refReturnlabel.text =  [NSString stringWithFormat:@"%.2f",returnRate.refReturnRate ];
    
}


- (void)setX:(CGFloat)x withReturnY:(CGFloat)returnY refReturnY:(CGFloat)refReturnY {
    _x = x;
    _y1 = returnY;
    _y2 = refReturnY;
    [self setNeedsDisplay];
    
    CGRect markFrame = _markView.frame;
    CGFloat markY = returnY + 10;
    
    if (fabs(oldMarkY - markY) > 10) {
        if (self.height - markY <  _markView.height) {
            markFrame.origin.y = markY - _markView.height ;
            
        }else{
            markFrame.origin.y = markY;
            
        }
        _markView.frame = markFrame;
        oldMarkY = markY;
    }
    
    if (x + _markView.width > [UIScreen mainScreen].bounds.size.width ) {
        [UIView animateWithDuration:0.25 animations:^{
            _markView.left = _x - _markView.width - 6;
            
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _markView.left =  _x +  6;
            
        }];
    }
    
}

- (NSString *)convertDate:(NSString *)date {
    NSMutableString *muleft=[NSMutableString stringWithFormat:@"%@",date];
    [muleft insertString:@"-" atIndex:muleft.length - 2];
    [muleft insertString:@"-" atIndex:muleft.length - 5];
    return muleft;
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
