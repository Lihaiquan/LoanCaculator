//
//  MCCurveView.m
//  MingCe
//
//  Created by haoliqiang on 16/12/13.
//  Copyright © 2016年 private team. All rights reserved.
//

#import "MCCurveView.h"
#import "MCReturnRate.h"
#import "MCMarkLineView.h"
#import "UIView+FrameChange.h"
#define kMarginTop 30
#define kMarginBottom  50
#define kLineBeginMarginLeft 30
#define kLineEndMarginRight 8
@interface MCCurveView()
@property (nonatomic,assign)float maxValue;
@property (nonatomic,assign)float minValue;
@property (nonatomic,assign)float yMaxFrame;
@property (nonatomic,assign)float yMinFrame;
@property (nonatomic,assign)float unitValue;
@property (nonatomic,copy)NSString *leftDate;
@property (nonatomic,copy)NSString *midDate;
@property (nonatomic,copy)NSString *rightDate;

@property (nonatomic,strong)MCMarkLineView *markLine;

@property (nonatomic,assign)float yScale;
@property (nonatomic,assign)float y_scale;
@property (nonatomic,assign)NSInteger yUnitCount;//y轴的单元格个数

@property (nonatomic,assign)NSInteger oldIndex;
@end
@implementation MCCurveView
- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr=[NSArray array];
    }
    return _dataArr;
}


- (NSInteger)yUnitCount {
    switch (self.type) {
        case 0:  //一周
            return 3;
            break;
        case 1:   //一月
            
            return 4;
            
            break;
        case 2:   //三月
            return 5;
            break;
        case 3:   //一年
            return 6;
        case 4:  //创建以来
            
            
            return 6;
        default:
            return 4;
            break;
    }
    return 4;
}

- (float)unitValue {
    
    return (self.maxValue - self.minValue) / self.yUnitCount;
}


- (MCMarkLineView *)markLine {
    if (!_markLine) {
        _markLine = [[MCMarkLineView  alloc] initWithFrame:CGRectMake(0,0, self.width, self.height )];
        _markLine.type = DoubleLine;
        _markLine.backgroundColor = [UIColor clearColor];
        _markLine.hidden = YES;
    }
    return _markLine;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0x121317);
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
        [self addGestureRecognizer:longPress];
        longPress.minimumPressDuration = 0.08;
        [self addSubview:self.markLine];
    }
    return self;
}


- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    CGPoint location = [longPress locationInView:self];
    if ((location.x < kLineBeginMarginLeft + 1)) {
        [self markViewDisappear];
        return;
    }
    if (self.dataArr.count == 0) {
        return;
    }
    
    CGFloat width = self.frame.size.width;
    NSInteger count = self.dataArr.count;
    if (UIGestureRecognizerStateBegan == longPress.state) {
        NSInteger index = (NSInteger)(location.x - kLineBeginMarginLeft) * (count - 1)/(width - kLineBeginMarginLeft - kLineEndMarginRight);
        if (index >= self.dataArr.count) {
            index = self.dataArr.count - 1;
        }
        CGFloat xx = index * (width - kLineBeginMarginLeft - kLineEndMarginRight) / (count - 1) + kLineBeginMarginLeft;
        CGFloat currenLoc = (location.x - kLineBeginMarginLeft) - xx;
        CGFloat rate = currenLoc * (count - 1)/(width - kLineBeginMarginLeft - kLineEndMarginRight);
        NSInteger selectIndex = index;
        if (rate > 0.5) {
            selectIndex = index + 1;
        }
        MCReturnRate *returnRete = self.dataArr[selectIndex];
        CGFloat returnY = [self convertY:[self returnY:returnRete.returnRate]];
        CGFloat refReturnY = [self convertY:[self returnY:returnRete.refReturnRate]];
        CGFloat x = selectIndex * (width - kLineBeginMarginLeft - kLineEndMarginRight)/(count-1) + kLineBeginMarginLeft;
        [self.markLine setX:x withReturnY:returnY refReturnY:refReturnY];
        _markLine.returnRate = returnRete;
        _markLine.hidden = NO;
        _oldIndex = index;
        
    } else if (UIGestureRecognizerStateChanged == longPress.state ) {
        //相对于屏幕的位置
        NSInteger index = (location.x - kLineBeginMarginLeft ) * (count - 1)/(width - kLineBeginMarginLeft - kLineEndMarginRight);
        if (index != _oldIndex) { //不能长按移动一点点就重新绘图  要让定位的点改变了再重新绘图
            if (index >= count) {
                index = count - 1;
            }
            
            MCReturnRate *returnRete = self.dataArr[index];
            CGFloat returnY = [self convertY:[self returnY:returnRete.returnRate]];
            CGFloat refReturnY = [self convertY:[self returnY:returnRete.refReturnRate]];
            CGFloat x = kLineBeginMarginLeft + (index)*(width - kLineBeginMarginLeft - kLineEndMarginRight) / (count-1) ;
            [self.markLine setX:x withReturnY:returnY refReturnY:refReturnY];
            _markLine.returnRate = returnRete;
            _markLine.hidden = NO;
            _oldIndex = index;
        }
    }
}


