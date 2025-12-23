#import <UIKit/UIKit.h>

@interface FloorpUIBootstrapper : NSObject
@end

@implementation FloorpUIBootstrapper

// アプリがメモリに読み込まれた瞬間に実行される
+ (void)load {
    NSLog(@"[Floorp] Bootstrapper: Ready and waiting for app launch...");
    
    // アプリの起動が完了した（didFinishLaunching 相当）タイミングを監視する
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"[Floorp] App launch notification received! Preparing UI...");
        [self injectFloorpUI];
    }];
}

+ (void)injectFloorpUI {
    // すでに UI が構築されているかチェック
    if ([UIApplication sharedApplication].keyWindow.rootViewController != nil && 
        ([NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]) containsString:@"BrowserViewController"])) {
        return;
    }

    NSLog(@"[Floorp] Injecting BrowserViewController into the main window...");
    
    // 新しい Window を作成
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // Swift の BrowserViewController を探す
    Class vcClass = NSClassFromString(@"floorp.BrowserViewController");
    if (!vcClass) vcClass = NSClassFromString(@"BrowserViewController");
    
    if (vcClass) {
        UIViewController *rootVC = [[vcClass alloc] init];
        window.rootViewController = rootVC;
        window.backgroundColor = [UIColor whiteColor];
        [window makeKeyAndVisible];
        
        // アプリ全体のメイン Window として登録
        [UIApplication sharedApplication].delegate.window = window;
        
        NSLog(@"[Floorp] UI Injection Successful! Enjoy Floorp Mobile.");
    } else {
        NSLog(@"[Floorp] UI Injection FAILED: BrowserViewController class not found.");
    }
}

@end
