//
//  ViewController.swift
//  Beaconversion2
//
//  Robert Rochford 2015

import UIKit
import AVFoundation

//Ashley's
let BEACON_1_UUID = "D8D3B0B4-E21A-11E5-9730-9A79F06E9478"
let BEACON_1_MAJOR: CLBeaconMajorValue = 1001
let BEACON_1_MINOR: CLBeaconMinorValue = 100

//Seaboard Green
let BEACON_2_UUID = "D8D3B0B4-E21A-11E5-9730-9A79F06E9478"
let BEACON_2_MAJOR: CLBeaconMajorValue = 2002
let BEACON_2_MINOR: CLBeaconMinorValue = 200

//Pump or Hans
let BEACON_3_UUID = "D8D3B0B4-E21A-11E5-9730-9A79F06E9478"
let BEACON_3_MAJOR: CLBeaconMajorValue = 3003
let BEACON_3_MINOR: CLBeaconMinorValue = 300

//Entrance
let BEACON_4_UUID = "D8D3B0B4-E21A-11E5-9730-9A79F06E9478"
let BEACON_4_MAJOR: CLBeaconMajorValue = 4004
let BEACON_4_MINOR: CLBeaconMinorValue = 400

//Break Room
let BEACON_5_UUID = "D8D3B0B4-E21A-11E5-9730-9A79F06E9478"
let BEACON_5_MAJOR: CLBeaconMajorValue = 5005
let BEACON_5_MINOR: CLBeaconMinorValue = 500

var sound = UILocalNotificationDefaultSoundName
var hasAppStarted = false
var audioPlayer = AVAudioPlayer()

func isBeacon(beacon: CLBeacon, withUUID UUIDString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) -> Bool {
    return beacon.proximityUUID.UUIDString == UUIDString && beacon.major.unsignedShortValue == major && beacon.minor.unsignedShortValue == minor
}

