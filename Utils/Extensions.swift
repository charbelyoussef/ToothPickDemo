//
//  Extensions.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/14/21.
//

import UIKit
import JGProgressHUD

// MARK: UIViewController extension

extension UIViewController {
    
    private static var coConfig = [String:Bool]()
    
    var FuncCalledOnce:Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIViewController.coConfig[tmpAddress] ?? false
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIViewController.coConfig[tmpAddress] = newValue
        }
    }
    
    func callOnce(funcToCall: () -> ()) {
        if !FuncCalledOnce {
            FuncCalledOnce = true
            funcToCall()
        }
    }
    
    /**
     Adds an action to the view controller that dismisses the keyboard on click.
     */
    func setupDismissOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        // Add the action to happen whenever the view is clicked, this case to dismiss keyboard
        self.view.addGestureRecognizer(tap)
    }
    
    /**
     Checks if the segueway exists for the given identifier.
     - parameter identifier: The identifier string of the segue.
     - Returns:
     canPerform: Bool value to determine if the segue exists for the given identifier.
     */
    func canPerformSegue(identifier: String) -> Bool {
        guard let identifiers = value(forKey: "storyboardSegueTemplates") as? [NSObject] else {
            return false
        }
        
        let canPerform = identifiers.contains { (object) -> Bool in
            if let id = object.value(forKey: "_identifier") as? String {
                if id == identifier {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }
        
        return canPerform
    }
    
    /**
     Perform the segueway if the segueway exists for the given identifier.
     - parameter identifier: The identifier string of the segue.
     */
    func performSegueIfPossible(identifier: String) {
        if canPerformSegue(identifier: identifier) {
            performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    /**
     Registers callback events for when the keyboard will open and will close.
     Override keyboardWillShow() and keyboardWillHide() to implement the needed logic.
     */
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Override this function in ViewController for listening to notification
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Override this function in ViewController for listening to notification
    }
    
    /**
     Dismisses the keyboard in the current view controller.
     */
    @objc func dismissKeyboard() {
        // dismisses the keyboad if it was open
        self.view.endEditing(true)
    }
    
    /**
     Shows a progress bar with a custom message.
     - parameter message: The message to display in the progress bar.
     */
    @objc func showProgressBar(message: String){
        let hud = JGProgressHUD(style: .light)
        hud.parallaxMode = JGProgressHUDParallaxMode.alwaysOn
        hud.textLabel.text = message
        hud.show(in: self.view)
    }
    
    /**
     Hides the progress bar.
     */
    @objc func hideProgressBar(){
        let huds = JGProgressHUD.allProgressHUDs(in: self.view)
        if(huds.count > 0){
            for hud in huds {
                hud.dismiss(animated: true)
            }
        }
    }
    
    /**
     Shows an alert with a message.
     */
    func showAlert(message:String){
        let alert = UIAlertController(title: "ToothPick", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))

        self.present(alert, animated: true)
    }
    
    /**
     Shows an alert popup with a custom message and optional cancel button.
     - parameter title: The title of the error popup.
     - parameter message: The message to display.
     - parameter actionTitle: The text of the Confirm button.
     - parameter cancelTitle: The text of the Cancel button. This is optional, and if set as nil the Cancel button will not be added to the popup.
     - parameter completionBlock: The action that happens when clicking the confirmation button. This can be nil.
     */
    func showActionSeetWithCompletion(title:String,
                                 message:String,
                                 actionTitle:String = "Delete",
                                 cancelTitle:String = "Cancel",
                                 completionBlock: (() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: actionTitle, style: .destructive) { action in
            completionBlock?()
        }
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view

        present(alert, animated: true, completion: nil)
    }
}

// MARK: UIColor Extension
extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let red   = CGFloat(Int(color >> 16) & 0x000000FF) / 255.0
        let green = CGFloat(Int(color >> 8) & 0x000000FF) / 255.0
        let blue  = CGFloat(Int(color) & 0x000000FF) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// MARK: TableView Extension
extension UITableView {
    
    func customRegisterForCell(identifiers: [String]) {
        for identifier in identifiers {
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
    
    func scrollToBottom(){
        let bottomOffset = CGPoint(x: 0, y: contentSize.height)
        setContentOffset(bottomOffset, animated: true)
    }
}

// MARK: UIView extension
extension UIView {
    func addCornerRadius(corners: UIRectCorner, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func addCornerRadiusWithBorder(radius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func rounded() {
        if self.frame.size.width != self.frame.size.height {
        }
        self.layer.cornerRadius = self.frame.size.height/2.0
        self.layer.masksToBounds = true
    }
    
    func addGradientBackgroundWithFrame(colors: [CGColor], startPoint:CGPoint, endPoint:CGPoint, frame:CGRect) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addShadow(radius: CGFloat, offset: CGSize, color: UIColor = .lightGray, opacity: Float = 0.5) {
        self.layer.shadowPath =
            UIBezierPath(roundedRect: self.bounds,
                         cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func addShadowWithTransparency(radius: CGFloat, offset: CGSize, opacity: Float = 0.5) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}

extension UINavigationController {
    
    func popToViewController(ofClass: AnyClass){
        
        if let vc = self.getViewControllerInStack(ofClass: ofClass) {
            popToViewController(vc, animated: true)
        }
        else{
            print("Couldn't Find Class In Stack")
        }
    }
    
    func getViewControllerInStack(ofClass: AnyClass) -> UIViewController?{
        for vc in self.viewControllers as [UIViewController] {
            if vc.isKind(of: ofClass) {
                return vc
            }
        }

        return nil
    }
    
}