- (void)markViewDisappear {
    _markLine.hidden = YES;
    _oldIndex = -1;//kLineBeginMarginLeft;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.dataArr.count == 0) {
        //        CGContextRef context=UIGraphicsGetCurrentContext();
        //        CGContextClearRect(context, rect);
        [self drawString:@"暂无可显示的数据" inReact:CGRectMake(self.width/2.0 - 45,(self.bounds.size.height - 40)/2.0 ,200,40) fontSize:14 color:[UIColor colorWithWhite:1.0 alpha:0.3]];
        return;
    } else if (self.dataArr.count == 1) {
        id obj = self.dataArr.firstObject;
        self.dataArr = @[obj,obj];
    }
    // 取出最大值 最小值
    CGContextRef context=UIGraphicsGetCurrentContext();
    //    CGContextClearRect(context, rect);
    
    //     绘制当前路径区域
    [self configureDrawFrameWithRect:rect];
    [self drawCoodinateContext:context];
    [self drawHuShenLine:rect];
    [self drawZuHeLine:rect];
    [self drawYingyinRect:rect withPoints:self.dataArr index:0];
    [self drawCircleWithColor:TradeLineZuHeColor andSquareRect:CGRectMake(self.width/2.0 - 60, 7, 6, 6)];
    NSString *str1 = @"等额本息";
    NSString *str2 = @"等额本金";
    if (_type == 4) {
        _markLine.titleArr = @[@"房价",@"钱",@"月后买入"];
        str1 = @"房价";
        str2 = @"钱数";
    } else if (_type == 3) {
        _markLine.titleArr = @[@"等本息",@"等本金"];
    } else if (_type == 5) {
        _markLine.titleArr = @[@"房价",@"钱",@"年总还款"];
    } else if (_type == 7) {
        str1 = @"等本息月还款";
        str2 = @"月入利息";
        _markLine.titleArr = @[@"月还款",@"月入利息",@"元首付"];
    } else if (_type == 6) {
        _markLine.titleArr = @[@"等本息",@"等本金",@"元首付"];
        
    } else if (_type == 8) {
        str1 = @"等本进月均款";
        str2 = @"月入利息";
        _markLine.titleArr = @[@"月还款",@"月入利息",@"元首付"];
    }
    [self drawString:str1 inReact:CGRectMake(self.width/2.0 - 50, 4.5, 60, 10) fontSize:9];
    [self drawCircleWithColor:TradeLineHuShenColor andSquareRect:CGRectMake(self.width/2.0 + 10, 7, 6, 6)];
    [self drawString:str2 inReact:CGRectMake(self.width/2.0 + 20, 4.5, 60, 10) fontSize:9];
}


