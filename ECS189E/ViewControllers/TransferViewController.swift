//
//  TransferViewController.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 11/2/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit

class TransferViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var fromPicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var constraintBefore: NSLayoutConstraint!
    @IBOutlet weak var constraintAfter: NSLayoutConstraint!
    
    var transType = TransType.unknown
    var wallet = Wallet.init()
    var originFrame = CGRect()
    var fromAccount = 0
    var toAccount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        dataInit()
        originFrame = container.frame
        done.layer.cornerRadius = done.frame.height / 2
    }
    
    func dataInit() {
        Api.user { (response, error) in
            guard let response = response, error == nil else {
                print("Cannot get data for Transfer.")
                return
            }
            self.wallet = Wallet.init(data: response, ifGenerateAccounts: false)
            self.fromPicker.reloadAllComponents()
            self.toPicker.reloadAllComponents()
        }
    }
    
    func recordTrans(amount: Double) {
        let newTrans = Transaction.init(inputAmount: amount, inputType: transType, inputFrom: wallet.accounts[fromAccount].name, inputTo: wallet.accounts[toAccount].name, inputAccount: 0, inputWallet: 0)

        switch transType {
            case .deposit:
                wallet.accounts[toAccount].amount += amount
                wallet.totalAmount += amount
                newTrans.from = "Magic place"
                newTrans.currentAccount = wallet.accounts[toAccount].amount
                wallet.accounts[toAccount].Ahistory.insert(newTrans, at: 0)
            
            case .withdraw:
                wallet.accounts[fromAccount].amount -= amount
                wallet.totalAmount -= newTrans.amount
                newTrans.to = "Live"
                newTrans.amount = -amount
                newTrans.currentAccount = wallet.accounts[fromAccount].amount
                wallet.accounts[fromAccount].Ahistory.insert(newTrans, at: 0)
            
            case .transfer:
                wallet.accounts[fromAccount].amount -= amount
                wallet.accounts[toAccount].amount += amount
                newTrans.currentAccount = wallet.accounts[toAccount].amount
                wallet.accounts[toAccount].Ahistory.insert(newTrans, at: 0)
                newTrans.amount = -amount
                newTrans.currentAccount = wallet.accounts[fromAccount].amount
                wallet.accounts[fromAccount].Ahistory.insert(newTrans, at: 0)
            
            case .unknown:
                print("recordTrans() unknown Error")
        }
        
        newTrans.currentWallet = wallet.totalAmount
        wallet.Whistory.insert(newTrans, at: 0)
        
        let vc = self.presentingViewController as! WalletViewController
        vc.wallet = wallet
        vc.viewUpdate()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneByButton(_ sender: UIButton) {
        
        if let input = amountTextField.text {
            if input == "" {
                infoLabel.text = "The amount cannot be empty."
                return
            }
            if let amount = Double(input) {
                if amount == 0 {
                    infoLabel.text = "The amount cannot be 0."
                    return
                }
                
                if transType != TransType.deposit && amount > wallet.accounts[fromAccount].amount {
                    infoLabel.text = "There is not enough amount on \(wallet.accounts[fromAccount].name)"
                    amountTextField.text = String(wallet.accounts[fromAccount].amount)
                    return
                }
                
                if transType == TransType.transfer && fromAccount == toAccount {
                    infoLabel.text = "Cannot transfer money between same account."
                    return
                }

                recordTrans(amount: amount)
                
                // Trans
//                Api.setAccounts(accounts: self.wallet.accounts) { (response, error) in
//                    guard error == nil else {
//                        print("Something wrong when setting accounts.")
//                        return
//                    }
//                    let dest = self.presentingViewController as! WalletViewController
//                    dest.dataInit(random: false, first: false)
//                    self.dismiss(animated: true, completion: nil)
//                } // Api
                
            } // if amount
        } // if input valid
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.restorationIdentifier == "fromPicker" {
            if transType == TransType.deposit {
                return 1
            } else {
                return wallet.accounts.count
            }
        } else {
            if transType == TransType.withdraw {
                return 1
            } else {
                return wallet.accounts.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.restorationIdentifier == "fromPicker" {
            if transType == TransType.deposit {
                return "Magic Place: Infinity"
            } else {
                return wallet.accounts[row].name + ": " + Format.money(input: wallet.accounts[row].amount, withMark: false)
            }
        } else {
            if transType == TransType.withdraw {
                return "Live: -Infinity"
            } else {
                return wallet.accounts[row].name + ": " + Format.money(input: wallet.accounts[row].amount, withMark: false)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.restorationIdentifier == "fromPicker" {
            fromAccount = row
        } else {
            toAccount = row
        }
    }
    
    @IBAction func fieldTouchDown(_ sender: UITextField) {

        UIView.animate(withDuration: 0.3) {
            self.constraintBefore.isActive = false
            self.constraintAfter.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.constraintBefore.isActive = true
            self.constraintAfter.isActive = false
            self.view.layoutIfNeeded()
        }
    }
}
