import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginVC: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBAction func handleLoginButton(_ sender: AnyObject) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // 処理中を表示
            SVProgressHUD.show()
            
            FIRAuth.auth()?.signIn(withEmail: address, password: password) { user, error in
                if error != nil {
                    // エラー表示
                    SVProgressHUD.showError(withStatus: "エラー")
                } else {
                    // Firebaseからログインしたユーザの表示名を取得してNSUserDefaultsに保存する
                    if let displayName = user?.displayName {
                        self.setDisplayName(name: displayName)
                    }
                    
                    // HUDを消す
                    SVProgressHUD.dismiss()
                    
                    // 画面を閉じる
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func handleCreateAcountButton(_ sender: AnyObject) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text,
            let displayName = displayNameTextField.text {
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.characters.isEmpty || password.characters.isEmpty
                || displayName.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            FIRAuth.auth()?.createUser(withEmail: address, password: password) { user, error in
                if error != nil {
                    print(error)
                } else {
                    // ユーザーを作成できたらそのままログインする
                    FIRAuth.auth()?.signIn(withEmail: address, password: password) { user, error in
                        if error != nil {
                            print(error)
                        } else {
                            if let user = user {
                                // Firebaseに表示名を保存する
                                let request = user.profileChangeRequest()
                                request.displayName = displayName
                                request.commitChanges() { error in
                                    if error != nil {
                                        print(error)
                                    } else {
                                        // NSUserDefaultsに表示名を保存する
                                        self.setDisplayName(name: displayName)
                                        
                                        // 画面を閉じる
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setDisplayName(name: String){
        let ud = UserDefaults.standard
        ud.setValue(name, forKey: CommonConst.DisplayNameKey)
        ud.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
