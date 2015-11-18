import UIKit

class WalletInfoViewController : UICollectionViewController {

    var wallet : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = wallet["name"] as? String
        
        print(wallet)
    }
}