//
//  WebViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 17/02/2022.
//

import UIKit
import WebKit
class WebViewController: UIViewController {
   
    //MARK: - IBOutlets
    
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - properties
    
    var resource:Resource? = nil
    var type:String?
    let presentationUrl = URL(string: "https://www.youtube.com/watch?v=H_etS_uYUZg")!
    var url:URL?
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard resource != nil else{return}
        webView.load(URLRequest(url:URL(string:resource!.url)!))
    }
    
    // MARK: - load the contant of the web page in webView
    
    func showPresentation (){
        url = presentationUrl
        webView.load(URLRequest(url:url!))
    }

}
