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
}

// MARK: CollectionView Extension

extension UICollectionView {
    
    func customRegisterForCell(identifier:String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
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
    
}
// MARK: UITableViewCell Extension

extension UITableViewCell {
    func enable(on: Bool) {
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
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
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.3
        animation.values = [-20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func startLoadingAnimation(duration:CGFloat) {
        self.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.clipsToBounds = true
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: -self.bounds.width, y: -self.bounds.height, width: self.bounds.width*3, height: self.bounds.height*3)
        gradient.colors = [UIColor.clear.cgColor, UIColor.gray.cgColor, UIColor.gray.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0, 0.5, 0.5, 1]
        gradient.startPoint = CGPoint(x: -1, y: 0.4)
        gradient.endPoint = CGPoint(x: 0, y: 0.6)
        
        self.layer.addSublayer(gradient)

        let animation1 = CABasicAnimation(keyPath: "startPoint")
        animation1.fromValue = CGPoint(x: -1, y: 0.4)
        animation1.toValue = CGPoint(x: 1, y: 0.4)
        animation1.duration = CFTimeInterval(duration)
        animation1.repeatCount = Float.infinity
        gradient.add(animation1, forKey: "anim1")
        
        let animation2 = CABasicAnimation(keyPath: "endPoint")
        animation2.fromValue = CGPoint(x: 0, y: 0.6)
        animation2.toValue = CGPoint(x: 2, y: 0.6)
        animation2.duration = CFTimeInterval(duration)
        animation2.repeatCount = Float.infinity
        gradient.add(animation2, forKey: "anim2")
    }
    
    func stopLoadingAnimation() {
        self.layer.removeAllAnimations()
        if let sublayers = self.layer.sublayers {
            for case let sublayer as CAGradientLayer in sublayers {
                sublayer.removeAllAnimations()
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func addGradientBackground(colors: [CGColor], startPoint:CGPoint, endPoint:CGPoint) {
        addGradientBackgroundWithFrame(colors: colors, startPoint: startPoint, endPoint: endPoint, frame: self.bounds)
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
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    
}

// MARK: UILabel extension

extension UILabel {

    func getActualLineNumber() -> Int {
        let height = self.text?.height(withConstrainedWidth: self.frame.size.width, font: self.font) ?? 0
        return lroundf(Float(height/self.font.lineHeight))
    }
    
    func setHTMLFromString(htmlText: String, fontSize:CGFloat = 15) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(fontSize)\">%@</span>", htmlText)

        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
            documentAttributes: nil)

        self.attributedText = attrStr
    }
}

// MARK: Int extension

extension Int {
    
    func toStringwithSeparator(_ separator:String) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = separator
        formatter.numberStyle = .decimal
        return formatter.string(for: self)!
    }
    
}

// MARK: UIImageView extension

extension UIImageView {

    func tint(color: UIColor) {
        self.image = self.image?.withRenderingMode(.automatic)
        self.tintColor = color
    }
    
}

// MARK: String extension

extension String {
    
    static func emptyOrNil(string: String?) -> Bool {
        return string == nil || string == ""
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizeFirstLetter()
    }
    
    func isEmptyString() -> Bool {
        return self == ""
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func safeURL() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
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
