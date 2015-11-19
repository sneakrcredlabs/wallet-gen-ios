import Foundation

class Utilities {
    
    static func createTimestamp() -> String {
        return "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    static func getHeaders(url : String, body : String) -> [String : String] {
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            let signature = "\(url)\(body)".hmac(.SHA256, key: dict["SNAPCARD_SECRET"] as! String)
            let apiKey = dict["SNAPCARD_API_KEY"] as! String
            return ["X-Api-Key": apiKey, "X-Api-Signature": signature]
        }
        return [:]
    }
}