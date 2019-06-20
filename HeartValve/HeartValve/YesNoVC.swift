//
//  YesNoVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class YesNoVC: UIViewController{
    
    let userManager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var answer = SurveyAnswer()

    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var trueBtn: UIButton!
    @IBOutlet weak var falseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavTitle();

        nextBtn.layer.cornerRadius = 5
        nextBtn.layer.borderWidth = 1
        nextBtn.layer.borderColor = UIColor.appBlue().cgColor
        nextBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)

        answer?.questionId = surveyQuestion?.questionId
        answer?.categoryId = nil
        answer?.optionId = nil
        answer?.answerText = "Yes"

        questionLabel.text = surveyQuestion?.questionText
        
        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("Yes"){
                    answer?.optionId = option.optionId
                }
            }
        }
    }
    
    func back(sender: UIBarButtonItem) {
        
        print("Display alert here")
        print("Display alert here")
        
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        print(numberOfViewControllers as Any)

        if (numberOfViewControllers == 0){
            print("Display alert here")
            print("Display alert here")

        }
        else{
            self.navigationController?.popViewController(animated: true);
        
        }
    
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AudioPlayer.speak(questionLabel.text, with: self.synthesizer)
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
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        return
    }
    
    func showNavTitle(){
        
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        
        if (numberOfViewControllers == 2){
            self.navigationItem.hidesBackButton = true
        }
        else{
            self.navigationItem.backBarButtonItem?.title = "Previous Question"
        }
    }
    
    @IBAction func replayVoice(_ sender: Any) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        synthesizer = AVSpeechSynthesizer()
        AudioPlayer.speak(questionLabel.text, with: self.synthesizer)
    }
    
    @IBAction func trueBtnPressed(_ sender: AnyObject) {
        
        answer?.answerText = "Yes"
        
        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("Yes"){
                    answer?.optionId = option.optionId
                }
            }
        }
        let answerList = NSMutableArray()
        answerList.add(answer!)
        
        let hud = Utility.getHUDAdded(to: self.view, withText: "Loading...")
        hud?.show(true)
        
        self.getNextQuestion(surveyQuestion?.surveyId as! Int, questionId: surveyQuestion?.questionId as! Int, answers: answerList, manager: userManager){
            (questionOptions, surveyQuestion) in
            
            hud?.hide(true)
            print("Post Survey Answers")
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }

    }
    
    @IBAction func falseBtnPressed(_ sender: AnyObject) {

        answer?.answerText = "No"

        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("No"){
                    answer?.optionId = option.optionId
                }
            }
        }
        let answerList = NSMutableArray()
        answerList.add(answer!)
        
        let hud = Utility.getHUDAdded(to: self.view, withText: "Loading...")
        hud?.show(true)
        
        self.getNextQuestion(surveyQuestion?.surveyId as! Int, questionId: surveyQuestion?.questionId as! Int, answers: answerList, manager: userManager){
            (questionOptions, surveyQuestion) in
            
            hud?.hide(true)
            print("Post Survey Answers")
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }

    }
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {

        let answerList = NSMutableArray()
        answerList.add(answer!)
        
        let hud = Utility.getHUDAdded(to: self.view, withText: "Loading...")
        hud?.show(true)
        
        self.getNextQuestion(surveyQuestion?.surveyId as! Int, questionId: surveyQuestion?.questionId as! Int, answers: answerList, manager: userManager){
            (questionOptions, surveyQuestion) in
            hud?.hide(true)
            print("Post Survey Answers")
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }
    }
}
