//
//  LoginVC.swift
//  Fluff_iOS
//
//  Created by TaeJin Oh on 2019/12/23.
//  Copyright © 2019 TaeJin Oh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurBackgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coverView: UIView!
    // Animate 되기전 SNS 로그인 분기 버튼
    @IBOutlet weak var snsButton: UIButton!
    // Animate 되기전 Login으로 분기 버튼
    @IBOutlet weak var loginButton: UIButton!
    // Animate 되기전 회원가입 분기 버튼
    @IBOutlet weak var signinButton: UIButton!
    
    // Animate 되고 나오는 버튼  --> 아이디/패스워드 찾기
    @IBOutlet weak var idPwdSearchButton: UIButton!
    // Animate 되고 나오는 버튼 --> 로그인 하기
    @IBOutlet weak var doLoginButton: UIButton!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var snsLabel: UILabel!
    
    // Animate 되고 ID 입력하는 TextField
    private var emailTextField: UITextField?
    // Animate 되고 Pwd 입력하는 TextField
    private var pwdTextField: UITextField?
    // Animate 되고 IDTextField Background View
    private var loginView: UIView?
    // Animate 되고 PWDTextField Background View
    private var pwdView: UIView?
    
    // Animate 되고 ID Label
    private var emailLabel: UILabel?
    // Animate 되고 Pwd Label
    private var pwdLabel: UILabel?
    
    private var loginEstimateX: CGFloat?
    private var loginEstimateY: CGFloat?
    private var pwdEstimateY: CGFloat?
    private var estimateSize: CGSize?

    lazy var logoWidth: CGFloat = self.logoImageView.frame.size.width
    lazy var logoHeight: CGFloat = self.logoImageView.frame.size.height
    
    private var userData: SignupUserInform?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialButton()
        UIView.animate(withDuration: 1.0) {
            self.backgroundImageView.alpha = 0
        }
        
        coverView.alpha = 0
        
        loginEstimateX = snsButton.frame.origin.x
        loginEstimateY = snsButton.frame.origin.y - 280
        pwdEstimateY = loginButton.frame.origin.y - 250
        
        estimateSize = loginButton.frame.size
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func initialButton() {
        idPwdSearchButton.alpha = 0
        doLoginButton.alpha = 0
        doLoginButton.makeCornerRounded(radius: doLoginButton.frame.width / 17)
        loginButton.makeCornerRounded(radius: loginButton.frame.width / 17)
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.borderWidth = 1
        snsButton.makeCornerRounded(radius: snsButton.frame.width / 17)
        snsButton.layer.borderWidth = 1
        snsButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setUserData(_ userData: SignupUserInform) {
        self.userData = userData
    }
    
    @IBAction func doSignup(_ sender: Any) {
        let SignupStroyboard = UIStoryboard(name: "NewSignUp", bundle: nil)
        guard let signupVC = SignupStroyboard.instantiateViewController(identifier: "NewSignUp") as? NewSignUpViewController else { return }
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @IBAction func doLogin(_ sender: Any) {
        // Login 실행
        guard let inputEmail = emailTextField?.text, inputEmail != "" else {
            self.presentAlertController(title: "ID을 입력해주세요", message: nil)
            return
        }
        guard let inputPwd = pwdTextField?.text, inputPwd != "" else {
            self.presentAlertController(title: "PW을 입력해주세요", message: nil)
            return
        }
        
        SigninService.shared.signin(email: inputEmail, pwd: inputPwd) { networkResult in
            switch networkResult {
            case .success(let data):
                guard let jsonData = data as? SigninJsonData else { return }
                if jsonData.success {
                    guard let userToken = jsonData.data else { return }
                    let token = userToken.token
                    // token 값 UserDefault 내부 DB에 저장
                    UserDefaults.standard.set(token, forKey: "token")
                    print("userToken: \(token)")
                    print(userToken.style)
                    
                    // Style 값이 있는 경우 취향조사 페이지로 분기
                    if let isStyle = userToken.style, isStyle == false {
                        guard let tasteAnalysisVC = self.storyboard?.instantiateViewController(identifier: "TasteAnalysisVC") as? TasteAnalysisVC else { return }
                        tasteAnalysisVC.setAnalysisStatus(.signup)
                        self.navigationController?.pushViewController(tasteAnalysisVC, animated: true)
                    } else {
                    // 메인 홈탭으로 분기
                        guard let mainTabbarController = self.storyboard?.instantiateViewController(identifier: "MainTabbarController") as? MainTabbarController else { return }
                        mainTabbarController.modalPresentationStyle = .fullScreen
                        self.present(mainTabbarController, animated: true, completion: nil)
                    }
                }
            case .requestErr(_):
                self.presentAlertController(title: "회원가입이 필요합니다", message: "")
                return
            case .pathErr:
                print("pathErr")
                return
            case .serverErr:
                print("server")
                return
            case .networkFail:
                self.presentAlertController(title: "네트워크 연결 불가", message: "네트워크를 연결해주세요")
                return
            }
        }
    }
    
    @IBAction func animateLogin(_ sender: Any) {
        loginButton.backgroundColor = .white
        
        UIView.animate(withDuration: 0.5, animations: {
            self.signinButton.alpha = 0
            self.backgroundImageView.alpha = 1
            self.loginLabel.alpha = 0
            self.snsLabel.alpha = 0
            self.logoImageView.transform = CGAffineTransform(translationX: 0, y: -150)
            self.logoImageView.frame.size = CGSize(width: self.logoWidth-20, height: self.logoHeight-20)
            self.loginButton.transform = CGAffineTransform(translationX: 0, y: -250)
            self.snsButton.transform = CGAffineTransform(translationX: 0, y: -280)
            self.coverView.alpha = 0.5
            self.doLoginButton.alpha = 1
            self.idPwdSearchButton.alpha = 1
        }, completion: { isAnimate in
            self.addGestureRecognizer()
            self.logoImageView.translatesAutoresizingMaskIntoConstraints = true
            self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = true
            self.blurBackgroundImageView.translatesAutoresizingMaskIntoConstraints = true
            
            self.loginView = UIView(frame: CGRect(origin: CGPoint(x: self.loginEstimateX!, y: self.loginEstimateY!), size: self.estimateSize!))
            self.loginView?.backgroundColor = .white
            self.loginView?.makeCornerRounded(radius: self.loginButton.frame.width / 17)
            self.view.addSubview(self.loginView!)
            
            self.emailLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.loginEstimateX! + 12, y: self.loginEstimateY! - 30), size: CGSize(width: 50, height: 30)))
            self.emailLabel?.text = "이메일"
            self.emailLabel?.textColor = .white
            self.emailLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.view.addSubview(self.emailLabel!)
            
            self.emailTextField = UITextField(frame: CGRect(origin: CGPoint(x: self.loginEstimateX! + 20, y: self.loginEstimateY!), size: self.estimateSize!))
            self.emailTextField?.placeholder = "이메일"
            self.emailTextField?.borderStyle = .none
            self.view.addSubview(self.emailTextField!)
            
            self.pwdView = UIView(frame: CGRect(origin: CGPoint(x: self.loginEstimateX!, y: self.pwdEstimateY!), size: self.estimateSize!))
            self.pwdView?.backgroundColor = .white
            self.pwdView?.makeCornerRounded(radius: self.loginButton.frame.width / 17)
            self.view.addSubview(self.pwdView!)
            
            self.pwdLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.loginEstimateX! + 12, y: self.pwdEstimateY! - 30), size: CGSize(width: 70, height: 30)))
            self.pwdLabel?.text = "비밀번호"
            self.pwdLabel?.textColor = .white
            self.pwdLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.view.addSubview(self.pwdLabel!)
            
            self.pwdTextField = UITextField(frame: CGRect(origin: CGPoint(x: self.loginEstimateX! + 20, y: self.pwdEstimateY!), size: self.estimateSize!))
            self.pwdTextField?.isSecureTextEntry = true
            self.pwdTextField?.placeholder = "비밀번호"
            self.pwdTextField?.borderStyle = .none
            self.view.addSubview(self.pwdTextField!)
        })
    }
}

