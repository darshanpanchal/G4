//
//  ApiResult.swift
//  Metis
//
//  Created by Michael Miller on 08/03/2018.
//  Copyright © 2018 Dreamr. All rights reserved.
//

import UIKit
import Bugsnag

class ApiResult: NSObject {
    var statusCode : Int?
    var data : Data?
    var errorMessage : String?
    var userMessage : ErrorHelper.CustomErrorType?
    
    init(url:URL?, statusCode:Int?, data:Data?, errorMessage:String?, userMessage:ErrorHelper.CustomErrorType?) {
        self.data = data
        self.errorMessage = errorMessage
        self.userMessage = userMessage
        self.statusCode = statusCode
        
        #if DEBUG
            print("\n------------------------------")
            print("URL: \(url?.absoluteString ?? "")")
            print("Status Code: \(statusCode ?? -1)")
            print("Error Message: \(errorMessage ?? "")")
            
            if data != nil {
                do { 
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print("Data : \(json)");
                }
                catch {
                    print("Data : \(String(describing: String(data: data!, encoding: .utf8)))");
                    let _ = NSException(name:NSExceptionName(rawValue: "ApiResult"),
                                                reason:"\(error.localizedDescription)",
                        userInfo:nil)
                   // Bugsnag.notify(exception)
                }
            }
            print("------------------------------\n")
        #endif
    }
    
}
@IBDesignable
class ProgressHud: UIView {
    fileprivate static let rootView = {
        return UIApplication.shared.keyWindow!
    }()
    
    fileprivate static let blurView:UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0.2
        return view
    }()
    fileprivate static let hudView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
        view.layoutIfNeeded()
        return view
    }()
    fileprivate static let activity:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.style = .whiteLarge
        view.hidesWhenStopped = false
        view.color = UIColor.black
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    static func show(){
        rootView.addSubview(blurView)
        self.addObserver()
        self.addActivity()
    }
    static func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name:UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc static func rotated(){
        print(UIScreen.main.bounds)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            print("landscape")
        default:
            print("Portrait")
        }
        blurView.frame = UIScreen.main.bounds
        //blurView.frame = CGRect.init(origin: .zero, size: CGSize.init(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width))
        
    }
    static func addActivity(){
        rootView.addSubview(hudView)
        hudView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        hudView.centerXAnchor.constraint(equalTo: hudView.superview!.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: hudView.superview!.centerYAnchor).isActive = true
        
        hudView.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: activity.superview!.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: activity.superview!.centerYAnchor).isActive = true
        rootView.isUserInteractionEnabled = false
        
    }
    static func hide(){
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
            rootView.isUserInteractionEnabled = true
            blurView.removeFromSuperview()
            hudView.removeFromSuperview()
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
