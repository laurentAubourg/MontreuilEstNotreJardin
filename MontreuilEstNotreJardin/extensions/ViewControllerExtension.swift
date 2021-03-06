//
//  ViewController+Alert rxtension
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 23/09/2021.
//
import UIKit
extension UIViewController{
    
    //MARK: - Displays an alert
    
     func presentAlert(title:String = "", message:String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
   
        func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }

}

