import UIKit
import Alamofire

class HomeViewController : UICollectionViewController {
    
    private let endpoint = "https://api.snapcard.io/v2"
    
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
        let url = "\(endpoint)/wallets?timestamp=\(Utilities.createTimestamp())"
        Alamofire.request(.POST, url,
            parameters: ["name":name],
            encoding: .JSON,
            headers: Utilities.getHeaders(url, body: body))
            .responseJSON { response in
                if let apiResponse = response.result.value as? [String : AnyObject] {
                    if apiResponse["exceptionId"] as? String == nil {
                        let newWallet = apiResponse
                        self.wallets.insert(newWallet, atIndex: 0)
                        self.collectionView!.insertItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
                        return
                    }
                    self.onApiError(apiResponse)
                }
        }
    }
    
    private func loadWallets() {
        let url = "\(endpoint)/wallets?timestamp=\(Utilities.createTimestamp())&limit=100&offset=0"
        Alamofire.request(.GET, url,
            parameters: nil,
            encoding: .JSON,
            headers: Utilities.getHeaders(url, body: ""))
            .responseJSON { response -> Void in
                if let apiResponse = response.result.value as? [String : AnyObject] {
                    if apiResponse["exceptionId"] as? String == nil {
                        let data = apiResponse["data"] as! [[String : AnyObject]]
                        self.wallets = data
                        self.collectionView!.reloadData()
                        return
                    }
                    self.onApiError(apiResponse)
                }
        }
    }
    
    private func onApiError(apiResponse : [String : AnyObject]) {
        let alert = UIAlertController(title: NSLocalizedString("An error has occurred", comment: ""), message: apiResponse["message"] as? String, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Cancel) { action in
            alert.dismissViewControllerAnimated(true) { () in }
        })
        self.presentViewController(alert, animated: true) { () in }
        print(apiResponse)
    }
}