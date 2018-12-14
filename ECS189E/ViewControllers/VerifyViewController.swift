//
//  LoginView2.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 9/23/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit

class VerifyViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var displayPhoneNumber: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorInfo: UILabel!
    
    var phoneNumber = String()
    var phoneNumberInFormat = String()
    var data = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewInit()
        displayPhoneNumber.text = phoneNumberInFormat
    }
    
    func viewInit() {
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        errorInfo.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func nextOnTap(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let code = inputField.text else {
            self.errorInfo.text = "Please enter the code we sent you via SMS"
            self.errorInfo.textColor = UIColor.red
            self.errorInfo.isHidden = false
            return
        }
        
        // Without Api
        if code == "1234" {
            Storage.phoneNumberInE164 = phoneNumber
            performSegue(withIdentifier: "showWallet", sender: self)
        } else {
            self.errorInfo.text = "Please enter 1234."
            self.errorInfo.textColor = UIColor.red
            self.errorInfo.isHidden = false
        }
//        Api.verifyCode(phoneNumber: phoneNumber, code: code) { response, error in
//            guard let response = response, error == nil else {
//                self.errorInfo.text = error?.message
//                self.errorInfo.textColor = UIColor.red
//                self.errorInfo.isHidden = false
//                return
//            }
//
//            // ===
//            if let authToken = response["auth_token"] as? String {
//                Storage.authToken = authToken
//            }
//            Storage.phoneNumberInE164 = self.phoneNumber
//            self.data = response
//            self.performSegue(withIdentifier: "showWallet", sender: self)
//        }
    }
    
    @IBAction func resend(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWallet" {
            let dest = segue.destination as! WalletViewController
            dest.sms = true
        }
    }
}
