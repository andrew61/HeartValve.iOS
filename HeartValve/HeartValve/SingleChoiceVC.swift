//
//  SingleChoiceVC.swift
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

class SingleChoiceVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let usermanager = UserManager()
    
    var synthesizer = AVSpeechSynthesizer()
    var surveyQuestion = SurveyQuestion()
    var questionOptionsList = NSMutableArray()
    var answer = SurveyAnswer()
    var optionId : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavTitle();

        
//        nextBtn.layer.cornerRadius = 5
//        nextBtn.layer.borderWidth = 1
//        nextBtn.layer.borderColor = UIColor.appBlue().cgColor
        nextBtn.setBackgroundImage(Utility.image(with: UIColor.appYellow()), for: UIControl.State.highlighted)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sizeToFit()
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.reloadData()
        
        questionLabel.text = surveyQuestion?.questionText
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
        
        if let questionOptions = questionOptionsList[(indexPath as NSIndexPath).item] as? SurveyQuestionOptions{
            cell.choiceLabel.text = questionOptions.optionText
            //cell.choiceBtn.isHidden = !questionOptions.selected
            cell.optionId = questionOptions.optionId as! Int
            cell.choiceIcon.image = questionOptions.image
            
            if questionOptions.image != nil {
                cell.choiceLabelLeadingConstraint.constant += cell.choiceIconWidthConstraint.constant
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? ChoiceCell{
            let row = (indexPath as NSIndexPath).row
            if let questionOptions = questionOptionsList[row] as? SurveyQuestionOptions{
                for options in questionOptionsList{
                    if let option = options as? SurveyQuestionOptions{
                        option.selected = false
                    }
                    
                }
                synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
                synthesizer = AVSpeechSynthesizer()
                AudioPlayer.speak(questionOptions.optionText + ".If this is the correct answer, please press the blue continue button at the bottom of the screen.", with: synthesizer)

                questionOptions.selected = true
                
                //cell.choiceBtn.isHidden = false
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                
                optionId = questionOptions.optionId as! Int
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = (indexPath as NSIndexPath).row
        if let cell = self.tableView.cellForRow(at: indexPath) as? ChoiceCell{
            //cell.choiceBtn.isHidden = true
            cell.accessoryType = UITableViewCell.AccessoryType.none
            if let questionOptions = questionOptionsList[row] as? SurveyQuestionOptions{
                questionOptions.selected = false

            }

        }
    }
    
    @IBAction func replayVoice(_ sender: Any) {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        synthesizer = AVSpeechSynthesizer()
        AudioPlayer.speak(questionLabel.text! + ". Push the blue continue button when you have selected an answer.", with: self.synthesizer)
    }
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {
        
        let answerList = NSMutableArray()
        answer?.categoryId = nil
        answer?.answerText = nil
        answer?.optionId = optionId as NSNumber!
        answerList.add(answer!)
        
        let hud = Utility.getHUDAdded(to: self.view, withText: "Loading...")
        hud?.show(true)
        
        self.getNextQuestion(surveyQuestion?.surveyId as! Int, questionId: surveyQuestion?.questionId as! Int, answers: answerList, manager: usermanager){
            (questionOptions, surveyQuestion) in
            hud?.hide(true)
            print("Post Survey Answers")
            self.displaySurveyViewController(surveyQuestion.questionTypeId as! Int, question: surveyQuestion, options: questionOptions)
        }
    }
}
