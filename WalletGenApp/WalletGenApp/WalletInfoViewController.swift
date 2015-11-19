import UIKit

class WalletInfoViewController : UICollectionViewController {

    var wallet : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = wallet["name"] as? String
     
        print(wallet)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let coinView = collectionView.dequeueReusableCellWithReuseIdentifier("coin", forIndexPath: indexPath) as! WalletInfoCell
        coinView.setWallet(wallet, currency: getCurrencyForIndex(indexPath.row))
        return coinView
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: { () -> CGFloat in
            switch indexPath.row {
            default:
                return 200
            }
        }())
    }
    
    private func getCurrencyForIndex(index : Int) -> String {
        switch index {
        case 0:
            return "BTC"
        case 1:
            return "DOGE"
        default:
            return "LTC"
        }
    }
}