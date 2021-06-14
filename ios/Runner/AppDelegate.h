#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface AppDelegate : FlutterAppDelegate
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
@end
