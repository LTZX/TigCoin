//
//  ViewController.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 9/22/18.
//  Copyright © 2018 Zhiyi Xu. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorInfo: UILabel!
    
    let phoneNumberPrefix = "+1"
    var asYouTypeFormatter: NBAsYouTypeFormatter?
    var phoneNumber = String()
    var phoneNumberInFormat = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
        phoneNumber = Storage.phoneNumberInE164 ?? ""
        if phoneNumber != "" {
            
            // Removing +1
            phoneNumber =  String(phoneNumber[2...])
            phoneNumberInFormat = asYouTypeFormatter?.inputString(phoneNumber) ?? ""
            inputField.text = phoneNumberInFormat
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewInit()
    }

    func viewInit() {
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        errorInfo.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func touchID() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Biometric Authntication"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            self.performSegue(withIdentifier: "showWalletWithoutSMS", sender: self)
                            // User authenticated successfully, take appropriate action
                        } else {
                            self.testPhoneNumber()
                            // User did not authenticate successfully, look at error and take appropriate action
                        }
                    }
                }
            } else {
                self.testPhoneNumber()
                // Could not evaluate policy; look at authError and present an appropriate message to user
            }
        } else {
            self.testPhoneNumber()
            // Fallback on earlier versions
        }
    }
    
    @IBAction func nextOnTap(_ sender: UIButton) {
        self.view.endEditing(true)

        // For Auth token verify
//        guard Storage.authToken != nil, Storage.phoneNumberInE164 == (phoneNumberPrefix + phoneNumber) else {
//            testPhoneNumber()
//            return
//        }
        guard Storage.phoneNumberInE164 == (phoneNumberPrefix + phoneNumber) else {
            testPhoneNumber()
            return
        }
        touchID()
    }
    
    func testPhoneNumber() {
        if let input = inputField.text {
            phoneNumber = input.filter { $0 >= "0" && $0 <= "9" }
            if phoneNumber.count == 0 {
                errorInfo.text = "Please enter your phone number."
                errorInfo.isHidden = false
            }
            else if phoneNumber.count != 10 {
                errorInfo.text = "Your phone number is invalid."
                errorInfo.isHidden = false
            } else {
                
                // Without Api
                phoneNumberInFormat = input
                performSegue(withIdentifier: "verifySMS", sender: self)

                //                Api.sendVerificationCode(phoneNumber: phoneNumber) { response, error in
//                    self.nextButton.setTitle("Next", for: .normal)
//                    guard response != nil && error == nil else {
//                        self.errorInfo.isHidden = false
//                        self.errorInfo.text = error?.message
//                        return
//                    }
//                    self.phoneNumberInFormat = input
//                    self.performSegue(withIdentifier: "verifySMS", sender: self)
//                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verifySMS" {
            let dest = segue.destination as! VerifyViewController
            dest.phoneNumber = phoneNumberPrefix + phoneNumber
            dest.phoneNumberInFormat = phoneNumberInFormat
        }
        if segue.identifier == "showWalletWithoutSMS" {
            let dest = segue.destination as! WalletViewController
            dest.sms = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 {
            inputField.text = asYouTypeFormatter?.inputDigit(string)
        } else {
            inputField.text = asYouTypeFormatter?.removeLastDigit()
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        asYouTypeFormatter = NBAsYouTypeFormatter(regionCode: "US")
        return true
    }
}