- (void)drawCoordinateLinesBeginPoint:(CGPoint)bPoint endPoint:(CGPoint)ePoint {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置虚线颜色
    CGContextSetStrokeColorWithColor(currentContext,  [UIColor colorWithWhite:1 alpha:0.1].CGColor);
    //设置虚线宽度
    CGContextSetLineWidth(currentContext, 0.3);
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
//画字符
- (void)drawString:(NSString *)str inReact:(CGRect)rect {
    [self drawString:str inReact:rect fontSize:8];
}
- (void)drawString:(NSString *)str inReact:(CGRect)rect fontSize:(CGFloat)fontSize {
    [self drawString:str inReact:rect fontSize:fontSize color:TradeLineColor];
    
}

- (void)drawString:(NSString *)str inReact:(CGRect)rect fontSize:(CGFloat)fontSize color:(UIColor*)color {
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentLeft;
    UIFont *textFont = [UIFont systemFontOfSize:fontSize];
    [str drawInRect:rect withAttributes:@{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:textStyle,NSForegroundColorAttributeName:color}];
}


- (void)drawCircleWithColor:(UIColor*)color andSquareRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color set];
    CGContextAddEllipseInRect(context, rect);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
}
//画组合
- (void)drawZuHeLine:(CGRect)rect {
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    // 3.设置一些修饰属性
    aPath.lineWidth = 1.0;
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    UIColor *color = TradeLineZuHeColor;
    [color set];
    NSInteger count = self.dataArr.count;
    MCReturnRate *rate0 = _dataArr[0];
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(kLineBeginMarginLeft,  [self convertY:[self returnY:rate0.returnRate]])];
    for (int i = 0; i < count ; i++) {
        MCReturnRate *rate = (MCReturnRate *)self.dataArr[i];
        [aPath addLineToPoint:CGPointMake(kLineBeginMarginLeft + [self returnX:i ],[self convertY:[self returnY:rate.returnRate]])];
    }
    
    MCReturnRate *rate = (MCReturnRate *)self.dataArr.lastObject;
    [self drawCircleWithColor:TradeLineZuHeColor andSquareRect:CGRectMake(kLineBeginMarginLeft + [self returnX:(int)count - 1 ] - 1.5,[self convertY: [self returnY:rate.returnRate]] - 2, 4, 4)];
    
    [aPath stroke]; // 4.渲染，完成绘制
}
//画沪深
- (void)drawHuShenLine:(CGRect)rect {
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    // 3.设置一些修饰属性
    aPath.lineWidth = 1.0;
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineCapRound;
    UIColor *color =TradeLineHuShenColor;
    [color set];
    
    int count = (int)self.dataArr.count;
    
    MCReturnRate *rate0 = _dataArr[0];
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(kLineBeginMarginLeft, [self convertY:[self returnY:rate0.refReturnRate]])];
    for (int i=0; i < count ; i ++) {
        MCReturnRate *rate = (MCReturnRate *)self.dataArr[i];
        [aPath addLineToPoint:CGPointMake(kLineBeginMarginLeft + [self returnX:i],[self convertY:[self returnY:rate.refReturnRate]])];
        
    }
    
    MCReturnRate *rate = (MCReturnRate *)self.dataArr.lastObject;
    [self drawCircleWithColor:TradeLineHuShenColor andSquareRect:CGRectMake(kLineBeginMarginLeft + [self returnX:(int)count - 1 ] - 1.5,[self convertY: [self returnY:rate.refReturnRate]] - 2, 4, 4)];
    [aPath stroke]; // 4.渲染，完成绘制
}


//
- (void)getMaxAndMinValue {
    //计算最大值
    self.maxValue = - LONG_MAX;
    self.minValue = LONG_MAX;
    
    for(int i = 0;i < self.dataArr.count;i ++) {
        MCReturnRate *rate = self.dataArr[i];
        if (rate.returnRate > self.maxValue) {
            self.maxValue = rate.returnRate;
            if (rate.refReturnRate > self.maxValue) {
                self.maxValue = rate.refReturnRate;
            }
            
        } else if (rate.refReturnRate > self.maxValue) {
            self.maxValue = rate.refReturnRate;
            if (rate.returnRate > self.maxValue) {
                self.maxValue = rate.returnRate;
            }
        }
        
        if (rate.returnRate < self.minValue) {
            self.minValue = rate.returnRate;
            if (rate.refReturnRate < self.minValue) {
                self.minValue = rate.refReturnRate;
            }
        } else if (rate.refReturnRate < self.minValue) {
            self.minValue = rate.refReturnRate;
            if (rate.returnRate < self.minValue) {
                self.minValue = rate.returnRate;
            }
        }
    }
}

