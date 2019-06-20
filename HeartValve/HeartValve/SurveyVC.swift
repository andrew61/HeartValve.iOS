//
//  SurveyVC.swift
//  HeartValve
//
//  Created by Tachl on 12/9/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SurveyVC: UIViewController{
    
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
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate updateDailyAssessmentWithStep:3];
        
        
        userManager.getUser(){
            (user, error) in
            
            if error == nil{
                if user?.firstName == nil{
                    self.welcomeText = "Hello!  It's time to start your daily assessment. This process should take less than 10 minutes. Press the button on your screen to get started."
                    
                    //AudioPlayer.speak("Hello!  It's time to start your daily assessment. This process should take less than 10 minutes. Press the button on your screen to get started.", with: self.synthesizer)
                }else{
                    self.welcomeLabel.text = "Welcome \((user?.firstName)!)"
                    
                    self.welcomeText = "Hello \((user?.firstName)!)!  It's time to start your daily assessment. This process should take less than 10 minutes. Press the button on your screen to get started.".replacingOccurrences(of: "slnc", with: " ")
                    
                    //AudioPlayer.speak(spokenString, with: self.synthesizer)
                }
            }else{
                self.welcomeText = "Hello! It's time to start your daily assessment. This process should take less than 10 minutes.  Press the button on your screen to get started."
                
                //AudioPlayer.speak("Hello! It's time to start your daily assessment. This process should take less than 10 minutes.  Press the button on your screen to get started.", with: self.synthesizer)
            }
            
            AudioPlayer.speak(self.welcomeText, with: self.synthesizer)
        }
        
        self.welcomeLabel.isHidden = false
        self.surveyBtn.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.updateDailyAssessment(withStep: 2)
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
    
    @IBAction func takeDailySurvey(_ sender: Any) {
        self.getQuestion(3, manager: userManager){
            (questionOptions, surveyQuestion) in
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }
    }
    
    @IBAction func replayAudio(_ sender: AnyObject) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        AudioPlayer.speak(self.welcomeText, with: self.synthesizer)
    }
}

// MARK: - Global Variables

struct GlobalVariables{
    static var currentSurvey = Survey()
}
// MARK: - Enums

enum SurveyType: Int{
    case Completed = 0, YesNo = 1, TrueFalse = 2, Scale = 3, Text = 4, Number = 5, DropDown = 6, MCSingle = 7, MCMulti = 8, DateTime = 9, Date = 10, Category = 11, ImageMap = 12, ImageUpload = 13
}

// MARK: - Extensions

public extension UIViewController{
    func displaySurveyViewController(_ type: Int, question: SurveyQuestion, options: NSMutableArray){
        if let surveyType = SurveyType(rawValue: type){

            switch surveyType{
            case .YesNo:
                
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "YesNoVC") as! YesNoVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options

                 self.navigationController!.pushViewController(surveyView, animated: true)

            case .TrueFalse:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "TrueFalseVC") as! TrueFalseVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .MCSingle:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "SingleChoiceVC") as! SingleChoiceVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .MCMulti:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "MultipleChoiceVC") as! MultipleChoiceVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .Number:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "NumberVC") as! NumberVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .Text:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "FreeTextVC") as! FreeTextVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .Scale:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "ScaleVC") as! ScaleVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .ImageUpload:
                let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                surveyView.surveyQuestion = question
                surveyView.questionOptionsList = options
                
                self.navigationController!.pushViewController(surveyView, animated: true)
            case .Completed:
                
                if(JNKeychain.loadValue(forKey: "isDailyAssessmentSurvey") != nil){
                    
                    JNKeychain.deleteValue(forKey: "isDailyAssessmentSurvey")
                    let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "CompletedVC") as! CompletedVC
                    if(GlobalVariables.currentSurvey?.surveyId == 5){
                        surveyView.isPsychAssessment = true
                    }
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window.rootViewController = surveyView
                    
//                    self.navigationController?.present(surveyView, animated: true, completion: nil)
                }
                else{
                    let surveyView = self.storyboard?.instantiateViewController(withIdentifier: "RevealVC")
                    self.present(surveyView!, animated: true, completion: nil)
                }
                
            default: break
            }
        }
    }
    
    func getQuestion(_ surveyId: Int, manager: UserManager, completion: @escaping (NSMutableArray, SurveyQuestion) -> ()){
        manager.getSurvey(surveyId as NSNumber ){
            (survey, error) in
            GlobalVariables.currentSurvey = survey
            manager.getSurveyQuestion(surveyId as NSNumber ){
                (surveyQuestion, error) in
                if surveyQuestion == nil{
                    self.displaySurveyViewController(0, question: SurveyQuestion(), options: NSMutableArray())
                }else{
                    manager.getSurveyQuestionOptions((surveyQuestion?.questionId)!){
                        (options, error) in
                        
                        let group = DispatchGroup()
                        
                        for case let option as SurveyQuestionOptions in options! {
                            if option.imagePath != nil {
                                group.enter()
                                manager.getImage(option.imagePath, completion: { (image, error) in
                                    option.image = image
                                    group.leave()
                                })
                            }
                        }
                        
                        DispatchQueue.global().async {
                            group.wait()
                            DispatchQueue.main.async {
                                completion(options!, surveyQuestion!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNextQuestion(_ surveyId: Int, questionId: Int, answers: NSMutableArray, manager: UserManager, completion: @escaping (NSMutableArray, SurveyQuestion) -> ()){
        manager.postSurveyAnswers(answers, survey: surveyId as NSNumber, question: questionId as NSNumber!){
            error in
            self.getQuestion(surveyId, manager: manager){
                (questionOptions, question) in
                completion(questionOptions, question)
            }
        }
    }
    
    func getNextQuestion(_ surveyId: Int, questionId: Int, image: UIImage, manager: UserManager, completion: @escaping (NSMutableArray, SurveyQuestion) -> ()){
        manager.postSurveyImage(image, survey: surveyId as NSNumber, question: questionId as NSNumber){
            error in
            self.getQuestion(surveyId, manager: manager){
                (questionOptions, question) in
                completion(questionOptions, question)
            }
        }
    }
}

