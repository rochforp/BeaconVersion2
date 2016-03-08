//
//  AppDelegate.swift
//  Protoype for D
//
//  Robert Rochford 2015
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, ESTEddystoneManagerDelegate {

    var window: UIWindow?
    
    //Hold's the beacon manager and instantiate's it
    let beaconManager = ESTBeaconManager()
    
    let notification = UILocalNotification()
    
    let eddystoneManager = ESTEddystoneManager()
    
    let pumpBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "D8D3B0B4-E21A-11E5-9730-9A79F06E9478")!, major: 998, minor: 1057, identifier: "pumpBeaconRegion")
    
    let entranceBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "D8D3B0B4-E21A-11E5-9730-9A79F06E9478")!, major: 998, minor: 1026, identifier: "entranceBeaconRegion")
    
    let viewController = ViewController()
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ESTConfig.setupAppID("beaconversion2", andAppToken: "8eaf3822f57dc4cdcc347658517e1ff0")
        ESTConfig.enableMonitoringAnalytics(true)
        ESTConfig.enableGPSPositioningForAnalytics(true)
        ESTConfig.enableRangingAnalytics(true)
        
        //Sets the beacon manager's delegate
        self.beaconManager.delegate = self
        
        //Sets the eddystone delegate
        self.eddystoneManager.delegate = self
        
        //Request for ALWAYS authorization that occurs ever time the app launches.  It is only prompted the first time but the app makes the request every time it is launched.
        self.beaconManager.requestAlwaysAuthorization()
        
        startPumpMonitor(true)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil))

        // Override point for customization after application launch.
        return true
    }
    

    
    func eddystoneManager(manager: ESTEddystoneManager!, didDiscoverEddystones eddystones: [AnyObject]!, withFilter eddystoneFilter: ESTEddystoneFilter!) {
        
        let urlFilter = ESTEddystoneFilterURL(URL: "http://my.restaurant.com/new-york-city")
        self.eddystoneManager.startEddystoneDiscoveryWithFilter(urlFilter)
    }
    
    
    func beaconManager(manager: AnyObject!, didEnterRegion currentRegion: CLBeaconRegion!) {
        
        //let lastRegion = currentRegion
        
        if currentRegion == pumpBeaconRegion{
        
            NSLog("didEnterPumpRegion, will record a pump visit")
            
            self.notification.alertBody =
                "Welcome to the Dell Experince " +
            "Please unlock your device to see special offers from this Dell Demo!"
            self.notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            startStoreMonitor(true)
        }
        /*
        else if currentRegion == entranceBeaconRegion && lastRegion == pumpBeaconRegion{
            NSLog("They went from pump to the store")
            self.notification.alertBody = ("You came in from the pump! Have a million dollars!")
            self.notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
            */
        else if currentRegion == entranceBeaconRegion {
            NSLog("didEnterMapcoStoreRegion, will record a store entrance")
            self.notification.alertBody =
                "You came from the pump!  Swipe to unlock to access your free item!"
            self.notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            //let viewController:ViewController = window!.rootViewController as! ViewController
            //viewController.showEntrancePromo()
            stopStoreMonitor(true)
        }
    }
    
    func beaconManager(manager: AnyObject!, didExitRegion currentRegion: CLBeaconRegion!) {
        
        if currentRegion == pumpBeaconRegion{
        NSLog("didExitPumpRegion, will automatically record a pump exit")
        self.notification.alertBody = "You have left The Dell Demo " +
        "Thanks for visiting!"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        else if currentRegion == entranceBeaconRegion{
            //this is where we can call to store customer entrance in a database
            NSLog("didExitStoreRegion, will automatically record a store exit")
        }
        //else if lastRegion == entranceBeaconRegion && currentRegion == pumpBeaconRegion{
        //    NSLog("didExitStore and Pump. Came from the store back to the pump")
        //    self.notification.alertBody = "Thanks for coming inside the store today from the pump!"
        //    self.notification.soundName = UILocalNotificationDefaultSoundName
        //    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        //}
        
        stopStoreMonitor(true)
    }
    
    func startPumpMonitor(_: Bool) -> Bool{
        
        if true{
            self.beaconManager.startMonitoringForRegion(pumpBeaconRegion)
        }
        return false
    }
    
    func startStoreMonitor(_: Bool) -> Bool{
        
        if true{
            self.beaconManager.startMonitoringForRegion(entranceBeaconRegion)
        }
        return false
    }
    
    func stopStoreMonitor(_: Bool) -> Bool{
        if true{
            self.beaconManager.stopMonitoringForRegion(entranceBeaconRegion)
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.MapcoExpress.AirportApp" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    

}


