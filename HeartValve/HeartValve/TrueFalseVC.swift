//
//  TrueFalseVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class TrueFalseVC: UIViewController{
    
    let userManager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var answer = SurveyAnswer()
    
    @IBOutlet weak var questionTv: UITextView!
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
        answer?.answerText = "True"
        
        questionTv.text = surveyQuestion?.questionText
        
        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("True"){
                    answer?.optionId = option.optionId
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AudioPlayer.speak(questionTv.text, with: self.synthesizer)

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
    
    
    @IBAction func trueBtnPressed(_ sender: AnyObject) {
        trueBtn.setTitleColor(UIColor.appleBlue(), for: .normal)
        falseBtn.setTitleColor(UIColor.gray, for: .normal)
        answer?.answerText = "True"
        
        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("True"){
                    answer?.optionId = option.optionId
                }
            }
        }
    }
    
    @IBAction func falseBtnPressed(_ sender: AnyObject) {
        falseBtn.setTitleColor(UIColor.appleBlue(), for: .normal)
        trueBtn.setTitleColor(UIColor.gray, for: .normal)
        answer?.answerText = "False"
        
        for options in questionOptionsList{
            if let option = options as? SurveyQuestionOptions{
                if option.optionText.contains("False"){
                    answer?.optionId = option.optionId
                }
            }
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
