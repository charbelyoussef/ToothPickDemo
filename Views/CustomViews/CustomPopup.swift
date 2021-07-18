//
//  SecondPageVC.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 8/15/21.
//


import UIKit

enum CustomPopupActionType:Int {
    case create
    case edit
    case none
}

protocol CustomPopupDelegate {
    /**
     Called when action button is clicked.
     - parameter post: The post dictionary object.
     - parameter actionType: Action type (create, edit or none).
     */
    func didPerformAction(post: NSDictionary?, actionType:CustomPopupActionType)
}

class CustomPopup: FadingViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var vBackground: UIView!
    @IBOutlet weak var vContentContainer: UIView!
        
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfDescription: UITextField!

    private static var dropDown:CustomPopup?
    
    
    var postDict:NSDictionary?
    var postToEdit:Structs.Post?
    
    var delegate: CustomPopupDelegate?
    
    var dropDownTag = -1
    var titleText = "Create New Post"
    
    var didSetAlreadySelected = false
    
    var actionType:CustomPopupActionType = .create
    
    override func viewDidLoad() {
        registerForKeyboardNotifications()
        
        lblTitle.text = titleText

        vContentContainer.layer.cornerRadius = 8
        
        vContentContainer.layer.borderWidth = 1
        vContentContainer.layer.borderColor = UIColor.gray.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        vBackground.addGestureRecognizer(tap)
        
        btnAction.layer.cornerRadius = 10
        
        didSetAlreadySelected = true
        initView()
    }
    
    //Mark Class Methods
    func initView(){
        switch actionType {
        case .create:
            btnAction.setTitle("Create", for: .normal)
            break
            
        case .edit:
            btnAction.setTitle("Edit", for: .normal)
            tfTitle.text = postToEdit?.title
            tfDescription.text = postToEdit?.body
            break

        default:
            break
        }
    }
    
    class func open(title:String,
                    post:Structs.Post?,
                    delegate:CustomPopupDelegate,
                    actionType:CustomPopupActionType){
        
        dropDown = CustomPopup(nibName: "CustomPopup", bundle: Bundle.main)
        dropDown?.delegate = delegate
        dropDown?.titleText = title
        dropDown?.modalPresentationStyle = .custom
        dropDown?.transitioningDelegate = dropDown
        dropDown?.actionType = actionType
        dropDown?.postToEdit = post
        if dropDown != nil {
            UIApplication.shared.keyWindow?.rootViewController?.present(dropDown!, animated: true, completion: nil)
        }
    }
    
    @objc func close() {
        dropDownTag = -1
        if CustomPopup.dropDown != nil {
            CustomPopup.dropDown?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Keyboard Methods
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: API Methods
    func createPost(title:String, body:String, userId:Int, completion: @escaping (Bool) -> Void){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts"
        
        var params: [String : AnyObject] = [:]
        params["title"] = title as AnyObject
        params["body"] = body as AnyObject
        params["userId"] = userId as AnyObject

        RequestManager.sharedManager.post(url: url, parameters: params, headers: nil, raw: false, loading: false) { response in
            self.hideProgressBar()
            self.postDict = response
            completion(true)
        } failure: { error in
            self.hideProgressBar()
        }
    }
    
    func editPost(id:String, title:String, body:String, userId:Int, completion: @escaping (Bool) -> Void){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts/\(id)"
        
        var params: [String : AnyObject] = [:]
        params["title"] = title as AnyObject
        params["body"] = body as AnyObject
        params["userId"] = userId as AnyObject
        
        RequestManager.sharedManager.put(url: url, parameters: params, raw: false, loading: false) { response in
            self.hideProgressBar()
            
            self.postDict = response
            completion(true)
        } failure: { error in
            self.hideProgressBar()
        }
    }
        
    // MARK: Action Handlers
    @IBAction func btnCloseAction(_ sender: Any) {
        close()
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
        if let titleStr = tfTitle.text, titleStr != "", let bodyStr = tfDescription.text, bodyStr != "" {
            
            switch actionType {
            case .create:
                createPost(title:titleStr, body:bodyStr, userId: 1) { success in
                    self.hideProgressBar()
                    if success{
                        self.delegate?.didPerformAction(post: self.postDict, actionType:self.actionType)
                        self.close()
                    }
                    else{
                        //Show Not Success Error
                    }
                }
                break
                
            case .edit:
                editPost(id: postToEdit?.id ?? "N/A", title:titleStr, body:bodyStr, userId: 1) { success in
                    self.hideProgressBar()
                    if success{
                        self.delegate?.didPerformAction(post: self.postDict, actionType:self.actionType)
                        self.close()
                    }
                    else{
                        //Show Failure Error
                    }
                }
                break
                
            default:
                break
            }
        }
        else{
            btnAction.shake()
        }
    }
}
