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
    @IBOutlet weak var btn_Settings: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hides navigation bar everywhere
         self.navigationController?.navigationBar.isHidden = true
     }
    
    //MARK: Begin button
    @IBAction func act_startTest(_ sender: UIButton)
    {
            UserDefaults.standard.set("10.38.37.146", forKey: "serverAddress")
        
            
        
            let alert = UIAlertController(title: "Enter Patient ID", message: "Please enter the patient's ID.", preferredStyle: .alert)
        
            alert.addTextField { (textField) -> Void in textField.text = "" }
            
            let defaultAction = UIAlertAction(title: "Continue", style: .default, handler: {

                [unowned self] (action) -> Void in
            
                let textField = alert.textFields![0] as UITextField
            
                if(textField.text != "")
                {
                    
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
    
    //MARK: Settings button
    @IBAction func act_openSettings(_ sender: Any) {
        //except when we open the settings menu
        self.navigationController?.navigationBar.isHidden = false
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


