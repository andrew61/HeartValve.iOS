//
//  FreeTextVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class FreeTextVC: UIViewController, UITextFieldDelegate{
    
    let userManager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var answer = SurveyAnswer()
    
    @IBOutlet weak var questionTv: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavTitle();

        
        nextBtn.layer.cornerRadius = 5
        nextBtn.layer.borderWidth = 1
        nextBtn.layer.borderColor = UIColor.appBlue().cgColor
        nextBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        questionTv.text = surveyQuestion?.questionText
        
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(FreeTextVC.dismissTextPad(_:)))
        toolbarDone.items = [barBtnDone]
        textField.inputAccessoryView = toolbarDone
        textField.delegate = self
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
    
    @objc func dismissTextPad(_ sender: AnyObject){
        self.textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {
        let answerList = NSMutableArray()
        answer?.answerText = textField.text
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
