import UIKit
import MapKit
import CoreLocation
import Foundation
import CoreFoundation

class ViewController: UIViewController{
    
    @IBOutlet weak var Map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var start = NSDate()
        var time=0.0
        
        var per_lat=0.0
        var per_long=0.0
        var SOW = 0.0
        var SOG = 0.0
        var COG = 0.0
        var TH = 0.0
        
        var velocity = 0.0
        var deg_lat = 0.0
        var deg_long = 0.0
        
        //SOME OF THE CODE ARE COMMENTED OUT TO RUN THE SIMULATION WITH OUR PLUGGED IN VALUES
        //OUR NETWORK AND RADIO SUBGROUP WASN’T WASN’T ABLE TO WRITE DATA TO THE FILE WE WERE SUPPOSED TO READ FROM AS OF RIGHT NOW
        
        let fullyQualifiedPath = "ftp://192.168.5.1/nmea_transfer/parsedSentences.txt"
        
        let ftpUrl = CFURLCreateWithString(kCFAllocatorDefault, fullyQualifiedPath as CFString, nil)
        let ftpStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, ftpUrl!)
        let myreadstream = ftpStream.takeRetainedValue()
        //set username and password
        let username: CFString = "pi" as CFString
        let password: CFString = "raspberry" as CFString
        let propertyKey_username = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName)
        let propertyKey_password = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword)
        CFReadStreamSetProperty(myreadstream,propertyKey_username, username)
        CFReadStreamSetProperty(myreadstream,propertyKey_password, password)
        
        /*
         
         let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
         let fileURL = documentDirectory!.appendingPathComponent("Text1.txt")
         let mywritestream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, fileURL as CFURL)
         
         
         if (!CFReadStreamOpen(myreadstream as! CFReadStream)) {
         print("read stream can't be opened")
         }
         
         if (!CFWriteStreamOpen(mywritestream)) {
         print("write stream can't be opened")
         }
         
         /*
         var end = NSDate()
         var delta_time: Double = end.timeIntervalSince(start as Date)
         //this is a timer loop that calls the update function
         let file_timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
         (file_timer: Timer) in
         
         start = NSDate()
         end = NSDate()
         delta_time = end.timeIntervalSince(start as Date)
         while(delta_time<5.0){
         //NS timer, config timer to call separate fn every second. update annotation in separate fn
         delta_time = end.timeIntervalSince(start as Date)
         end = NSDate()
         }
         time = time+delta_time
         /*check if the file has been modified*/
         
         if(current_file_date==starting_time){
         print("waiting for file to be read")
         }
         else{
         file_timer.invalidate()
         //issue?
         }
         }
         */
         //save num_bytes read and check if the num_bytes in file has changed if so re read
         var numBytesRead: CFIndex = 0
         
         repeat {
         let bufSize = 4096
         var buffer = [UInt8](repeating: 0, count: bufSize) // define myReadBufferSize as desired
         var numBytesRead = CFReadStreamRead(myreadstream as! CFReadStream, &buffer, 4096)
         
         if( numBytesRead > 0 ) {
         var bytesRead = numBytesRead
         
         //...make sure bytesRead > 0 ...
         
         var bytesWritten = 0
         var totalBytesWritten = 0
         while (bytesWritten < bytesRead) {
         var result: CFIndex
         
         result = CFWriteStreamWrite(mywritestream, buffer, numBytesRead)
         if (result <= 0) {
         print("CFWrite error")
         }
         bytesWritten += result
         }
         totalBytesWritten += bytesWritten
         
         } else if( numBytesRead < 0 ) {
         print("CFRead error")
         }
         } while( numBytesRead > 0 );
         
         
         do {
         
         if (documentDirectory != nil){
         
         let data = try String(contentsOf: fileURL, encoding: .utf8)
         var myStrings = data.components(separatedBy: .whitespacesAndNewlines)
         print(myStrings)
         let size=myStrings.count
         print("Size: ",size)
         var word=0
         while(word<size){
         
         if(myStrings[word]=="Latitude:"){
         word=word+1
         per_lat=Double(myStrings[word])!
         word=word+1
         /*
         if(myStrings[word]=="S"){
         per_lat=per_lat * -1
         }*/
         per_lat = per_lat/100
         print("Latitude: ",per_lat)
         }
         else if(myStrings[word]=="Longitude:"){
         word=word+1
         per_long=Double(myStrings[word])!
         word=word+1
         /*
         if(myStrings[word]=="W"){
         per_long=per_long * -1
         }*/
         per_long = per_long/100
         print("Longitude: ",per_long)
         }
         else if(myStrings[word]=="SOG:"){
         word=word+1
         SOG=Double(myStrings[word])!
         print("SOG: ",SOG)
         }
         else if(myStrings[word]=="SOW:"){
         word=word+1
         SOW=Double(myStrings[word])!
         print("SOW",SOW)
         }
         else if(myStrings[word]=="COG:"){
         word=word+1
         COG=Double(myStrings[word])!
         print("COG",COG)
         }
         else if(myStrings[word]=="TH:"){
         word=word+1
         /*TH=Double(myStrings[word])!*/
         TH=1.0
         print("TH",TH)
         }
         else if(myStrings[word]=="Current:"){
         word=word+1
         velocity=Double(myStrings[word])!
         
         }
         word=word+1
         
         }
         
         var x1 = SOW * sin(TH)
         var y1 = SOW * cos(TH)
         var x2 = SOG * sin(COG)
         var y2 = SOG * cos(COG)
         var x3 = x2-x1
         var y3 = y2-y1
         var set = atan(x3/y3)
         
         
         if(x3 < 0 && y3>0){
         if(set < 0){
         set+=360
         }
         else{
         set+=270
         }
         }
         if(x3>0 && y3>0){
         if(set < 0){
         set+=90
         }
         }
         if(x3 > 0 && y3 < 0 ){
         if(set < 0){
         set+=180
         
         }
         else{
         set+=90
         }
         }
         if(x3 < 0 && y3 < 0){
         if(set < 0){
         set+=270
         }
         else{
         set+=180
         }
         
         }
         
         deg_long = set
         deg_lat = set
         //current direction calculations
         //set deg_lat and deg+long to whatever current direction is
         if(velocity==0.0){
         velocity = sqrt((x3*x3)+(y3*y3))
         }
         
         }
         } catch {
         print("error: ", error)
         }
         
         print("Velocity: ",velocity)*/
        
        //THESE ARE THE VALUES WE PLUGGED IN TO GET THE SIMULATION TO RUN DUE TO THE TRANSFER OF DATA //FILE’S PROBLEM
        
        per_lat=35.181209074332926
        per_long=120.39620416248646
        
        SOW = 1.0
        SOG = 1.0
        COG = 271.2
        TH = 1.0
        
        velocity = 20.0
        deg_lat = 1.0
        deg_long = 1.0
        per_lat=35.211135
        per_long=120.507588
        
        SOW = 1.0
        SOG = 1.0
        COG = 271.2
        TH = 1.0
        
        velocity = 20.0
        deg_lat = 1.0
        deg_long = 1.0
        
        //END OF INPUTTED VALUES
        
        //creating variables for drift calculations
        let deg_lat_per_nm: Double = 1/60
        let cos_deg_lat=cos(deg_lat)
        //calculates degree of longitude per nm
        let p1: Double = 111412.84
        let p2: Double = -93.5
        let p3: Double = 0.118
        
        let longlen = (p1*cos(deg_lat))+(p2*cos(3*deg_lat))+(p3*cos(5*deg_lat))
        let longfeet = (longlen * (3.280833333))
        let longsm = longfeet/5280
        let longnmr: Double = perRound(num: longsm/1.15077945)
        let deg_long_per_nm = 1/longnmr
        let cos_deg_long=cos(deg_long)
        
        
        var per_location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(per_lat, per_long)
        var delta_latitude: Double = 5.0
        var delta_longitude: Double = 5.0
        
        print("Location: ",per_location)
        
        
        //setting map and creating first annotation for person
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: delta_latitude, longitudeDelta: delta_longitude)
        var region: MKCoordinateRegion = MKCoordinateRegion(center: per_location, span: span)
        Map.setRegion(region, animated: true)
        var per_annotation = MKPointAnnotation()
        
        per_annotation.coordinate=per_location
        
        Map.addAnnotation(per_annotation)
        
        var cir_coor:CLLocationCoordinate2D = per_location
        var delta_radius:Double = 0.0
        var radius = 5000.0
        var circle = MKCircle(center: cir_coor, radius: radius)
        self.Map.addOverlay(circle)
        
        
        //updates annotation each second
        start = NSDate()
        var end = NSDate()
        var delta_time = end.timeIntervalSince(start as Date)
        //this is a timer loop that calls the update function
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            (timer: Timer) in
            
            start = NSDate()
            end = NSDate()
            delta_time = end.timeIntervalSince(start as Date)
            while(delta_time<1.0){
                //NS timer, config timer to call separate fn every second. update annotation in separate fn
                delta_time = end.timeIntervalSince(start as Date)
                end = NSDate()
            }
            time = time+delta_time
            
            //need to alter some vars inside this loop to make different annotations......
            //maybe add if statement that checks if no parameters have changed -> dont update..
            
            
            delta_radius=self.update(Longitude: per_long ,Latitude:per_lat,time: time, velocity: velocity, deg_lat_per_nm: deg_lat_per_nm, cos_deg_lat: cos_deg_lat, deg_long_per_nm: deg_long_per_nm, cos_deg_long:cos_deg_long,annotation: per_annotation)
            self.Map.removeOverlay(circle)
            radius = radius+(delta_radius*(1/deg_long_per_nm)*180)
            print(circle.radius)
            circle = MKCircle(center: cir_coor, radius: radius)
            self.Map.addOverlay(circle)
            let bufSize = 4096
            var buffer = [UInt8](repeating: 0, count: bufSize)
            var new_numBytesRead = CFReadStreamRead(myreadstream as! CFReadStream, &buffer, 4096)
            print(new_numBytesRead)
            if(new_numBytesRead>0){
                print("\n\n\n\n\n\n REREAD\n\n\n\n\n")
            }
            
        }
        
    }
    
    
    
    func update(Longitude: Double, Latitude: Double, time: Double, velocity: Double, deg_lat_per_nm: Double, cos_deg_lat: Double, deg_long_per_nm: Double, cos_deg_long: Double,annotation: MKPointAnnotation)->Double{
        
        //***nothing is changing because the parameters passed into this function are not changing**//
        var delta_latitude = time*(velocity/3600)*deg_lat_per_nm*cos_deg_lat
        var delta_longitude = time*(velocity/3600)*deg_long_per_nm*cos_deg_long
        var delta_radius=sqrt((delta_latitude*delta_latitude)+(delta_longitude*delta_longitude))
        
        var Long = Longitude + delta_longitude //must have separate fn for returning viewdload
        var Lat = Latitude + delta_latitude
        var location = CLLocationCoordinate2DMake(Lat, Long)
        print(location)
        
        
        annotation.coordinate=location
        var str_lat = (String)(Lat)
        var str_long = (String)(Long)
        var str_loc="PERSON: "+str_lat+",\r\n"+str_long
        annotation.title = str_loc
        
        Map.addAnnotation(annotation)
        print(annotation.coordinate)
        
        return delta_radius
    }
    
    func perRound(num: Double)->Double{
        let precision = 2;
        let result1 = num * Double(truncating: pow(10,precision) as NSNumber)
        let result2=round(result1)
        let result3=result2/Double(truncating: pow(10,precision) as NSNumber)
        return result3
    }
    
    func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    // Do any additional setup after loading the view, typically from a nib.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.clear.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.red.withAlphaComponent(0.1)
        return renderer
        
    }
    
}
