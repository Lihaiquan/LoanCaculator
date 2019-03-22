//
//  ViewController.m
//  LoanCalculation
//
//  Created by 名策 on 2017/3/29.
//  Copyright © 2017年 名策. All rights reserved.
//

#import "ViewController.h"
#import "MCCurveView.h"
#include "MCReturnRate.h"
#import "KLTNavigationController.h"
#import "SecondViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()

@property (nonatomic,strong) UIButton * selectedBtn;
@property (nonatomic,strong) UIButton *secondSelectedBtn;
@property (strong, nonatomic)  MCCurveView *second;

@property (weak, nonatomic) IBOutlet UITextField *jine;
@property (weak, nonatomic) IBOutlet UITextField *lilv;

@property (weak, nonatomic) IBOutlet UITextField *nianshu;
@property (strong, nonatomic)  MCCurveView *first;
@property (nonatomic, strong) NSMutableArray *firstDataArr;//月还款
@property (nonatomic, strong) NSMutableArray *secondDataArr;//月累计还款
@property (nonatomic, strong) NSMutableArray *firstLilvArr;//月利息
@property (nonatomic, strong) NSMutableArray *secondLiLvArr;//月累计利息
@property (nonatomic, strong) NSMutableArray *firstBenjinArr;//月本金
@property (nonatomic, strong) NSMutableArray *secondbenjinArr;//月累计本金
@property (nonatomic, strong) NSMutableArray *firstYearJineArr;//年数与总金额
@property (nonatomic, assign) BOOL isStartAnalyze;
@end

@implementation ViewController


- (void)more:(UIButton *)button {
    SecondViewController *sVC = [[SecondViewController alloc] init];
    KLTNavigationController *lNav = [[KLTNavigationController alloc] initWithRootViewController:sVC];
    [self presentViewController:lNav animated:YES completion:NULL];
}