extension LoginVC {
    private func addGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(resetView))
        doubleTap.numberOfTapsRequired = 2
        self.coverView.addGestureRecognizer(doubleTap)
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(downKeyboard))
        oneTap.numberOfTapsRequired = 1
        self.coverView.addGestureRecognizer(oneTap)
    }
    
    @objc func downKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func resetView() {
        loginView?.alpha = 0
        pwdView?.alpha = 0
        loginButton.backgroundColor = .clear
        UIView.animate(withDuration: 1.0, animations: {
            self.doLoginButton.alpha = 0
            self.idPwdSearchButton.alpha = 0
            self.signinButton.alpha = 1
            self.backgroundImageView.alpha = 0
            self.emailTextField?.alpha = 0
            self.pwdTextField?.alpha = 0
            self.loginView?.alpha = 0
            self.pwdView?.alpha = 0
            self.emailLabel?.alpha = 0
            self.pwdLabel?.alpha = 0
            self.coverView.alpha = 0
            self.logoImageView.transform = .identity
            self.logoImageView.frame.size = CGSize(width: self.logoWidth, height: self.logoHeight)
            self.loginButton.alpha = 1
            self.loginButton.transform = .identity
            self.snsLabel.alpha = 1
            self.snsButton.alpha = 1
            self.snsButton.transform = .identity
            self.loginLabel.alpha = 1
        }, completion: { isAnimate in
            self.logoImageView.frame.size = CGSize(width: self.logoWidth, height: self.logoHeight)
        })
    }
}

extension LoginVC {
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(doAutoLogin), name: .autoLoginExcute, object: nil)
    }
    
    @objc func doAutoLogin() {
        guard let userData = self.userData else { return }
        // 여기에 login로직 추가
        // 로그인 로직에 따라 로그인 되게 추가!!!!!
        SigninService.shared.signin(email: userData.email, pwd: userData.pwd) { networkResult in
            switch networkResult {
            case .success(let data):
                guard let jsonData = data as? SigninJsonData else { return }
                if jsonData.success {
                    guard let userToken = jsonData.data else { return }
                    let token = userToken.token
                    // token 값 UserDefault 내부 DB에 저장
                    UserDefaults.standard.set(token, forKey: "token")
                    print("userToken: \(token)")
                    
                    // Style 값이 있는 경우 취향조사 페이지로 분기
                    if let isStyle = userToken.style, isStyle == false {
                        guard let tasteAnalysisVC = self.storyboard?.instantiateViewController(identifier: "TasteAnalysisVC") as? TasteAnalysisVC else { return }
                        tasteAnalysisVC.setAnalysisStatus(.signup)
                        self.navigationController?.pushViewController(tasteAnalysisVC, animated: true)
                    }
                }
            case .requestErr(_):
                self.presentAlertController(title: "회원가입이 필요합니다", message: "")
                return
            case .pathErr:
                self.presentAlertController(title: "경로 에러", message: "")
                return
            case .serverErr:
                print("server")
                return
            case .networkFail:
                self.presentAlertController(title: "네트워크 연결 불가", message: "네트워크를 연결해주세요")
                return
            }
        }
    }
}
