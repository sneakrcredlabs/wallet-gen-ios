# Wallet Generator for iOS
Easily create and manage new bitcoin wallets

- [Running the app](#running-the-app)
- [About the code](#about-the-code)
- [Third Party Libraries](#third-party-libraries)


## Running the app

- Clone the repo
    * `$ git clone https://github.com/snapcard/wallet-gen-ios.git`  
- Download [Xcode](https://developer.apple.com/xcode/downloads/)
- Install CocoaPods & download dependencies
    * `$ gem install cocoapods`  
    * `$ cd wallet-gen-ios/WalletGenApp/`  
    * `$ pod update`  
- Open `wallet-gen-ios/WalletGenApp/WalletGenApp.xcworkspace`
    * __NOTE__ ensure that you open the file ending in `*.xcworkspace` not the `*.xcodeproj` file  
- In the `Info.plist` file update the __SNAPCARD_API_KEY__ and __SNAPCARD_SECRET__ with your credentials. Api keys can be generated [here](https://www.snapcard.io/wallet/settings#!/api)

![](https://s3.amazonaws.com/uploads.hipchat.com/100175/1171589/aUPD2Y560qoVNKh/update-plist.png)


## About the code

- [HomeViewController.swift](#homeviewcontrollerswift)
- [Authentication](#authentication)
- [Creating a wallet](#creating-a-wallet)
- [Displaying wallets](#displaying-wallets)

![](https://s3.amazonaws.com/uploads.hipchat.com/100175/1171589/ggI1mYA1m9vEIWs/wallet-gen.png)


#### HomeViewController.swift

  - This app is essentially one file, [HomeViewController](https://github.com/snapcard/wallet-gen-ios/blob/develop/WalletGenApp/WalletGenApp/HomeViewController.swift), it handles the creation of new wallets, display of existing, and provides data for a detail view.


#### Authentication

  - The SNAPCARD Master Wallet Api requires both an api key and a signature in order to perform successful requests. [Api Documentation](http://wallets.docs.snapcard.io/docs/authentication)

  - In this application the calculation of the signature is performed by a method in [Utilities.swift](https://github.com/snapcard/wallet-gen-ios/blob/develop/WalletGenApp/WalletGenApp/Utilities.swift)

    ````swift
    static func getHeaders(url : String, body : String) -> [String : String] {
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            let signature = "\(url)\(body)".hmac(.SHA256, key: dict["SNAPCARD_SECRET"] as! String)
            let apiKey = dict["SNAPCARD_API_KEY"] as! String
            return ["X-Api-Key": apiKey, "X-Api-Signature": signature]
        }
        return [:]
    }
    ````
    [Utilities.swift:9](https://github.com/snapcard/wallet-gen-ios/blob/develop/WalletGenApp/WalletGenApp/Utilities.swift#L9)


#### Creating a wallet

  - All that is required to create a new wallet is a `POST` request to `https://api.snapcard.io/v2/wallets` with a name in the body, you can also include a [callback url](http://wallets.docs.snapcard.io/docs/callbacks)

    ````swift
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
    ````
    [HomeViewController.swift:52](https://github.com/snapcard/wallet-gen-ios/blob/develop/WalletGenApp/WalletGenApp/HomeViewController.swift#L52) - [Api Documentation](http://wallets.docs.snapcard.io/docs/create-child-wallet)


#### Displaying wallets

  - Viewing existing wallets is achieved via a `GET` request to `https://api.snapcard.io/v2/wallets`

    ````swift
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
    ````
    [HomeViewController.swift:72](https://github.com/snapcard/wallet-gen-ios/blob/develop/WalletGenApp/WalletGenApp/HomeViewController.swift#L72) - [Api Documentation](http://wallets.docs.snapcard.io/docs/list-child-wallets)


## Third Party Libraries

- [Alamofire](https://github.com/Alamofire/Alamofire)
