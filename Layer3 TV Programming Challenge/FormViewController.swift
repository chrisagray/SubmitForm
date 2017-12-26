//  FormViewController.swift
//  Layer3 TV Programming Challenge

import UIKit
import WebKit

class FormViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, UIScrollViewDelegate {
    
    var wkWebView: WKWebView!
    
    let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
    
    let submitNotification = Notification.Name("submitNotification")

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: submitNotification, object: nil, queue: nil, using: catchNotification)
        
        setUpWebView()
        let url = Bundle.main.url(forResource: "index", withExtension: "html")
        wkWebView.load(URLRequest(url: url!))
    }
    
    private func setUpWebView() {
        
        let controller = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        
        //Add scripts
        let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        controller.addUserScript(viewportScript)
        
        //Add listener and set content controller
        controller.add(self, name: "JSListener")
        configuration.userContentController = controller
        
        wkWebView = WKWebView(frame: view.bounds, configuration: configuration)
        wkWebView.uiDelegate = self
        wkWebView.contentMode = .scaleToFill
        wkWebView.scrollView.delegate = self
        
        view = wkWebView
    }
    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return nil
//    }
    
    private func catchNotification(notification: Notification) -> Void {
        if let _ = notification.object as? String {
            wkWebView?.evaluateJavaScript("alert('Success!')", completionHandler: nil)
        } else {
            wkWebView?.evaluateJavaScript("alert('Error! Invalid user input')", completionHandler: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        alertController.view.layoutIfNeeded()
        present(alertController, animated: true)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NotificationCenter.default.post(name: submitNotification, object: message.body)
    }
}
