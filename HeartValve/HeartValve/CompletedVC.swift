//
//  CompletedVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class CompletedVC: UIViewController{
    
    var synthesizer = AVSpeechSynthesizer()
    var isPsychAssessment: Bool = false
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var replayBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueBtn.layer.borderWidth = 1.0
        self.continueBtn.layer.borderColor = UIColor.appBlue().cgColor
        self.continueBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !isPsychAssessment{
            appDelegate.updateDailyAssessment(withStep: 3)
            
            AudioPlayer.speak("Thank you!  Please remain seated and prepare to take your blood pressure.", with: synthesizer)
            
            self.perform(NSSelectorFromString("NextAssessment"), with:nil, afterDelay: 12.0);

        }else{
            AudioPlayer.speak("Thank you!  Press the continue button to take your daily assessment.", with: synthesizer)

            appDelegate.setDefaultViewController()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(true)
        return
    }
    @objc func NextAssessment(){
        performSegue(withIdentifier: "GoToBP", sender: nil)
    }
    

    
    @IBAction func goToHome(_ sender: AnyObject) {
        
    }
    
    @IBAction func replayAudio(_ sender: AnyObject) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        synthesizer = AVSpeechSynthesizer()
        if !isPsychAssessment{
            
            AudioPlayer.speak("Thank you!  Press the continue button to take your blood pressure.", with: self.synthesizer)
        }else{
            AudioPlayer.speak("Thank you!  Press the continue button to take your daily assessment.", with: self.synthesizer)
        }
    }
}
