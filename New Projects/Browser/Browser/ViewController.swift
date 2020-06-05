import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {

    var favouriteCount = 1
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var searchField: NSTextField!
    
    
    @IBOutlet weak var favouriteData: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func SearchClick(_ sender: Any) {
        let url = URL(string: searchField.stringValue)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    @IBAction func Add(_ sender: Any) {
        if (webView.url?.absoluteString ?? "") == "" {
            return
        }
        favouriteData.stringValue = favouriteData.stringValue + "#" + String(favouriteCount) + " " + (webView.url?.absoluteString ?? "") + "\n"
        favouriteCount += 1
    }
    
}
