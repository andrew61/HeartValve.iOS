//
//  MultipleChoiceVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

import Foundation

class MultipleChoiceVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var questionTv: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let userManager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var chosenAnswers = Set<SurveyQuestionOptions>()
    
    var list = [NSNumber]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavTitle();

        
        nextBtn.layer.cornerRadius = 5
        nextBtn.layer.borderWidth = 1
        nextBtn.layer.borderColor = UIColor.appBlue().cgColor
        nextBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sizeToFit()
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        
        questionTv.text = surveyQuestion?.questionText
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
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.questionOptionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell", for: indexPath) as! ChoiceCell
        let row = (indexPath as NSIndexPath).row
        
        if let questionOptions = questionOptionsList[row] as? SurveyQuestionOptions{
            cell.choiceLabel.text = questionOptions.optionText
            cell.choiceBtn.isHidden = !questionOptions.selected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChoiceCell
        let row = (indexPath as NSIndexPath).row
        print("Did Select!")


        if let questionOptions = questionOptionsList[row] as? SurveyQuestionOptions{
            if cell.choiceBtn.isHidden{
                cell.choiceBtn.isHidden = false
                chosenAnswers.insert(questionOptions)
                questionOptions.selected = true
                
                synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                AudioPlayer.speak(questionOptions.optionText, with: self.synthesizer)
            }else{
                cell.choiceBtn.isHidden = true
                if chosenAnswers.contains(questionOptions){
                    chosenAnswers.remove(questionOptions)
                    questionOptions.selected = false
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {
        let answerList = NSMutableArray()

        for answer in chosenAnswers{
            let surveyAnswer = SurveyAnswer()
            surveyAnswer?.answerText = answer.optionText
            surveyAnswer?.optionId = answer.optionId
            surveyAnswer?.categoryId = nil
            answerList.add(surveyAnswer!)
        }
        
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

extension Array where Element: Equatable{
    mutating func removeObject(object: Element){
        if let index = index(of: object){
            remove(at: index)
        }
    }
}