//设置参数
- (void)configureDrawFrameWithRect:(CGRect)rect {
    [self getMaxAndMinValue];
    self.unitValue = 1;
    self.yMaxFrame = kMarginTop;
    self.yMinFrame = rect.size.height - kMarginTop;
    self.yScale = 0;
    self.y_scale = 0;
    self.leftDate = nil;
    self.rightDate = nil;
    self.midDate = nil;
    if (self.maxValue > 0 && self.minValue < 0) {
        float max = (self.maxValue / (self.maxValue + fabs(self.minValue))) * (rect.size.height - kMarginBottom - kMarginTop);
        self.yMaxFrame = max + kMarginTop;
        self.yMinFrame = rect.size.height - self.yMaxFrame;
    }else if(self.maxValue <= 0 && self.minValue < 0){
        if (self.maxValue < 0) {
            self.maxValue = 0;
        }
        self.yMaxFrame = kMarginTop;
        self.yMinFrame = rect.size.height - self.yMaxFrame;
    }else if (self.maxValue > 0 && self.minValue >= 0){
        if (self.minValue > 0) {
            self.minValue = 0;
        }
        self.yMaxFrame = rect.size.height - kMarginBottom;
        self.yMinFrame = kMarginTop;
    }
    
    self.rightDate = [NSString stringWithFormat:@"%d",[(MCReturnRate *)self.dataArr.lastObject date]];
    
    self.leftDate =[NSString stringWithFormat:@"%d",[(MCReturnRate *)self.dataArr.firstObject date]];
    if (self.dataArr.count>2) {
        long i = self.dataArr.count/2;
        self.midDate =[NSString stringWithFormat:@"%d",[(MCReturnRate *)self.dataArr[i] date]];
    }
}

- (void)drawYAxisWithString:(NSString *)textString marginTop:(CGFloat)marginTop {
    [self drawString:textString inReact:CGRectMake(1, marginTop, 40, 10)];
    [self drawCoordinateLinesBeginPoint:CGPointMake(kLineBeginMarginLeft, marginTop + 5) endPoint:CGPointMake(self.width - kLineEndMarginRight,  marginTop + 5)];
    
}

- (void)drawXAxisWithString:(NSString *)textString marginLeft:(CGFloat)marginLeft {
    [self drawString:textString inReact:CGRectMake(marginLeft, self.frame.size.height - 10, 60, 20)];
    
}



- (void)drawCoodinateContext:(CGContextRef)context {
    //画0刻度线
    [self drawYAxisWithString:@"0.0" marginTop:self.yMaxFrame];
    
    CGFloat scaleNumbery = (self.bounds.size.height - kMarginBottom - kMarginTop)/(self.yUnitCount + 1);
    if (self.maxValue > 0)
    {
        //画刻度
        //画正半轴
        int ycount = 0;
        if (self.maxValue > 0) {
            ycount = [self yTotalCount:self.maxValue] ;//格数
        }
        self.yScale = scaleNumbery;
        for (int i = 1; i <= ycount + 1 ; i ++) {
            float xscale = scaleNumbery * i;
            float value = i * self.unitValue;
            CGFloat marginY = [self convertY:xscale];
            if (marginY >= 0) {
                NSString *y_strtext =[NSString stringWithFormat:@"%.1f",value];
                [self drawYAxisWithString:y_strtext marginTop:marginY];
            }
            
        }
    }
    //画y轴 负半轴
    if (self.minValue < 0) {
        int y_count = 0;
        if (self.minValue < 0) {
            y_count = [self yTotalCount:self.minValue];//格数
        }
        self.y_scale = scaleNumbery;
        for (int i = - y_count  ; i<0; i++) {
            float yscale = scaleNumbery * i;
            float value=i * self.unitValue;
            NSString *y_strtext = [NSString stringWithFormat:@"%.1f%%",value];
            [self drawYAxisWithString:y_strtext marginTop:[self convertY:yscale]];
        }
    }
    //画x轴
    [self drawXAxisWithString:self.leftDate marginLeft:1];
    if (self.midDate) {
        [self drawXAxisWithString:self.midDate marginLeft:self.frame.size.width *0.5 - 30];
    }
    [self drawXAxisWithString:self.rightDate marginLeft:self.frame.size.width - 2 - 60];
    
}

