#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Gecko 内部の AppShellDelegate を宣言
@interface AppShellDelegate : NSObject <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation NSObject (GeckoHijacker)

// アプリ起動時に自動的に実行される
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"AppShellDelegate");
        if (class) {
            NSLog(@"[Floorp] AppShellDelegate found! Initializing swizzle...");
            
            SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
            SEL swizzledSelector = @selector(floorp_application:didFinishLaunchingWithOptions:);

            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);

            // メソッドを動的に追加して入れ替える
            class_addMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            class_replaceMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            
            NSLog(@"[Floorp] Swizzle complete. Gecko is now under our control.");
        } else {
            NSLog(@"[Floorp] ERROR: Could not find AppShellDelegate. It might be loaded later.");
        }
    });
}

// 私たちが定義した新しい起動処理
- (BOOL)floorp_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1. Gecko 本来の処理を実行（名前を変えて保存した元のメソッドを呼ぶ）
    // 注意: class_replaceMethod により、この self は AppShellDelegate のインスタンスです
    BOOL result = YES;
    SEL originalSelector = @selector(floorp_application:didFinishLaunchingWithOptions:);
    if ([self respondsToSelector:originalSelector]) {
        // 元のメソッドを呼び出す（Gecko のログ出力など）
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        result = (BOOL)[self performSelector:originalSelector withObject:application withObject:launchOptions];
        #pragma clang diagnostic pop
    }
    
    NSLog(@"[Floorp] Gecko Master initialization complete. Injecting Floorp UI...");

    // 2. メインスレッドで UI を構築
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        // Swift の BrowserViewController を取得
        Class vcClass = NSClassFromString(@"BrowserViewController");
        if (vcClass) {
            UIViewController *rootVC = [[vcClass alloc] init];
            window.rootViewController = rootVC;
            window.backgroundColor = [UIColor whiteColor];
            [window makeKeyAndVisible];
            
            // AppShellDelegate のプロパティに保持させてメモリ解放を防ぐ
            if ([self respondsToSelector:@selector(setWindow:)]) {
                [self performSelector:@selector(setWindow:) withObject:window];
            }
            NSLog(@"[Floorp] SUCCESS: BrowserViewController injected into the window!");
        } else {
            NSLog(@"[Floorp] FATAL ERROR: BrowserViewController class not found. Check target membership!");
        }
    });

    return result;
}

@end
