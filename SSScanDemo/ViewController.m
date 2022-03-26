//
//  ViewController.m
//  SSScanDemo
//
//  Created by Sseakom on 2022/3/25.
//

#import "ViewController.h"
#import "SSScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = ({
        UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, 200, 100, 44)];
        [view setTitle:@"Scan" forState:UIControlStateNormal];
        [view setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        view.layer.borderColor = [UIColor grayColor].CGColor;
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1;
        [view addTarget:self action:@selector(pushToScan) forControlEvents:UIControlEventTouchUpInside];
        view.layer.cornerRadius = 4;
        view;
    });
    [self.view addSubview:button];
}

-(void)pushToScan{
    SSScanViewController *vc = [[SSScanViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
