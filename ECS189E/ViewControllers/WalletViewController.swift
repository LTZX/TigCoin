//
//  WalletViewController.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 10/26/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

class WalletViewController: UIViewController {
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var userNameField: UITextField! // name keyboard
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var greeting: UILabel!
    
    @IBOutlet var functionView: UIView!
    @IBOutlet var accountView: UIView!
    @IBOutlet var historyView: UIView!
    
    @IBOutlet weak var pages: UIScrollView!
    @IBOutlet weak var pageControl: UISegmentedControl!
    
    @IBOutlet weak var listOfAccounts: UICollectionView!
    @IBOutlet weak var listOfHistory: UITableView!
    @IBOutlet weak var listOfFunctions: UICollectionView!
    

    @IBOutlet weak var accountViewCover: UIButton!
    @IBOutlet weak var historyViewCover: UILabel!
    
    @IBOutlet weak var newAccountView: UIView!
    @IBOutlet weak var newAccountNameField: UITextField!
    @IBOutlet weak var newAccountButton: UIButton!
    
    
    var wallet = Wallet()
    var phoneNumberInFormat = String()
    var pagesFrame = CGRect()
    var sms = false
    var selectedAccountIndex = 0
    var functions = ["Deposit", "Withdraw", "Transfer"]
    var selectedTransType = TransType.unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        pagesFrame = pages.frame
        if sms { welcomeMessage.text = "Welcome!" } else { welcomeMessage.text = "Welcome Back!" }
        welcomeMessage.alpha = 1
//        dataInit(random: false, first: true)
        dataInit(random: true, first: true)
    }
    
    func dataInit(random: Bool, first: Bool) {
        // Without Api
        self.wallet = Wallet.init(data: [:], ifGenerateAccounts: random)
        if first {
            self.viewInit()
        } else {
            self.viewUpdate()
        }
//        Api.user(){ response, error in
//            guard let response = response, error == nil else {
//                print("Wrong")
//                return
//            }
//            self.wallet = Wallet.init(data: response, ifGenerateAccounts: random)
//            if first {
//                self.viewInit()
//            } else {
//                self.viewUpdate()
//            }
//            if random {
//                self.saveAccountsToServer()
//            }
//        }
    }
    
    func viewInit() {
        setupGreeting()
        
        addSubViewToScroll(newView: functionView)
        addSubViewToScroll(newView: accountView)
        addSubViewToScroll(newView: historyView)
        
        let numOfPages = pages.subviews.count
        pages.contentSize = CGSize.init(width: pagesFrame.width * CGFloat(numOfPages), height: pagesFrame.height)
        pages.contentOffset.x = pagesFrame.width
        
        listOfAccounts.contentInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 10, right: 10)
        listOfAccounts.layoutIfNeeded()
        accountViewCover.layer.cornerRadius = accountViewCover.frame.height / 2
        
        newAccountView.layer.cornerRadius = 10
        newAccountView.layer.shadowOpacity = 0.7
        newAccountView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        newAccountView.alpha = 0
        newAccountButton.layer.cornerRadius = newAccountButton.frame.height / 2
        
        viewUpdate()
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .beginFromCurrentState, animations: {
            self.welcomeMessage.alpha = 0
        }, completion: nil)
    }
    
    func addSubViewToScroll(newView: UIView) {
        let index = pages.subviews.count
        newView.frame.size = CGSize.init(width: pagesFrame.width - 20, height: pagesFrame.height - 20)
        newView.frame.origin.x = CGFloat(index) * pagesFrame.width + 10
        newView.frame.origin.y = 10
        
        pages.addSubview(newView)
    }
    
    func setupGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour > 5 && hour <= 12 {
            greeting.text = "Good morning, "
        } else if hour > 12 && hour <= 17 {
            greeting.text = "Good afternoon, "
        } else {
            greeting.text = "Good evening, "
        }
        if wallet.userName != "" {
            userNameField.text = wallet.userName
        } else {
            setFieldToNumber()
        }
    }
    
    func saveAccountsToServer() {
        Api.setAccounts(accounts: wallet.accounts) { (response, error) in
            guard let response = response, error == nil else {
                print(error?.message ?? "Unknow error")
                return
            }
            print(response)
        }
    }
    
    func viewUpdate(){
        listOfAccounts.reloadData()
        listOfHistory.reloadData()
        totalAmountLabel.text = "Your Total Amount: " + Format.money(input: wallet.totalAmount, withMark: false)
    }
    
    func setFieldToNumber() {
        let phoneNumber =  String(wallet.phoneNumber[2...])
        let asYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
        phoneNumberInFormat = asYouTypeFormatter?.inputString(phoneNumber) ?? ""
        guard phoneNumberInFormat != "" else {
            print("Should have formatted Phone Number.")
            return
        }
        userNameField.text = phoneNumberInFormat
    }
    
    @IBAction func Logout(_ sender: UIBarButtonItem) {
        let storybaord = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storybaord.instantiateViewController(withIdentifier: "Login")
        present(vc, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        pages.isUserInteractionEnabled = true
        pageControl.isUserInteractionEnabled = true
        
        guard let input = userNameField.text, input != "" else {
            setFieldToNumber()
//            Api.setName(name: "") { (response, error) in
//                guard error == nil else {
//                    print("setting user name failed.")
//                    return
//                }
//            }
            return
        }
        userNameField.text = input
        if input != wallet.userName {
            Storage.user = input
//            Api.setName(name: input) { (response, error) in
//                guard error == nil else {
//                    print("setting user name failed.")
//                    return
//                }
//            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.newAccountView.alpha = 0
        }
    }
    
    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            self.pages.contentOffset.x = CGFloat(sender.selectedSegmentIndex) * self.pagesFrame.width
        }
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        dataInit(random: true, first: false)
    }
    
    @IBAction func clean(_ sender: UIButton) {
        wallet.totalAmount = 0.0
        wallet.accounts.removeAll()
        wallet.Whistory.removeAll()
        viewUpdate()
//        saveAccountsToServer()
    }
    
    @IBAction func coverNewAccount(_ sender: UIButton) {
        addNewAccount()
    }
    @IBAction func navNewAccount(_ sender: Any) {
        addNewAccount()
    }
    
    func addNewAccount() {
        pages.isUserInteractionEnabled = false
        pageControl.isUserInteractionEnabled = false
        newAccountNameField.becomeFirstResponder()
        newAccountNameField.placeholder = "Account \(wallet.accounts.count + 1)"
        UIView.animate(withDuration: 0.3) {
            self.newAccountView.alpha = 1
        }
    }
    
    @IBAction func newAccountButton(_ sender: UIButton) {
        var name = ""
        if newAccountNameField.text == "" {
            name = newAccountNameField.placeholder ?? ""
        } else {
            name = newAccountNameField.text ?? ""
        }
        guard name != "" else {
            print("Something wrong with setting name.")
            return
        }
        Api.addNewAccount(wallet: wallet, newAccountName: name) { (response, error) in
            guard let response = response, error == nil else {
                print(error?.message ?? "Error add account on server.")
                return
            }
            print(response)
            self.wallet = Wallet.init(data: response, ifGenerateAccounts: false)
            self.viewUpdate()
            UIView.animate(withDuration: 0.3) {
                self.newAccountView.alpha = 0
            }
            self.newAccountNameField.text = ""
            self.view.endEditing(true)
        }
    }
}

