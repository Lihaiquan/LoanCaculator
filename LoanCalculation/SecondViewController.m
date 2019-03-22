//
//  SecondViewController.m
//  LoanCalculation
/*
 rate.returnRate =
 rate.refReturnRate = ((daiKuanJine - i * (daiKuanJine/mounth)* daiKuanLilv) - (woDeqianShu + i *yueGongZi)*cunKuanLilv) ;
 */
//  Created by 名策 on 2017/3/30.
//  Copyright © 2017年 名策. All rights reserved.
//

#import "SecondViewController.h"
#import "MCCurveView.h"
#import "MCReturnRate.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SecondViewController ()
@property (nonatomic, assign) BOOL isStartAnalyze;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UIButton *secondSelectedBtn;
@property (weak, nonatomic) IBOutlet UITextField *daiKuanlilv;

@property (weak, nonatomic) IBOutlet UITextField *fangZhangfu;
@property (weak, nonatomic) IBOutlet UITextField *xianYouzijin;
@property (weak, nonatomic) IBOutlet UITextField *nianshu;
@property (weak, nonatomic) IBOutlet UITextField *cunKuanLilv;
@property (weak, nonatomic) IBOutlet UITextField *gongzi;
@property (nonatomic ,strong) MCCurveView *fistCurveView;
@property (nonatomic ,strong) MCCurveView *secondCurveView;

@property (nonatomic, strong) NSMutableArray *firstDataArr;
@property (nonatomic, strong) NSMutableArray *secondDataArr;
@property (nonatomic, strong) NSMutableArray *totalDataArr;
@property (nonatomic, strong) NSMutableArray *lixiDataArr;
@property (nonatomic, strong) NSMutableArray *benXiLilvArr;
@property (nonatomic, strong) NSMutableArray *benjinLilvArr;
@property (weak, nonatomic) IBOutlet UITextField *fangJia;

@end

@implementation SecondViewController

