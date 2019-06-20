//
//  ScaleVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class ScaleVC: UIViewController{
    
    let userManager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var answer = SurveyAnswer()
    var optionId : Int = 0
    
    @IBOutlet weak var questionTv: UITextView!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavTitle();

        
        nextBtn.layer.cornerRadius = 5
        nextBtn.layer.borderWidth = 1
        nextBtn.layer.borderColor = UIColor.appBlue().cgColor
        nextBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        questionTv.text = surveyQuestion?.questionText
        
        sliderView.maximumValue = (Float(questionOptionsList.count)/10) - 0.1
        sliderView.minimumValue = 0.0
        
        if let questionOption = questionOptionsList[0] as? SurveyQuestionOptions{
            scaleLabel.text = questionOption.optionText
            optionId = questionOption.optionId as! Int
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
    
    
    @IBAction func scaleValueChanged(_ sender: AnyObject) {
        if let slider = sender as? UISlider{
            let value = (Int(slider.value * 10))
            if let questionOption = questionOptionsList[value] as? SurveyQuestionOptions{
                scaleLabel.text = questionOption.optionText
                optionId = questionOption.optionId as! Int
            }
        }
    }
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {
        
        let answerList = NSMutableArray()
        answer?.categoryId = nil
        answer?.answerText = nil
        answer?.optionId = optionId as NSNumber!
        answerList.add(answer!)
        
        let hud = Utility.getHUDAdded(to: self.view, withText: "Loading...")
        hud?.show(true)

        self.getNextQuestion(surveyQuestion?.surveyId as! Int, questionId: surveyQuestion?.questionId as! Int, answers: answerList, manager: self.userManager){
            (questionOptions, surveyQuestion) in
            hud?.hide(true)
            print("Post Survey Answers")
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }

    }
    
}