extension WalletViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pages.isUserInteractionEnabled = false
        pageControl.isUserInteractionEnabled = false
    }
}

class accountCell: UICollectionViewCell {
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var accountID: UILabel!
    @IBOutlet weak var accountAmount: UILabel!
}

class functionCell: UICollectionViewCell {
    @IBOutlet weak var functionName: UILabel!
}

extension WalletViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.restorationIdentifier == "lisfOfAccount" {
            if wallet.accounts.count == 0 {
                listOfAccounts.alpha = 0
                accountViewCover.alpha = 1
            } else {
                listOfAccounts.alpha = 1
                accountViewCover.alpha = 0
            }
            return wallet.accounts.count
        }
        else if collectionView.restorationIdentifier == "listOfFunctions" {
            return functions.count + 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.restorationIdentifier == "lisfOfAccount" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "account", for: indexPath) as! accountCell
            
            cell.accountName.text = wallet.accounts[indexPath.row].name
            cell.accountID.text = wallet.accounts[indexPath.row].ID
            cell.accountAmount.text = Format.money(input: wallet.accounts[indexPath.row].amount, withMark: false)

            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowOffset = CGSize.init(width: 1, height: 1)
            cell.layer.cornerRadius = 6
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "function", for: indexPath) as! functionCell
            
            if indexPath.row != functions.count {
                cell.functionName.text = functions[indexPath.row]
                cell.layer.cornerRadius = cell.frame.height / 2
            } else {
                cell.backgroundColor = UIColor.white
                cell.functionName.textColor = UIColor.darkGray
                cell.functionName.font = UIFont.init(name: "System", size: 12)
                cell.functionName.text = "More Incoming..."
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.restorationIdentifier == "lisfOfAccount" {
            return CGSize.init(width: pagesFrame.width - 40, height: 100)
        } else {
            let viewFrame = collectionView.frame
            let newHeight = (viewFrame.height - CGFloat(20 * functions.count)) / CGFloat(functions.count + 1)
            return CGSize.init(width: viewFrame.width * 0.8, height: newHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.restorationIdentifier == "lisfOfAccount" {
            selectedAccountIndex = indexPath.row
            performSegue(withIdentifier: "accountDetail", sender: self)
        } else {
            switch indexPath.row {
                case 0: selectedTransType = TransType.deposit
                case 1: selectedTransType = TransType.withdraw
                case 2: selectedTransType = TransType.transfer
                case 3: selectedTransType = TransType.unknown
                default: print("Wrong selected cell.")
            }
            if selectedTransType != TransType.unknown {
                performSegue(withIdentifier: "showTransfer", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountDetail" {
            let dest = segue.destination as! AccountViewController
            dest.accountData = wallet.accounts[selectedAccountIndex]
        } else {
            let dest = segue.destination as! TransferViewController
            dest.transType = selectedTransType
            // Without Api
            dest.wallet = wallet
        }
    }
}

class historyCell: UITableViewCell {
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!
    @IBOutlet weak var icon: UIImageView!
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wallet.Whistory.count == 0 {
            historyViewCover.alpha = 1
            listOfHistory.alpha = 0
            return 0
        } else {
            historyViewCover.alpha = 0
            listOfHistory.alpha = 1
            return wallet.Whistory.count < 20 ? wallet.Whistory.count : 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! historyCell
        cell.amount.text = Format.money(input: wallet.Whistory[indexPath.row].amount, withMark: false)
        cell.current.text = Format.money(input: wallet.Whistory[indexPath.row].currentWallet, withMark: true)
        cell.from.text = wallet.Whistory[indexPath.row].from
        cell.to.text = wallet.Whistory[indexPath.row].to
        switch wallet.Whistory[indexPath.row].type {
        case .deposit:
            cell.icon.image = UIImage.init(named: "add.png")
        case .transfer:
            cell.icon.image = UIImage.init(named: "swap.png")
        case .withdraw:
            cell.icon.image = UIImage.init(named: "remove.png")
        default:
            print("Should not appear.")
        }
        return cell
    }
}

extension WalletViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == pages {
            let x = scrollView.contentOffset.x + pagesFrame.width
            let w = scrollView.contentSize.width
            switch (w/x) {
            case 3.0:
                pageControl.selectedSegmentIndex = 0
            case 1.5:
                pageControl.selectedSegmentIndex = 1
            case 1.0:
                pageControl.selectedSegmentIndex = 2
            default:
                print("Error")
            }
        }
    }
}

extension WalletViewController {
    
}
