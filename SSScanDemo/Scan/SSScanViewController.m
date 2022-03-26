//
//  SSScanViewController.m
//  SSScanDemo
//
//  Created by Sseakom on 2022/3/25.
//

#import "SSScanViewController.h"
#import "SGQRCode.h"
#import <AVFoundation/AVFoundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SSScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic,strong) UIImageView *bgImageView;
@property(nonatomic,strong) UIButton *flashlightBtn;

@property(nonatomic,strong) SGQRCodeObtain *obtain;
@property(nonatomic,assign) BOOL isSelectedFlashlightBtn;

@end

@implementation SSScanViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self authorize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeFlashlightBtn];
    [self.obtain stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.obtain = [SGQRCodeObtain QRCodeObtain];
    [self setupQRCodeScan];
    [self initViews];
}

-(void)initViews{
    self.bgImageView = ({
        UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height/2 - 150, 200, 200)];
        view.image = [UIImage imageNamed:@"scan_border_bg"];
        view;
    });
    [self.view addSubview:self.bgImageView];
    
    self.flashlightBtn = ({
        UIButton *view = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height - 150, 80, 80)];
        [view setTitle:@"打开灯光" forState:UIControlStateNormal];
        [view setTitle:@"关闭灯光" forState:UIControlStateSelected];
        [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont systemFontOfSize:12];
        [view setImage:[UIImage imageNamed:@"ic_light"] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view addSubview:self.flashlightBtn];
    
}

-(void)startRunning{
    [self.obtain startRunningWithBefore:nil completion:nil];
}

//授权
- (void)authorize{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
                case AVAuthorizationStatusNotDetermined: {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                        if (granted) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [self setupQRCodeScan];
                                [self startRunning];
                            });
                            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                        } else {
                            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                        }
                    }];
                    break;
                }
                case AVAuthorizationStatusAuthorized: {
                    [self startRunning];
                    break;
                }
                case AVAuthorizationStatusDenied: {
                    UIAlertController *alertC = [self showAlertWithTitle:@"无法获取权限" msg:@"请在手机的 “设置-隐私-相机”选项中，允许访问你的相机权限。" leftTitle:nil rightTitle:@"好的" leftAction:nil rightAction:^{
                        
                    }];
                    [self presentViewController:alertC animated:YES completion:nil];
                    break;
                }
                case AVAuthorizationStatusRestricted: {
                    NSLog(@"因为系统原因, 无法访问相册");
                    break;
                }
                
            default:
                break;
        }
        return;
    }
        
    UIAlertController *alertC = [self showAlertWithTitle:@"温馨提示" msg:@"未检测到您的摄像头" leftTitle:nil rightTitle:@"确定" leftAction:nil rightAction:^{
        
    }];
    
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)setupQRCodeScan {
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    [self.obtain establishQRCodeObtainScanWithController:self configure:configure];
    
    __weak typeof(self) weakSelf = self;
    [self.obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        [weakSelf dealScanResult:result];
    }];
}

-(void)dealScanResult:(NSString *)result{
    [self.obtain stopRunning];
    NSLog(@"%@",result);
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title msg:(NSString *)msg leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle leftAction:(void (^)(void))leftAction rightAction:(void (^)(void))rightAction{
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x191A1C) range:NSMakeRange(0, title.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    
    NSMutableAttributedString *attrMsg = [[NSMutableAttributedString alloc] initWithString:msg];
    [attrMsg addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xA6A6AD) range:NSMakeRange(0, msg.length)];
    [attrMsg addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, msg.length)];
     
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertcontroller setValue:alertControllerStr forKey:@"attributedTitle"];
    [alertcontroller setValue:attrMsg forKey:@"attributedMessage"];
     
    if (leftAction) {
        UIAlertAction *left = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            leftAction();
        }];
        [left setValue:UIColorFromRGB(0x333338) forKey:@"titleTextColor"];
        [alertcontroller addAction:left];
    }
    
    if (rightAction) {
        UIAlertAction *right = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            rightAction();
        }];
        [right setValue:UIColorFromRGB(0xD7000F) forKey:@"titleTextColor"];
        [alertcontroller addAction:right];
    }
    return alertcontroller;
}

#pragma mark - - - 闪光灯按钮
- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [self.obtain openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
        
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.obtain closeFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        //[self.flashlightBtn removeFromSuperview];
    });
}

#pragma mark - 聚焦和曝光
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    [self.obtain cameraDidSelected:point];
}

- (void)dealloc {
    NSLog(@"dealloc");
}


@end