- (void)back:(UIButton *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (void)secondButtonClickAction:(UIButton *)button {
    NSInteger index = button.tag;
    if (_isStartAnalyze) {
        
        if (_secondSelectedBtn == button) {
            return;
        }
        [_secondCurveView markViewDisappear];
        button.selected = YES;
        _secondSelectedBtn.selected = NO;
        _secondSelectedBtn = button;
        
        if (index == 200) {
            _secondCurveView.dataArr = _secondDataArr;
            _secondCurveView.type = 6;
            [_secondCurveView setNeedsDisplay];
            
        }else if (index == 201) {
            
            _secondCurveView.dataArr = _benXiLilvArr;
            _secondCurveView.type = 7;
            [_secondCurveView setNeedsDisplay];
            
        }else if (index == 202) {
            
            _secondCurveView.dataArr = _benjinLilvArr;
            _secondCurveView.type = 8;
            [_secondCurveView setNeedsDisplay];
        }
    }
}

- (double)zengZhangWithMonth:(NSInteger)month wodeZijin:(double)woDeqianShu gongZi:(double)yueGongZi {
    double cunKuanLilv = [_cunKuanLilv.text doubleValue]/100/12;
    double sum = woDeqianShu;
    double wodeQian = woDeqianShu;
    for (int i = 0; i < month; i ++) {
        if (i % 12 == 11) {
            wodeQian = sum;
        }
        sum += wodeQian*cunKuanLilv;
        sum += yueGongZi;
        wodeQian += yueGongZi;
        
    }
    return (sum - woDeqianShu);
    
}

- (double)zengZhangWithMonth:(NSInteger)month {
    double woDeqianShu = [_xianYouzijin.text doubleValue] * 10000;
    double yueGongZi = [_gongzi.text doubleValue] * 10000;
    
    return [self zengZhangWithMonth:month wodeZijin:woDeqianShu gongZi:yueGongZi];
    
}


- (IBAction)analyze:(id)sender {
    
    if ([_nianshu.text isEqualToString:@""]||[_fangZhangfu.text isEqualToString:@""]||[_daiKuanlilv.text isEqualToString:@""]||[_fangJia.text isEqualToString:@""]||[_cunKuanLilv.text isEqualToString:@""]||[_gongzi.text isEqualToString:@""]) {
        _isStartAnalyze = NO;
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先输入正确参数." preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:controller animated:YES completion:nil];
        
    }else {
        _isStartAnalyze = YES;
        [_firstDataArr removeAllObjects];
        [_secondDataArr removeAllObjects];
        [_totalDataArr removeAllObjects];
        [_lixiDataArr removeAllObjects];
        [_benjinLilvArr removeAllObjects];
        [_benXiLilvArr removeAllObjects];
        
        NSInteger mounth = [_nianshu.text integerValue] * 12;
        double fangjiazhangFu = [_fangZhangfu.text doubleValue]/100/12;
        double woDeqianShu = [_xianYouzijin.text doubleValue] * 10000;
        double fangJia = [_fangJia.text doubleValue] * 10000;
        //    double yueGongZi = [_gongzi.text doubleValue] * 10000;
        
        
        for (int i = 0; i < 10 * 12; i ++) {
            
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = fangJia*pow((1+fangjiazhangFu), i);//房价
            rate.refReturnRate =   [self zengZhangWithMonth:i] + woDeqianShu;//需要贷款数
            if(rate.refReturnRate <=0){
                rate.refReturnRate = 0;
            }
            rate.date = i ;
            [_firstDataArr addObject:rate];
            
        }
        
        _fistCurveView.dataArr = _firstDataArr;
        _fistCurveView.type = 4;
        [_fistCurveView setNeedsDisplay];
        
        for (int i = 1; i <= 10 * 12; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            
            MCReturnRate *reteLixi = [[MCReturnRate alloc] init];
            
            double daikuan = (fangJia*pow((1+fangjiazhangFu), i) - ([self zengZhangWithMonth:i] + woDeqianShu));
            if (daikuan <= 0) {
                daikuan = 0;
                reteLixi.returnRate = 0;
                reteLixi.refReturnRate = 0;
                rate.returnRate = fangJia*pow((1+fangjiazhangFu), i);//等额本息
                rate.refReturnRate = fangJia*pow((1+fangjiazhangFu), i);//等额本金
            }else{
                
                rate.returnRate = [self dengEbenxiTotalFund:daikuan month:mounth] + ([self zengZhangWithMonth:i] + woDeqianShu) ;//等额本息
                rate.refReturnRate = [self dengEBenjinDaikuanFund:daikuan month:mounth] + ([self zengZhangWithMonth:i] + woDeqianShu);//等额本金
                
                reteLixi.returnRate = rate.returnRate - fangJia*pow((1+fangjiazhangFu), i);
                reteLixi.refReturnRate = rate.refReturnRate - fangJia*pow((1+fangjiazhangFu), i);
            }
            
            reteLixi.date = i ;
            rate.date = i;
            [_lixiDataArr addObject:reteLixi];
            [_totalDataArr addObject:rate];
        }
        
        NSInteger index = _selectedBtn.tag;
        if (index == 100) {
            _fistCurveView.dataArr = _firstDataArr;
            _fistCurveView.type = 4;
            [_fistCurveView setNeedsDisplay];
            
        }else if (index == 101) {
            _fistCurveView.dataArr = _totalDataArr;
            _fistCurveView.type = 3;
            [_fistCurveView setNeedsDisplay];
        }else if (index == 102) {
            _fistCurveView.dataArr = _lixiDataArr;
            _fistCurveView.type = 3;
            [_fistCurveView setNeedsDisplay];
        }
        
        for (int i =  fangJia /3; i <= woDeqianShu  ; i ++) {
            MCReturnRate *rate = [[MCReturnRate alloc] init];
            rate.returnRate = (([self dengEbenxiTotalFund:(fangJia - i) month:mounth] + i)- ([self zengZhangWithMonth:mounth wodeZijin:(woDeqianShu - i) gongZi:0]));//
            rate.refReturnRate = (([self dengEBenjinDaikuanFund:(fangJia - i) month:mounth] + i) - ([self zengZhangWithMonth:mounth wodeZijin:(woDeqianShu - i) gongZi:0]));;
            rate.date = i;
            [_secondDataArr addObject:rate];
            
            MCReturnRate *rate0 = [[MCReturnRate alloc] init];
            rate0.returnRate = [self dengEbenxiYueQianshu:(fangJia - i) month:mounth];
            rate0.refReturnRate = ([self zengZhangWithMonth:1 wodeZijin:(woDeqianShu - i) gongZi:0]);
            rate0.date = i;
            [_benXiLilvArr addObject:rate0];
            
            
            MCReturnRate *rate1 = [[MCReturnRate alloc] init];
            rate1.returnRate = [self dengEbenJinAvYueQianshu:(fangJia - i) month:mounth];
            rate1.refReturnRate =  [self zengZhangWithMonth:1 wodeZijin:(woDeqianShu - i) gongZi:0];
            rate1.date = i;
            [_benjinLilvArr addObject:rate1];
            
            index = _secondSelectedBtn.tag;
            
            if (index == 200) {
                _secondCurveView.dataArr = _secondDataArr;
                _secondCurveView.type = 6;
                [_secondCurveView setNeedsDisplay];
                
            }else if (index == 201) {
                
                _secondCurveView.dataArr = _benXiLilvArr;
                _secondCurveView.type = 7;
                [_secondCurveView setNeedsDisplay];
                
            }else if (index == 202) {
                
                _secondCurveView.dataArr = _benjinLilvArr;
                _secondCurveView.type = 8;
                [_secondCurveView setNeedsDisplay];
            }

            
            //        double leftGongzi = yueGongZi - [self dengBenxiMeiyueHuankuanWithZijin:(fangJia - i)];
          
        }
        
        
      
    }
    
}

//
- (double)dengBenxiMeiyueHuankuanWithZijin:(double)daiKuanFound {
    NSInteger mounth = [_nianshu.text integerValue] * 12;
    
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
    
    return (daiKuanFound *lilv * pow((1+lilv), mounth))/(pow((1+lilv), mounth) - 1);
}
- (double)dengBenJinMeiyueHuankuanWithZijin:(double)daiKuanFound {
    
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
    NSInteger mounth = [_nianshu.text integerValue] * 12;
    return  (daiKuanFound/mounth) + (daiKuanFound - 0 * (daiKuanFound/mounth))* lilv;
    
}

//计算等额本息的每月还款数，参数是贷款月数和贷款钱数
- (double)dengEbenxiYueQianshu:(double)money month:(NSInteger)month {
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
   return  (money *lilv * pow((1+lilv), month))/(pow((1+lilv), month) - 1);
}

//计算等额本金的平均每月还款 参数是贷款月数和贷款钱数
- (double)dengEbenJinAvYueQianshu:(double)money month:(NSInteger)month{
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
    return ((money/month) + (money/month)* lilv + (money/month) + (money)* lilv)/2.0;

}

//计算等额本息的总的还款额度 参数是贷款月数和贷款钱数
- (double)dengEbenxiTotalFund:(double)money month:(NSInteger)month {
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
    
    return  ( month * ((money *lilv * pow((1+lilv), month))/(pow((1+lilv), month) - 1)));
}

//计算等额本金的总的还款额度 参数是贷款月数和贷款钱数

- (double)dengEBenjinDaikuanFund:(double)money month:(NSInteger)month {
    double lilv = [_daiKuanlilv.text doubleValue]/100/12;
    
    return  (month * ((money/month) + money * lilv) - (money/month) *lilv *(month) * (month - 1)/2.0);
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)firstButtonClickAction:(UIButton *)button {
    NSInteger index = button.tag;
    
    if (_isStartAnalyze) {
        if (_selectedBtn == button) {
            return;
        }
        [_fistCurveView markViewDisappear];
        
        button.selected = YES;
        _selectedBtn.selected = NO;
        _selectedBtn = button;
        
        if (index == 100) {
            _fistCurveView.dataArr = _firstDataArr;
            _fistCurveView.type = 4;
            [_fistCurveView setNeedsDisplay];
            
        }else if (index == 101) {
            _fistCurveView.dataArr = _totalDataArr;
            _fistCurveView.type = 3;
            [_fistCurveView setNeedsDisplay];
            
            
            
        }else if (index == 102) {
            _fistCurveView.dataArr = _lixiDataArr;
            _fistCurveView.type = 3;
            [_fistCurveView setNeedsDisplay];
            
        }else if (index == 103) {
            
            
        }
        
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _totalDataArr = [[NSMutableArray alloc] init];
    _firstDataArr = [[NSMutableArray alloc] init];
    _secondDataArr = [[NSMutableArray alloc] init];
    _lixiDataArr = [[NSMutableArray alloc] init];
    _benXiLilvArr = [[NSMutableArray alloc] init];
    _benjinLilvArr = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.hidden = YES;
    UIButton *btn =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake( 0, 18, 60, 24);
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTintColor:UIColorFromRGB(0x565568)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"X" forState:UIControlStateNormal];
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    NSArray *titleArr = @[@"n月后买入房价",@"n月后买入总款数",@"n月后买入总利息"];
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3;
    for (int i = 0; i < 3; i ++) {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake( width * i, 185, width, 24);
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
    
    _fistCurveView = [[MCCurveView alloc] initWithFrame:CGRectMake(15, 225, [UIScreen mainScreen].bounds.size.width - 30, 191)];
    _fistCurveView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_fistCurveView];
    
    
    NSArray *titles = @[@"首付n总还款额",@"首付n等本息月还款",@"首付n等本金月均还款"];
    width = [UIScreen mainScreen].bounds.size.width/3.0;
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
    _secondCurveView = [[MCCurveView alloc] initWithFrame:CGRectMake(15, [UIScreen mainScreen].bounds.size.height - 200 - 15 , [UIScreen mainScreen].bounds.size.width - 30,200)];
    _secondCurveView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_secondCurveView];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
