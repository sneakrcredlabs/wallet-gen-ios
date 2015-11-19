import UIKit

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
    
    static func toQrImage(uri : String, height : CGFloat) -> UIImage {
        let qrCodeData = uri.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
        let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator")
        qrCodeFilter!.setValue(qrCodeData, forKey: "inputMessage")
        qrCodeFilter!.setValue("Q", forKey: "inputCorrectionLevel")
        let qrCode = qrCodeFilter!.outputImage
        let qrCodeScaleX = height / qrCode!.extent.size.width
        let qrCodeScaleY = height / qrCode!.extent.size.height
        let adjustedCode = qrCode!.imageByApplyingTransform(CGAffineTransformMakeScale(qrCodeScaleX, qrCodeScaleY))
        return UIImage(CIImage: adjustedCode)
    }
}