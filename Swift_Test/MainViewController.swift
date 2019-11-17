/* MARK: README
/ Start here if you are looking to modify this app - I added a lot of mark statements so that it's easy to find functions.
/ I started building this app knowing NOTHING about Swift and ended up semi-competent; if some of the parts aren't up to standard
/ its because I was learning along the way. I tried my best to maintain a good programming style throughout. In any case, enjoy!
/ P.S - it says "Shashank Sastri" instead of Rosty Hnatyshyn at the top of every file because I used my roommate's laptop while writing
/ this.
/ Some additional notes:
/ The if #avaliable clauses were forced on me by Swift
*/

import UIKit
import MetalKit
import ModelIO

//made this a global variable so it's easy to use across views
var patientID: String = ""

//main menu view controller
class MainViewController: UIViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!

    @IBOutlet weak var btn_startTest: UIButton!
    @IBOutlet weak var btn_About: UIButton!
    @IBOutlet weak var btn_Settings: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Metal View Setup
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.backgroundColor = UIColor.white
        mtkView.frame = CGRect(x:view.bounds.maxX/2 - 125,y:150, width:250, height:250)
        mtkView.clearColor = MTLClearColor.init(red: 255, green: 255, blue: 255, alpha: 1)
        view.addSubview(mtkView)
        let device = MTLCreateSystemDefaultDevice()
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        renderer = Renderer(view: mtkView, device: device!, mode: 0)
        mtkView.delegate = renderer
        
        //MARK: First launch settings
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            self.showAlert(title: "Welcome", message: "This is the first time the app has been opened. Please check the settings page.")
            
            UserDefaults.standard.set(false, forKey: "debugMode")
            UserDefaults.standard.set("192.168.1.1", forKey: "serverAddress")
            UserDefaults.standard.set("AlphabetTest", forKey: "testSelected")
            UserDefaults.standard.set("A", forKey: "targetSymbol")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set("123456789", forKey: "doctorID")
            UserDefaults.standard.set(true, forKey: "loadLocally")
            //if it loaded in the settings screen, we'll assume that the connection is working
            UserDefaults.standard.set(false, forKey: "isConnectionSafe")
            UserDefaults.standard.set(true, forKey: "showQuestionnaire")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hides navigation bar everywhere
         self.navigationController?.navigationBar.isHidden = true
     }
    
    //MARK: Begin button
    @IBAction func act_startTest(_ sender: UIButton) {
        
        if(UserDefaults.standard.string(forKey: "doctorID")! != "")
        {
        
            let alert = UIAlertController(title: "Enter Patient ID", message: "Please enter the patient's ID.", preferredStyle: .alert)
        
            alert.addTextField { (textField) -> Void in textField.text = "" }
            
            let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: {

                [unowned self] (action) -> Void in
            
                let textField = alert.textFields![0] as UITextField
            
                if(textField.text != "")
                {
                    patientID = textField.text!
                    self.view.showBlurLoader()
                    //MARK: Test connection
                    guard let url = URL(string: "http://" + UserDefaults.standard.string(forKey: "serverAddress")! + ":5000/data/testConnection") else { return }
                    var request = URLRequest(url: url)
                    request.timeoutInterval = 3.0
                    let task = URLSession.shared.dataTask(with: request)
                        { data, response, error in
                            if let error = error
                                {
                                    print("\(error.localizedDescription)")
                                    DispatchQueue.main.async
                                        {
                                            self.view.removeBlurLoader()
                                            self.showAlert(title:"Unable to connect to server", message: "Check the server address you entered and try again.")
                                        }
                                  }
                             if let httpResponse = response as? HTTPURLResponse
                                  {
                                    print("statusCode: \(httpResponse.statusCode)")
                                    DispatchQueue.main.async
                                        {
                                            self.view.removeBlurLoader()
                                            //MARK: Segue to next view
                                            (UserDefaults.standard.bool(forKey: "showQuestionnaire")) ? self.self.performSegue(withIdentifier: "to_Questions", sender: self) : self.performSegue(withIdentifier: "to_Test", sender: self)
                                        }
                                  }
                            }
                    //task.resume()
                    self.performSegue(withIdentifier: "to_Test", sender: self)
                }
                else
                {
                    self.showAlert(title: "No ID entered", message: "Please enter a valid patient ID and try again.")
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            showAlert(title: "Invalid doctor ID.", message: "Please enter a valid doctor ID and try again.")
        }
    }
    
    //MARK: About Us button
    @IBAction func act_OpenAbout(_ sender: UIButton) {
         let alert = UIAlertController(title: "Instructions", message: "Double tap to exit the about screen. Tap once to continue through the credits.", preferredStyle: .alert)
         
        let action = UIAlertAction(title: "OK", style: .default, handler: { [unowned self] (action) -> Void in
            self.performSegue(withIdentifier: "to_AboutUs", sender: self)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: Settings button
    @IBAction func act_openSettings(_ sender: Any) {
        //except when we open the settings menu
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "to_Settings", sender: self)
    }
    
    //MARK: UI Utility functions
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}


