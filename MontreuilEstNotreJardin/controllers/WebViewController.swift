//
//  WebViewController.swift
//  MontreuilEstNotreJardin
//
//  Created by laurent aubourg on 17/02/2022.
//

import UIKit
import WebKit
class WebViewController: UIViewController {
   
    @IBOutlet weak var webView: WKWebView!
    var type:String?
    let presentationUrl = URL(string: "https://www.youtube.com/watch?v=H_etS_uYUZg")!
     var url:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if(type == "presentation"){
            url = presentationUrl
        }
        guard url != nil else{return}
        webView.load(URLRequest(url:url!))
    }
    func showPresentation (){
        url = presentationUrl
        webView.load(URLRequest(url:url!))
    }

}
