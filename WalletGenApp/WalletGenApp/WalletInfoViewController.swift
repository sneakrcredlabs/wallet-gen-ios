import UIKit

class WalletInfoViewController : UICollectionViewController {

    var wallet : [String : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = wallet["name"] as? String
        
        print(wallet)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("coin", forIndexPath: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: { () -> CGFloat in
            switch indexPath.row {
            default:
                return 262
            }
        }())
    }
}