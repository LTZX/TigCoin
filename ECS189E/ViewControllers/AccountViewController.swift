//
//  AccountViewController.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 10/27/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var accountContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var transTable: UITableView!
    
    @IBOutlet weak var historyCover: UILabel!
    
    var accountData = Account()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerAnimation()
    }
    
    func viewInit() {
        accountContainer.layer.shadowOpacity = 0.7
        accountContainer.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        accountContainer.layer.cornerRadius = 10
        
        nameLabel.text = accountData.name
        IDLabel.text = accountData.ID
        amountLabel.text = Format.money(input: accountData.amount, withMark: true)
        
    }
    
    func containerAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.accountContainer.frame.origin.y = self.accountContainer.frame.origin.y * 2 / 5
            if self.accountData.Ahistory.count != 0 {
                self.transTable.alpha = 1
            }
        }, completion: {(true) in

        })
    }
    
    @IBAction func closeDetailView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

class transCell: UITableViewCell {
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var with: UILabel!
}

extension AccountViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transTable.alpha = 0
        if accountData.Ahistory.count == 0 {
            historyCover.alpha = 1
            return 0
        } else {
            historyCover.alpha = 0
            return accountData.Ahistory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell", for: indexPath) as! transCell
        let trans = accountData.Ahistory[indexPath.row]
        cell.amount.text = Format.money(input: trans.amount, withMark: true)
        cell.current.text = Format.money(input: trans.currentAccount, withMark: true)
        cell.date.text = Format.date(input: trans.date) + "\n" + Format.time(input: trans.date)
        if trans.from == accountData.name {
            cell.with.text = trans.to
        } else {
            cell.with.text = trans.from
        }
        return cell
    }
}
