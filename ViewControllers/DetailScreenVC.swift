//
//  DetailScreenVC.swift
//  Xicom M Test
//
//  Created by Itika Soni on 13/09/23.
//
import Alamofire
import UIKit

class DetailScreenVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var uiViewFirstName: UIView!
    @IBOutlet weak var uiViewLastName: UIView!
    @IBOutlet weak var uiViewPhone: UIView!
    @IBOutlet weak var uiViewEmail: UIView!
    @IBOutlet weak var txtFldFirstName: UITextField!
    @IBOutlet weak var txtFldLastName: UITextField!
    @IBOutlet weak var txtFldPhone: UITextField!
    @IBOutlet weak var txtFldEmail: UITextField!
    
    
    var imageData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        uiViewFirstName.layer.borderColor = UIColor.black.cgColor
        uiViewLastName.layer.borderColor = UIColor.black.cgColor
        uiViewPhone.layer.borderColor = UIColor.black.cgColor
        uiViewEmail.layer.borderColor = UIColor.black.cgColor
       
        uiViewFirstName.layer.borderWidth = 1.0
        uiViewLastName.layer.borderWidth = 1.0
        uiViewPhone.layer.borderWidth = 1.0
        uiViewPhone.layer.borderWidth = 1.0
        uiViewEmail.layer.borderWidth = 1.0
        
        if let imageUrl = URL(string: imageData) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        self.imgView.image = image
                    }
                }
            }
        }
       
    }
    



    func saveUserData(firstName: String, lastName: String, email: String, phone: String, userImage: UIImage) {
        
        let url = "http://dev3.xicom.us/xttest/savedata.php"
        let parameters: [String: String] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phone
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }

                if let imageData = userImage.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(imageData, withName: "user_image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
            },
            to: url
        )
        .responseJSON { response in
            debugPrint(response)
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let message = json["message"] as? String {
                    self.showAlert(title: "Success Message", message: message)
                } else {
                    self.showAlert(title: "Error", message: "Invalid Response Format")
                }
            case .failure(let error):
                print("Error: \(error)")
                self.showAlert(title: "Error", message: "An error occurred")
            }
            
        }
    }

    @IBAction func actionSubmit(_ sender: UIButton) {

        
        let firstName = txtFldFirstName.text
        let lastName = txtFldLastName.text
        let email = txtFldEmail.text
        let phone = txtFldPhone.text

        if(firstName == "" || lastName == "" || email == "" || phone == "" || firstName == ""){
            showAlert(title: "Alert Message", message: "All Fields are required")
            return
        }
        
       let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
       let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
       if !emailPredicate.evaluate(with: email) {
           showAlert(title: "Alert Message", message: "Invalid Email Format")
           return
       }
        
        if let imageUrl = URL(string: imageData) {
           DispatchQueue.global().async {
               if let imageData = try? Data(contentsOf: imageUrl) {
                   if let image = UIImage(data: imageData) {
                       // Use the downloaded image in the saveUserData function
                       self.saveUserData(firstName: firstName!, lastName: lastName!, email: email!, phone: phone!, userImage: image)
                   }
               }
           }
       }
        
        
    }
    
    

}


extension DetailScreenVC {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