- (IBAction)analyze:(id)sender {
    if ([_jine.text isEqualToString:@""] || [_lilv.text isEqualToString:@""] || [_nianshu.text isEqualToString:@""]) {
        
        _isStartAnalyze = NO;
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先输入正确参数." preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        _isStartAnalyze = YES;
        [_firstDataArr removeAllObjects];
        [_secondDataArr removeAllObjects];
        
        [_firstLilvArr removeAllObjects];
        [_secondLiLvArr removeAllObjects];
        
        [_firstBenjinArr removeAllObjects];
        [_secondbenjinArr removeAllObjects];
        [_firstYearJineArr removeAllObjects];
        
      NSInteger mounth =  [_nianshu.text integerValue] * 12;
        float money = [_jine.text floatValue] * 10000.0;
        double lilv = [_lilv.text doubleValue]/100.0/12.0;
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (money *lilv * pow((1+lilv), mounth))/(pow((1+lilv), mounth) - 1);
            rate.refReturnRate = (money/mounth) + (money - i * (money/mounth))* lilv;
            rate.date = i + 1;
            [_firstDataArr addObject:rate];
        }
        
        
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (i+1) * ((money *lilv * pow((1+lilv), mounth))/(pow((1+lilv), mounth) - 1));
            rate.refReturnRate = ((i + 1) * ((money/mounth) + money * lilv) - (money/mounth) *lilv *(1+ i) * i/2.0);
            rate.date = i + 1;
            [_secondDataArr addObject:rate];
        }
        
        
        
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (((money *lilv * pow((1+lilv), mounth))/(pow((1+lilv), mounth) - 1) - pow(1+ lilv, i)*money *lilv/(pow(1+ lilv, mounth) - 1)));
            rate.refReturnRate = (money - i * (money/mounth))* lilv;
            rate.date = i + 1;
            [_firstLilvArr addObject:rate];
        }
        
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = pow(1+ lilv, i)*money *lilv/(pow(1+ lilv, mounth) - 1);
            rate.refReturnRate = money/mounth;
            rate.date = i + 1;
            [_firstBenjinArr addObject:rate];
        }
        
        //50年的
        for (int i = 1; i <= 50; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (i * 12) * ((money *lilv * pow((1+lilv), (i * 12)))/(pow((1+lilv), (i * 12)) - 1));
            rate.refReturnRate = ((i * 12) * ((money/(i * 12)) + money * lilv) - (money/(i * 12)) *lilv *(12*i) * (12*i - 1)/2.0);
            rate.date = i;
            [_firstYearJineArr addObject:rate];
        }
        
        
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (i + 1) *(money *lilv * pow((1+lilv), mounth))/(pow((1+lilv), mounth) - 1) - money *(pow(1 + lilv, i + 1)-1)/(pow(1+lilv, mounth) - 1);
            rate.refReturnRate = (i + 1) * money *lilv - (money/mounth)*lilv *(i *(i + 1))/2.0;
            rate.date = i + 1;
            [_secondLiLvArr addObject:rate];
        }
        
        for (int i = 0; i < mounth; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = money *(pow(1+lilv, (i + 1))- 1)/(pow(1+lilv, mounth) - 1);
            rate.refReturnRate = (i + 1) * money/mounth;
            rate.date = i + 1;
            [_secondbenjinArr addObject:rate];
        }
        
        
        NSInteger ind = _selectedBtn.tag;
        if (ind == 100) {
            _first.dataArr = _firstDataArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (ind == 101) {
            _first.dataArr = _firstLilvArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (ind == 102) {
            _first.dataArr = _firstBenjinArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (ind == 103) {
            _first.dataArr = _firstYearJineArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }
        
        
       
        
        NSInteger index = _secondSelectedBtn.tag;
        if (index == 200) {
            _second.dataArr = _secondDataArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
        }else if (index == 201) {
            _second.dataArr = _secondLiLvArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
            
        }else if (index == 202) {
            _second.dataArr = _secondbenjinArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
        }

        
        
    }
}

- (void)secondButtonClickAction:(UIButton *)button {
    NSInteger index = button.tag;
    if (_isStartAnalyze) {
        
        if (_secondSelectedBtn == button) {
            return;
        }
        [_second markViewDisappear];
        button.selected = YES;
        _secondSelectedBtn.selected = NO;
        _secondSelectedBtn = button;
        
        if (index == 200) {
            _second.dataArr = _secondDataArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
        }else if (index == 201) {
            _second.dataArr = _secondLiLvArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
            
        }else if (index == 202) {
            _second.dataArr = _secondbenjinArr;
            _second.type = 3;
            [_second setNeedsDisplay];
            
        }
    }
}

- (void)firstButtonClickAction:(UIButton *)button {
    NSInteger index = button.tag;
  
    if (_isStartAnalyze) {
        if (_selectedBtn == button) {
            return;
        }
        [_first markViewDisappear];

        button.selected = YES;
        _selectedBtn.selected = NO;
        _selectedBtn = button;
        
        if (index == 100) {
            _first.dataArr = _firstDataArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (index == 101) {
            _first.dataArr = _firstLilvArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (index == 102) {
            _first.dataArr = _firstBenjinArr;
            _first.type = 3;
            [_first setNeedsDisplay];
            
        }else if (index == 103) {
            _first.dataArr = _firstYearJineArr;
            _first.type = 5;
            [_first setNeedsDisplay];
            
        }
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstDataArr = [[NSMutableArray alloc] init];
    _secondDataArr = [[NSMutableArray alloc] init];
    _firstLilvArr = [[NSMutableArray alloc] init];//月利息
   _secondLiLvArr = [[NSMutableArray alloc] init];//月累计利息
   _firstBenjinArr = [[NSMutableArray alloc] init];//月本金
    _secondbenjinArr = [[NSMutableArray alloc] init];//月累计本金
    _firstYearJineArr = [[NSMutableArray alloc] init];//年数与总金
    
    NSArray *titleArr = @[@"月还款额",@"月付利息",@"月付本金",@"贷款n年还本息数"];
    CGFloat width = [UIScreen mainScreen].bounds.size.width/4.0;
    for (int i = 0; i < 4; i ++) {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake( width * i, 160, width, 24);
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTintColor:UIColorFromRGB(0x565568)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(firstButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 100 + i;
        if (i == 0) {
            button.selected = YES;
            _selectedBtn = button;
        }
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    _first = [[MCCurveView alloc] initWithFrame:CGRectMake(15, 200, [UIScreen mainScreen].bounds.size.width - 30, 191)];
    _first.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_first];
   
    
    NSArray *titles = @[@"累计还款",@"累计利息",@"累计本金"];
    for (int i = 0; i < 3; i ++) {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake( width * i, [UIScreen mainScreen].bounds.size.height - 200 - 15 - 35, width, 24);
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTintColor:UIColorFromRGB(0x565568)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(secondButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 200 + i;
        if (i == 0) {
            button.selected = YES;
            _secondSelectedBtn = button;
        }
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    _second = [[MCCurveView alloc] initWithFrame:CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 200 - 15 , [UIScreen mainScreen].bounds.size.width - 30,200)];
    _second.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_second];
    
    
    UIButton *btn =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake( 0, 22, 60, 24);
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTintColor:UIColorFromRGB(0x565568)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"下一页" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_jine resignFirstResponder];
    [_lilv resignFirstResponder];
    [_nianshu resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
