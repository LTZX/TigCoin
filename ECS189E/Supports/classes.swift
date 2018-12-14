//
//  classes.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 10/26/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//
import Foundation

// Usage:
// Getting: phoneNumber = Storage.phoneNumberInE164
// Setting: Storage.phoneNumberInE164 = phoneNumber

struct Storage {
    static var phoneNumberInE164: String? {
        get {
            return UserDefaults.standard.string(forKey: "phoneNumberInE164")
        }
        
        set(phoneNumberInE164) {
            UserDefaults.standard.set(phoneNumberInE164, forKey: "phoneNumberInE164")
            print("Saving phone number was \(UserDefaults.standard.synchronize())")
        }
    }
    
    static var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "authToken")
        }
        
        set(authToken) {
            UserDefaults.standard.set(authToken, forKey: "authToken")
            print("Saving auth token was \(UserDefaults.standard.synchronize())")
        }
    }
    static var user: String? {
        get {
            return UserDefaults.standard.string(forKey: "userName")
        }
        
        set(authToken) {
            UserDefaults.standard.set(authToken, forKey: "userName")
            print("Saving user name was \(UserDefaults.standard.synchronize())")
        }
    }
}

// Usage:
// In case you want me to generate a list of Accounts with random amounts and names
//      var wallet = Wallet.init(data: response, ifGenerateAccounts: true)
// In case you want to customized your accounts
//      var wallet = Wallet.init(data: response, ifGenerateAccounts: false)

class Wallet {
    var userName: String?
    var totalAmount: Double
    var phoneNumber: String
    var accounts: [Account]
    var Whistory: [Transaction]
    
    init() {
        self.userName = ""
        self.totalAmount = 0.0
        self.phoneNumber = ""
        self.accounts = [Account]()
        self.Whistory = [Transaction]()
    }
    
    init(data: [String: Any], ifGenerateAccounts: Bool) {
//        let walletData = data["user"] as! [String:Any]
//        self.userName = walletData["name"] as? String
        self.userName = Storage.user ?? ""
        self.totalAmount = 0.0
//        self.totalAmount = walletData["totalAmount"] as? Double ?? 0.0
//        self.phoneNumber = walletData["e164_phone_number"] as! String
        self.phoneNumber = Storage.phoneNumberInE164 ?? ""
        self.accounts = [Account]()
        self.Whistory = [Transaction]()

        if ifGenerateAccounts {
            var newTotal = 0.0
            for i in 0 ..< Int.random(in: 2 ..< 8) {
                let newAccount = Account(index: i, randomAmount: true)
                self.accounts.append(newAccount)
                newTotal = newTotal + newAccount.amount
            }
            self.totalAmount = newTotal
            
            var dateSet = [Date]()
            for _ in 0...Int.random(in: 50...100) {
                let startDate = Date.init(timeIntervalSinceNow: -60 * 60 * 24 * 100)
                let aDay =  60 * 60 * 24
                dateSet.append(Date.init(timeInterval: Double(Int.random(in: 0...99) * aDay + Int.random(in: 1...60*60)), since: startDate))
            }
            dateSet.sort(by: {$0 < $1})
            
            let types = [TransType.deposit, TransType.withdraw, TransType.transfer]
            for date in dateSet {
                let type = types[Int.random(in: 0...2)]
                let transaction = Transaction()
                transaction.type = type
                transaction.date = date
                switch type {
                    case .deposit:
                        transaction.amount = round(Double.random(in: 100...2000) * 100) / 100
                        transaction.from = "Magical Place"
                        let toIndex = Int.random(in: 0..<self.accounts.count)
                        transaction.to = self.accounts[toIndex].name
                        transaction.currentWallet = self.totalAmount + transaction.amount
                        transaction.currentAccount = self.accounts[toIndex].amount + transaction.amount
                        self.Whistory.append(transaction)
                        self.accounts[toIndex].Ahistory.append(transaction)
                    
                    case .withdraw:
                        let fromIndex = Int.random(in: 0..<self.accounts.count)
                        transaction.from = self.accounts[fromIndex].name
                        transaction.amount = round(Double.random(in: -self.accounts[fromIndex].amount ..< 0) * 100) / 100
                        transaction.to = "Live"
                        transaction.currentWallet = self.totalAmount + transaction.amount
                        transaction.currentAccount = self.accounts[fromIndex].amount + transaction.amount
                        self.Whistory.append(transaction)
                        self.accounts[fromIndex].Ahistory.append(transaction)
                    
                    case .transfer:
                        let fromIndex = Int.random(in: 0..<self.accounts.count)
                        let toIndex = Int.random(in: 0..<self.accounts.count)
                        transaction.from = self.accounts[fromIndex].name
                        transaction.to = self.accounts[toIndex].name
                        transaction.amount = round(Double.random(in: 0...self.accounts[fromIndex].amount) * 100) / 100
                        transaction.currentWallet = self.totalAmount
                        transaction.currentAccount = self.accounts[fromIndex].amount - transaction.amount
                        transaction.type = .transfer
                        self.Whistory.append(transaction)
                        transaction.type = .withdraw
                        transaction.amount = -transaction.amount
                        self.accounts[fromIndex].Ahistory.append(transaction)
                        transaction.type = .deposit
                        transaction.amount = -transaction.amount
                        transaction.currentAccount = self.accounts[toIndex].amount + transaction.amount
                        self.accounts[toIndex].Ahistory.append(transaction)

                    default:
                        print("Shouldn't reach.")
                }
            }// generate
            
            for each in self.accounts {
                each.Ahistory.sort(by: {$0.date > $1.date})
            }
            self.Whistory.sort(by: {$0.date > $1.date})
        } else {
            // Without Api
            print("No Api.")
//            if let accountsData = walletData["accounts"] as? [[String: Any]] {
//                for each in accountsData {
//                    self.accounts.append(Account.init(data: each))
//                }
//            } else {
//                print("No account data found.")
//            }
//            for i in 0 ..< self.accounts.count {
//                self.totalAmount += self.accounts[i].amount
//            }
        }
    }
    
