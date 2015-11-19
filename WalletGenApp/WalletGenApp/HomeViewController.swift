import UIKit
import Alamofire

class HomeViewController : UICollectionViewController {
    
    private let endpoint = "https://api.snapcard.io/v2/wallets"
    
    var wallets = [[String : AnyObject]]()
    
    
    // MARK: UICollectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = NSLocalizedString("Wallets", comment: "")
        
        loadWallets()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallets.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let walletCell = collectionView.dequeueReusableCellWithReuseIdentifier("wallet", forIndexPath: indexPath)
        let name = walletCell.viewWithTag(1) as! UILabel
        name.text = wallets[indexPath.row]["name"] as? String
        return walletCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 40)
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let walletInfoView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("info") as! WalletInfoViewController
        walletInfoView.wallet = self.wallets[indexPath.row]
        navigationController?.pushViewController(walletInfoView, animated: true)
    }
    
    
    // MARK: Actions
    
    @IBAction func onAddButtonSelected(sender: AnyObject) {
        createWallet("wallet #\(wallets.count)")
    }
    
    
    // MARK: Networking
    
    private func createWallet(name : String) {
        let body = "{\"name\":\"\(name)\"}"
        let url = "\(endpoint)?timestamp=\(Utilities.createTimestamp())"
        Alamofire.request(.POST, url,
            parameters: ["name":name],
            encoding: .JSON,
            headers: Utilities.getHeaders(url, body: body))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let apiResponse = response.result.value {
                        let newWallet = apiResponse as! [String : AnyObject]
                        self.wallets.insert(newWallet, atIndex: 0)
                        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
                    } else {
                        fallthrough
                    }
                default:
                    print(response)
                }
        }
    }
    
    private func loadWallets() {
        let url = "\(endpoint)?timestamp=\(Utilities.createTimestamp())&limit=100&offset=0"
        Alamofire.request(.GET, url,
            parameters: nil,
            encoding: .JSON,
            headers: Utilities.getHeaders(url, body: ""))
            .responseJSON { response -> Void in
                switch response.result {
                case .Success:
                    if let apiResponse = response.result.value {
                        let data = apiResponse["data"] as! [[String : AnyObject]]
                        self.wallets = data
                        self.collectionView!.reloadData()
                    } else {
                        fallthrough
                    }
                default:
                    print(response)
                }
        }
    }
}