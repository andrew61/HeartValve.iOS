//
//  BehavioralSurveyVC.swift
//  HeartValve
//
//  Created by Tachl on 2/16/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class BehavioralSurveyVC: UIViewController{
    let userManager = UserManager()
    let synthesizer = AVSpeechSynthesizer()
    
    var welcomeText = String()

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var surveyBtn: UIButton!
    @IBOutlet weak var replayBtn: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.surveyBtn.layer.borderWidth = 1.0
        self.surveyBtn.layer.borderColor = UIColor.appBlue().cgColor
        self.surveyBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        userManager.getUser(){
            (user, error) in
            
            if error == nil{
                if user?.firstName == nil{
                    self.welcomeText = "Hello!  It's time to start your well being survey. This process should take less than 10 minutes. Press the button on your screen to get started."
                    
                    //AudioPlayer.speak("Hello!  It's time to start your daily assessment. This process should take less than 10 minutes. Press the button on your screen to get started.", with: self.synthesizer)
                }else{
                    self.welcomeLabel.text = "Welcome \((user?.firstName)!)"
                    
                    self.welcomeText = "Hello \((user?.firstName)!)!  It's time to start your well being survey. This process should take less than 10 minutes. Press the button on your screen to get started.".replacingOccurrences(of: "slnc", with: " ")
                    
                    //AudioPlayer.speak(spokenString, with: self.synthesizer)
                }
            }else{
                self.welcomeText = "Hello! It's time to start your well being survey. This process should take less than 10 minutes.  Press the button on your screen to get started."
                
                //AudioPlayer.speak("Hello! It's time to start your daily assessment. This process should take less than 10 minutes.  Press the button on your screen to get started.", with: self.synthesizer)
            }
            
            AudioPlayer.speak(self.welcomeText, with: self.synthesizer)
        }
        
        self.welcomeLabel.isHidden = false
        self.surveyBtn.isHidden = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        return
    }

    @IBAction func takeBehavioralSurvey(_ sender: Any) {
        self.getQuestion(5, manager: userManager){
            (questionOptions, surveyQuestion) in
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }
    }

    @IBAction func replayAudio(_ sender: AnyObject) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        AudioPlayer.speak(self.welcomeText, with: self.synthesizer)
    }
}

