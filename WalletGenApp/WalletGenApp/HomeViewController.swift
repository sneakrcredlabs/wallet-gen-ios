import UIKit
import Alamofire

class HomeViewController : UICollectionViewController {
    
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
        return CGSize(width: self.view.bounds.size.width, height: 60)
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
        let endpoint = "https://api.snapcard.io/v2/wallets"
        let body = "{\"name\":\"\(name)\"}"
        let url = "\(endpoint)?timestamp=\(createTimestamp())"
        Alamofire.request(.POST, url,
            parameters: ["name":name],
            encoding: .JSON,
            headers: getHeaders(url, body: body))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let apiResponse = response.result.value {
                        let newWallet = apiResponse as! [String : AnyObject]
                        self.wallets.append(newWallet)
                        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forRow: self.wallets.count - 1, inSection: 0)])
                    }
                default:
                    print(response)
                }
        }
    }
    
    private func loadWallets() {
        let endpoint = "https://api.snapcard.io/v2/wallets"
        let url = "\(endpoint)?timestamp=\(createTimestamp())"
        Alamofire.request(.GET, url,
            parameters: nil,
            encoding: .JSON,
            headers: getHeaders(url, body: ""))
            .responseJSON { response -> Void in
                switch response.result {
                case .Success:
                    if let apiResponse = response.result.value {
                        let data = apiResponse["data"] as! [[String : AnyObject]]
                        self.wallets = data
                        self.collectionView?.reloadData()
                    }
                default:
                    print(response)
                }
        }
    }
    
    private func createTimestamp() -> String {
        return "\(Int(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    private func getHeaders(url : String, body : String) -> [String : String] {
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            let signature = "\(url)\(body)".hmac(.SHA256, key: dict["SNAPCARD_SECRET"] as! String)
            let apiKey = dict["SNAPCARD_API_KEY"] as! String
            return ["X-Api-Key": apiKey, "X-Api-Signature": signature]
        }
        return [:]
    }
}