class ViewController: UIViewController, ESTBeaconManagerDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var redeemResponse: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var labelBottom: UILabel!
    @IBOutlet weak var barcodeImage: UIImageView!
    
    var counter = 0
    // let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Creates a second instance of a beacon manager which will handle our actions once the app is launched.  This controlls the view after the app launches while the AppDelegate handles pre-launch or background events.
    let beaconManager = ESTBeaconManager()
    

    let beaconRegion1 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_1_UUID)!, major: BEACON_1_MAJOR, minor: BEACON_1_MINOR, identifier: "beaconRegion1")
    let beaconRegion2 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_2_UUID)!, major: BEACON_2_MAJOR, minor: BEACON_2_MINOR, identifier: "beaconRegion2")
    let beaconRegion3 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_3_UUID)!, major: BEACON_3_MAJOR, minor: BEACON_3_MINOR, identifier: "beaconRegion3")
    let beaconRegion4 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_4_UUID)!, major: BEACON_4_MAJOR, minor: BEACON_4_MINOR, identifier: "beaconRegion4")
    let beaconRegion5 = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: BEACON_5_UUID)!, major: BEACON_5_MAJOR, minor: BEACON_5_MINOR, identifier: "beaconRegion5")

    //now we create a second beacon region for the whole office
    let wholeBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "SeaboardOffice")
    
    let notify = UILocalNotification()
    
    var redeemTime = NSDate().timeIntervalSince1970
    var currentTime = NSDate().timeIntervalSince1970
    var timeDifference = NSDate()
    
    
    /*
    func placesNearBeacon(beacon: CLBeacon) -> [String]{
    let beaconKey = "\(beacon.major):\(beacon.minor)"
    if let places = self.placesByBeacons[beaconKey]{
    let sortedPlaces = Array(places).sorted { $0.1 < $1.1 }.map {$0.0}
    return sortedPlaces
    }
    return []
    }
    */
    

    
    // Add the property holding the data.
    // TODO: replace "<major>:<minor>" strings to own beacons
    /*let placesByBeacons = [
    "61045:16636": [
    //Entrance beacon
    "Entrance To Mapco": 10, // read as: it's 50 meters from
    // "Entrance of Mapco" to the beacon with
    // major 6574 and minor 54631
    "Ashley's Snack's": 30,
    "Mint Mapco Coffee": 50
    ],
    //Ashley's Snacks
    "25707:14226": [
    "Entrance To Mapco": 30,
    "Ashley's Snacks": 10,
    "Mint Mapco Coffee": 20
    ],
    //Seaboard Green
    "5257:36182": [
    "Entrance To Mapco": 60,
    "Ashley's Snacks": 40,
    "Mint Mapco Coffee": 10
    ]
    ]
    */
    
    @IBAction func showPromo(sender: AnyObject) {
        
         //self.checkCounter()
        let promoAlert = UIAlertController(title: "Mapco Beacon Promo", message: "Buy One, Get One Free Hot Dogs. " +
            "Take this to the cashier to redeem", preferredStyle: UIAlertControllerStyle.Alert)
       
        promoAlert.addAction(UIAlertAction(title: "Redeem", style: .Cancel, handler: {(action: UIAlertAction) in
    
            //if currentTime - redeemTime > 10 then allow to redeem else don't allow
            
            self.currentTime = NSDate().timeIntervalSince1970
            let timeDiffernce = self.currentTime - self.redeemTime
            let waitTimeToUnlock = timeDiffernce - 60.00
            
            if self.currentTime - self.redeemTime > 60{
                self.counter = 0
            }
            
            if self.counter >= 1 {
                let timer = NSTimer.scheduledTimerWithTimeInterval(15, target:self, selector: Selector("clearBarcodeImage"), userInfo: nil, repeats: false)
                self.barcodeImage.image = UIImage(named: "noCoupon")
                self.redeemResponse.text = "You have already redeemed this today!"
                NSLog("Time Difference is: " + String(stringInterpolationSegment: timeDiffernce))
                NSLog("Redeemed successfully at " + String(stringInterpolationSegment: self.redeemTime) + ".  Unavailable, please wait " + String(stringInterpolationSegment: waitTimeToUnlock ) + " until zero.")
            }
            else {
                let timer = NSTimer.scheduledTimerWithTimeInterval(15, target:self, selector: Selector("clearBarcodeImage"), userInfo: nil, repeats: false)
                self.showEntrancePromo()
                self.counter++
                self.barcodeImage.image = UIImage(named: "realBarcode")
            NSLog("Successfully redeemed promo at currentTime" + String(stringInterpolationSegment: self.currentTime))}}))
        
        promoAlert.addAction(UIAlertAction(title: "Not Now", style: .Default, handler: {(action: UIAlertAction) in
            print("Handle Cancel loAgic here")}))
        
        self.presentViewController(promoAlert, animated: true, completion: nil)
        NSLog("Has attempted to redeem " + String(counter) + " today.")
    }
    
    //This actually is being called when walking from pump to entrance! It just disappears quickly.
    func showEntrancePromo(){
        
        let currentTimestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        self.redeemResponse.font = UIFont(name: "Georgia-BoldItalic", size: 16)
        self.redeemResponse.textColor = UIColor.redColor()
        self.redeemResponse.text = "Redeemed: " + currentTimestamp
        
        redeemTime = NSDate().timeIntervalSince1970
        NSLog("Redeemed at " + String(stringInterpolationSegment: redeemTime))
        
    }
    
    func clearBarcodeImage (){
        //ideally this would be set from a database of promo barcodes...
        self.barcodeImage.image = nil
    }

    func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        if let nearestBeacon = beacons.first as? CLBeacon{
            if isBeacon(nearestBeacon, withUUID: BEACON_1_UUID, major: BEACON_1_MAJOR, minor: BEACON_1_MINOR) {
                // beacon #1
                self.label.text = "You're near Ashley's Snacks"
                self.imageView.image = UIImage(named: "hotdog")
                self.button1.enabled = false
                self.button1.setTitle(" ", forState: UIControlState.Normal)
                self.labelBottom.text = "Try an all beef hot dog today! Located over by the fountain drinks."
                self.barcodeImage.image = nil
            }
            else if isBeacon(nearestBeacon, withUUID: BEACON_2_UUID, major: BEACON_2_MAJOR, minor: BEACON_2_MINOR) {
                // beacon #2
                self.label.text = "Try an ice cold Coca-Cola!"
                self.imageView.image = UIImage(named: "coke")
                self.button1.enabled = false
                self.button1.setTitle(" ", forState: UIControlState.Normal)
                self.labelBottom.text = "Two-for-one today on all coke products!"
                self.barcodeImage.image = nil
            }
            else if isBeacon(nearestBeacon, withUUID: BEACON_3_UUID, major: BEACON_3_MAJOR, minor: BEACON_3_MINOR) {
                // beacon #3
                self.label.adjustsFontSizeToFitWidth = true
                self.label.highlighted = true
                self.label.text = "Come inside for a exclusive, free item!"
                self.imageView.image = UIImage(named: "pumpPromo")
                self.labelBottom.text = "Thanks for fueling at Mapco! Enter the store to unlock the free promotion!"
                self.button1.enabled = false
                self.button1.setTitle(" ", forState: UIControlState.Normal)
                self.barcodeImage.image = nil
            }
            else if isBeacon(nearestBeacon, withUUID: BEACON_4_UUID, major: BEACON_4_MAJOR, minor: BEACON_4_MINOR) {
                // beacon #4
                self.label.text = "Welcome to Mapco!"
                self.imageView.image = UIImage(named: "mapcoLogo")
                self.labelBottom.text = "Thanks for stopping in Mapco Express #12345"
                self.button1.enabled = true
                self.button1.setTitle("Special Beacon App Promo", forState: UIControlState.Normal)
            }
            else if isBeacon(nearestBeacon, withUUID: BEACON_5_UUID, major: BEACON_5_MAJOR, minor: BEACON_5_MINOR) {
                // beacon #5
                self.label.text = "You found the secret spot in this Mapco!"
                self.imageView.image = UIImage(named: "mapcoBucket")
                //self.redeemResponse.text = " "
                self.button1.enabled = false
                self.button1.setTitle(" ", forState: UIControlState.Normal)
                self.labelBottom.text = "Shake the magic Mapco bucket to see what comes out!"
                self.barcodeImage.image = nil
                
            }
            
        } else {
            // no beacons found
            self.label.text = "No beacons found in range."
            self.imageView.image = UIImage(named: "MapcoSquareLogo")
            self.redeemResponse.text = " "
            self.labelBottom.text = "Stop by any Mapco Express for exclusive, location-based discounts."
            self.button1.enabled = false
            self.barcodeImage.image = nil
        }
        //let places = placesNearBeacon(nearestBeacon)
        //TODO: this is where we update the UI with a picture, text or whatever
        //println(places)
        //TODO: remove after implementing the UI
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Applause", ofType: "wav")!)
        var error:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
        } catch var error1 as NSError {
            error = error1
            //audioPlayer = nil
        }
        
        //set the beacon manager's delegate to self
        self.beaconManager.delegate = self
        self.beaconManager.returnAllRangedBeaconsAtOnce = true
        
        //need to request this autorization for every beacon manager
        self.beaconManager.requestAlwaysAuthorization()
        self.button1.enabled = false
        self.button1.setTitle(" ", forState: UIControlState.Normal)
        labelBottom.numberOfLines = 2
        labelBottom.font = UIFont(name: "Arial-Bold", size: 16)
        labelBottom.textColor = UIColor.blackColor()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if(event!.subtype == UIEventSubtype.MotionShake) {
            audioPlayer.play()
            let shakeAlert = UIAlertController(title: "You unlocked a free tank of fuel!", message: "Take this to the register to redeem for free fuel", preferredStyle: UIAlertControllerStyle.Alert)
            
            shakeAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(shakeAlert, animated: true, completion: nil)
        }
    }
    
    
    /*
    func beaconManager(manager: AnyObject!, didEnterRegion region: CLBeaconRegion!) {
        let entrance = CLBeacon()
        if isBeacon(entrance, withUUID: BEACON_4_UUID, major: BEACON_4_MAJOR, minor: BEACON_4_MINOR){
            self.notify.alertBody = "You have entered Mapco Entrance Region. Did this work?"
            self.notify.soundName = sound
            UIApplication.sharedApplication().presentLocalNotificationNow(notify)
        }
    }
    */

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion1)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion2)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion3)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion4)
        self.beaconManager.startRangingBeaconsInRegion(self.beaconRegion5)
        
        //Starts ranging in our defined region titled wholeBeaconRegion above
        self.beaconManager.startRangingBeaconsInRegion(self.wholeBeaconRegion)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion1)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion2)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion3)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion4)
        self.beaconManager.stopRangingBeaconsInRegion(self.beaconRegion5)
        
        //Stops ranging in our defined region
        self.beaconManager.stopRangingBeaconsInRegion(self.wholeBeaconRegion)
    }
    
    func beaconManager(manager: AnyObject!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            NSLog("Location Services authorization denied, can't range")
        }
    }
    
    func beaconManager(manager: AnyObject!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        NSLog("Ranging beacons failed for region '%@'\n\nMake sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Also note that iOS simulator doesn't support Bluetooth.\n\nThe error was: %@", region.identifier, error);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