    func printWallet() {
        print("=======================")
        print("user:\(self.userName ?? "")")
        print("phone number:\(self.phoneNumber)")
        print("totle amount:\(self.totalAmount)")
        print("List of Accounts:")
        for account in self.accounts {
            print("  \(account.name) has \(account.amount)")
        }
    }
}

class Account {
    var name: String
    var ID: String
    var amount: Double
    var Ahistory: [Transaction]
    
    init() {
        self.name = ""
        self.ID = UUID().uuidString
        self.amount = 0
        self.Ahistory = [Transaction]()
    }
    
    // For creating new account
    init(name: String) {
        self.name = name
        self.ID = UUID().uuidString
        self.amount = 0
        self.Ahistory = [Transaction]()
    }
    
    // For random generating
    init(index: Int, randomAmount: Bool) {
        self.name = "Account " + String(index + 1)
        self.ID = UUID().uuidString
        self.amount = 0
        if randomAmount {
            self.amount = round(Double.random(in: 10 ..< 10000) * 100) / 100
        }
        self.Ahistory = [Transaction]()
    }
    
    // For data reading
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.ID = data["ID"] as? String ?? ""
        self.amount = Double(data["amount"] as? String ?? "") ?? 0.0
        self.Ahistory = [Transaction]()
//        if let trans = data["transactions"] as? [[String: Any]] {
//            for each in trans {
//                self.Ahistory.append(Transaction.init(data: each))
//            }
//        }
    }
}

enum TransType: String {
    case withdraw = "withdraw"
    case deposit = "deposit"
    case transfer = "transfer"
    case unknown = "unknown"
}

class Transaction {
    var date: Date
    var amount: Double
    var type: TransType
    var from: String
    var to: String
    var currentAccount: Double
    var currentWallet: Double
    var ID: String
    
    init() {
        self.date = Date()
        self.amount = 0.0
        self.type = .unknown
        self.from = ""
        self.to = ""
        self.currentAccount = 0.0
        self.currentWallet = 0.0
        self.ID = UUID().uuidString
    }
    
    init(inputAmount: Double, inputType: TransType, inputFrom: String, inputTo: String, inputAccount: Double, inputWallet: Double) {
        self.date = Date()
        self.amount = inputAmount
        self.type = inputType
        self.from = inputFrom
        self.to = inputTo
        self.currentAccount = inputAccount
        self.currentWallet = inputWallet
        self.ID = UUID().uuidString
    }
    
    init(inputDate: Date, inputAmount: Double, inputType: TransType, inputFrom: String, inputTo: String, inputAccount: Double, inputWallet: Double) {
        self.date = inputDate
        self.amount = inputAmount
        self.type = inputType
        self.from = inputFrom
        self.to = inputTo
        self.currentAccount = inputAccount
        self.currentWallet = inputWallet
        self.ID = UUID().uuidString
    }
    
    init(data: [String: Any]) {
        self.date = Date()
        self.amount = data["amount"] as? Double ?? 0.0
        self.type = data["type"] as? TransType ?? .unknown
        self.from = data["from"] as? String ?? ""
        self.to = data["to"] as? String ?? ""
        self.currentAccount = data["currentAccount"] as? Double ?? 0.0
        self.currentWallet = data["currentWallet"] as? Double ?? 0.0
        self.ID = data["ID"] as? String ?? ""
    }
}

class Format {
    static func money(input: Double, withMark: Bool) -> String {
        if withMark {
            if input >= 0 {
                return "+T$" + String(format:"%.2f", input)
            } else {
                return "-T$" + String(format:"%.2f", -input)
            }
        } else {
            return "T$" + String(format:"%.2f", abs(input))
        }
    }
    
    static func date(input: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        dateFormatter.locale = Locale(identifier: "en_US")
        let result = dateFormatter.string(from: input)
        return result
    }
    
    static func time(input: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        dateFormatter.locale = Locale(identifier: "en_US")
        let result = dateFormatter.string(from: input)
        return result
    }
}
