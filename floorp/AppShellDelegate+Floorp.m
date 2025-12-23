#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Gecko 内部の AppShellDelegate を宣言
@interface AppShellDelegate : NSObject <UIApplicationDelegate>
@property(strong, nonatomic) UIWindow* window;
@end

// 元の実装を保存するための変数
static BOOL (*original_didFinishLaunching)(id, SEL, UIApplication*, NSDictionary*);

// 注入する新しい起動処理
static BOOL swizzled_didFinishLaunching(id self, SEL _cmd, UIApplication* application, NSDictionary* launchOptions) {
    NSLog(@"[Floorp] Swizzled didFinishLaunching called!");
    
    // 1. Gecko 本来の処理を実行
    BOOL result = YES;
    if (original_didFinishLaunching) {
        result = original_didFinishLaunching(self, _cmd, application, launchOptions);
    }
    
    // 2. 直後に私たちの UI (BrowserViewController) を割り込ませる
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[Floorp] Injecting BrowserViewController...");
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        // Swift クラスを探す
        Class vcClass = NSClassFromString(@"floorp.BrowserViewController");
        if (!vcClass) vcClass = NSClassFromString(@"BrowserViewController");
        
        if (vcClass) {
            UIViewController *rootVC = [[vcClass alloc] init];
            window.rootViewController = rootVC;
            window.backgroundColor = [UIColor whiteColor];
            [window makeKeyAndVisible];
            
            // Gecko 側の管理用 window 変数も更新しておく
            if ([self respondsToSelector:@selector(setWindow:)]) {
                [(AppShellDelegate *)self setWindow:window];
            }
            NSLog(@"[Floorp] UI Injection successful!");
        } else {
            NSLog(@"[Floorp] UI Injection FAILED: BrowserViewController not found.");
        }
    });
    
    return result;
}

// アプリ起動時に自動的に実行される初期化関数
__attribute__((constructor))
static void initialize_floorp_hook() {
    NSLog(@"[Floorp] Hook constructor running...");
    
    // 少し待機してからクラスを探す（フレームワークのロード待ち）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class class = NSClassFromString(@"AppShellDelegate");
        if (class) {
            Method originalMethod = class_getInstanceMethod(class, @selector(application:didFinishLaunchingWithOptions:));
            if (originalMethod) {
                original_didFinishLaunching = (void *)method_getImplementation(originalMethod);
                method_setImplementation(originalMethod, (IMP)swizzled_didFinishLaunching);
                NSLog(@"[Floorp] Successfully hooked AppShellDelegate!");
            }
        } else {
            NSLog(@"[Floorp] Hook failed: AppShellDelegate class not found yet.");
        }
    });
}