//绘制阴影
- (void)drawYingyinRect:(CGRect)rect withPoints:(NSArray*)arr index:(NSInteger)index {
    if  (!arr || [arr count]<=0) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        //先画出要裁剪的区域
        CGPoint firstPoint = CGPointMake(kLineBeginMarginLeft, 0);
        CGContextMoveToPoint(context, firstPoint.x, self.yMaxFrame);
        CGContextSetLineWidth(context, 2);
        for (int i=0; i<[arr count]; i++) {
            //画中间的区域
            MCReturnRate *ratel=(MCReturnRate *)[arr objectAtIndex:i];
            CGPoint point =  CGPointMake(kLineBeginMarginLeft +[self returnX:i],[self convertY:[self returnY:ratel.returnRate]]);
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        
        MCReturnRate *lastRate=(MCReturnRate *)[arr objectAtIndex:(arr.count-1)];
        CGPoint lastPoint =  CGPointMake(kLineBeginMarginLeft + [self returnX:(int)[arr count]],[self convertY:[self returnY:lastRate.returnRate]]);
        {
            //画边框
            CGContextAddLineToPoint(context, lastPoint.x, self.frame.size.height);
            CGContextAddLineToPoint(context, lastPoint.x, 0);
            CGContextAddLineToPoint(context, kLineBeginMarginLeft, 0);
            CGContextAddLineToPoint(context, kLineBeginMarginLeft, self.frame.size.height);
        }
        CGContextClosePath(context);
        CGContextAddRect(context, CGRectMake(kLineBeginMarginLeft, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height));
        CGContextEOClip(context);
        //裁剪
        CGContextMoveToPoint(context, firstPoint.x , 0);
        CGContextAddLineToPoint(context,  firstPoint.x, self.frame.size.height);
        CGContextSetLineWidth(context,(self.frame.size.width-kLineBeginMarginLeft - kLineEndMarginRight ) * 2);
        CGContextReplacePathWithStrokedPath(context);
        CGContextClip(context);
        
        //填充渐变
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        if (index == 0) {
            CGFloat colors[] = {
                234/255.0,115/255.0,28/255.0,0.3,
                234/255.0,115/255.0,28/255.0,0.01,
                234/255.0,115/255.0,28/255.0,0.0
            };
            CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 2);
            CGContextDrawLinearGradient(context, gradient, CGPointMake(firstPoint.x , 0), CGPointMake(firstPoint.x , self.frame.size.height), 0);
            CGGradientRelease(gradient);
        }
        else
        {
            CGFloat colors[] = {
                239/255.0,0/255.0,180/255.0,0.6,
                239/255.0,0/255.0,180/255.0,0.0,
                239/255.0,0/255.0,180/255.0,0.0
            };
            CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, 2);
            CGContextDrawLinearGradient(context, gradient, CGPointMake(firstPoint.x, 0), CGPointMake(firstPoint.x, self.frame.size.height), 0);
            CGGradientRelease(gradient);
        }
        
    }
    CGContextRestoreGState(context);
    
}

-(NSString *)convertDate:(NSString *)date{
    NSMutableString *muleft=[NSMutableString stringWithFormat:@"%@",date];
    [muleft insertString:@"." atIndex:muleft.length - 2];
    [muleft insertString:@"." atIndex:muleft.length - 5];
    return muleft;
}
- (float)convertY:(float)y {
    return self.yMaxFrame - y;
}
//获取y轴的总格数 传入受益
- (int)yTotalCount:(float)moneyFlow {
    
    return fabs(moneyFlow/self.unitValue);
}
- (double)returnX:(int)i {
    CGFloat xunit = (self.frame.size.width - kLineBeginMarginLeft - kLineEndMarginRight) / (self.dataArr.count - 1);
    return  i * xunit;
}

- (double)returnY:(float)value {
    if (value>0) {
        return value*self.yScale / self.unitValue;
    }else if (value<0){
        return value*self.y_scale / self.unitValue;
    }else{
        return 0;
    }
}
@end
