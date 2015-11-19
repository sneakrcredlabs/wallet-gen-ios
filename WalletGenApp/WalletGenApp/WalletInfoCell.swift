import UIKit

class WalletInfoCell : UICollectionViewCell {
    
    private var wallet : [String : AnyObject]!
    private var digitalCurrencyLabel : UILabel!
    private var qrImage : UIImageView!
    private var walletAddressLabel : UILabel!
    private var linkButton : UIButton!
    private var currency : String!
    private var availableBalance : UILabel!
    private var balance : UILabel!
    private var totalBalance : UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        self.digitalCurrencyLabel = viewWithTag(1) as! UILabel
        self.qrImage = viewWithTag(2) as! UIImageView
        self.walletAddressLabel = viewWithTag(3) as! UILabel
        self.linkButton = viewWithTag(4) as! UIButton
        self.availableBalance = viewWithTag(8) as! UILabel
        self.totalBalance = viewWithTag(10) as! UILabel
    }

    func setWallet(wallet : [String : AnyObject], currency : String) {
        self.wallet = wallet
        self.currency = currency
        let depositAddresses = wallet["depositAddresses"] as! [String : String]
        let availableBalances = wallet["availableBalances"] as! [String : Double]
        let totalBalances = wallet["totalBalances"] as! [String : Double]
        self.digitalCurrencyLabel.text = getLabel(currency)
        self.walletAddressLabel.text = depositAddresses[currency]
        self.availableBalance.text = String(format: "%.8f", arguments: [availableBalances[currency]!])
        self.totalBalance.text = String(format: "%.8f", arguments: [totalBalances[currency]!])
        self.qrImage.image = Utilities.toQrImage("\(getUriPrefix(currency)):\(depositAddresses[currency]!)", height: self.qrImage.frame.size.height)
        self.linkButton.setTitle("\(getLookupUrl(currency))\(depositAddresses[currency]!)", forState: .Normal)
        self.linkButton.addTarget(self, action: Selector("onLookupButtonSelected:"), forControlEvents: .TouchDown)
    }
    
    func onLookupButtonSelected(sender : UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: sender.titleForState(.Normal)!)!)
    }
    
    private func getUriPrefix(currency : String) -> String {
        switch currency {
        case "DOGE":
            return "dogecoin"
        case "LTC":
            return "litecoin"
        default:
            return "bitcoin"
        }
    }
    
    private func getLabel(currency : String) -> String {
        switch currency {
        case "DOGE":
            return "Đ"
        case "LTC":
            return "Ł"
        default:
            return "฿"
        }
    }
    
    private func getLookupUrl(currency : String) -> String {
        switch currency {
        case "DOGE":
            return "https://dogechain.info/address/"
        case "LTC":
            return "https://block-explorer.com/address/"
        default:
            return "https://blockchain.info/address/"
        }
    }
}