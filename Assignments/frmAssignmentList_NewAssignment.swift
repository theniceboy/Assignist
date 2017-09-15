//
//  frmAssignmentList_NewAssignment.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import UserNotifications

var _EDIT_ID_: Int = 0
var _EDIT_MODE_: Bool = false


func registerNotification () {
    let notificationSettings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
    UIApplication.shared.registerUserNotificationSettings(notificationSettings)
}

class frmAssignmentList_NewAssignment: UIViewController, UITextViewDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate {

    
    
    // MARK: - Outlets
    
    // Controls
    
    @IBOutlet weak var vTopBar: UIView!
    
    @IBOutlet weak var btnAdd: ZFRippleButton!
    
    @IBOutlet weak var btnSelectSubject: ZFRippleButton!
    
    @IBOutlet weak var tfTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var vClear: UIView!
    @IBOutlet weak var vTitleBlocker: UIView!
    
    @IBOutlet weak var vSuggestions: UIView!
    
    @IBOutlet weak var vComments: UIView!
    @IBOutlet weak var tvComments: UITextView!
    @IBOutlet weak var lbPlaceHolder_tfComments: UILabel!
    
    @IBOutlet weak var sgcSetPriority: BetterSegmentedControl!
    
    @IBOutlet weak var lbDueDate: UILabel!
    @IBOutlet weak var vSetDueDayTime: UIView!
    @IBOutlet weak var btnSetDueDate: ZFRippleButton!
    
    @IBOutlet weak var sgcSetDueTime: BetterSegmentedControl!
    
    @IBOutlet weak var vSetNotification: UIView!
    @IBOutlet weak var switchSetNotification: SevenSwitch!
    //@IBOutlet weak var btnSetNotification: ZFRippleButton!
    
    @IBOutlet weak var btnDeleteAssignment: ZFRippleButton!
    
    let coachMarksController = CoachMarksController()

    
    // Constraints
    
    @IBOutlet weak var _layout_vClearWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var _layout_vSuggestionsHeightAnchor: NSLayoutConstraint!
    
    // MARK: - Variables
    
    // MARK: UI
    
    var dropSelectSubject = DropDown()
    var _suggestionPositions: [CGFloat] = [65, 113, 165]
    
    // MARK: Class Open Var
    
    var showSuggestions: Bool = false
    var suggestionCount: Int = 0
    var assignmentItem: AssignmentItem = AssignmentItem()
    
    // MARK: Variables used for private functions
    
    var sgcSetDueTime_lastSelected: Int = 0
    var sgcSetDueTime_firstOpens: Bool = false
    
    // MARK: For btnAdd_Tapped (_:)
    
    var tmpSubject: String = ""
    var tmpPriority: Int = 0
    var tmpDueDate: Date = Date()
    var notificationOn: Bool = true
    var notifyDateTime: Date = Date()
    
    var editAssignment: AssignmentItem = AssignmentItem()
    
    // MARK: - System Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachMarksController.dataSource = self
        
        //curFrmAssignmentList_NewAssignment = self
        
        initializeUI()
        configureKeyboardHidingGestures()
        
        if (assignmentList.count > 0 && false) {
            showSuggestions = true
        }
        
        if (_EDIT_MODE_) {
            
            editAssignment = assignmentList[getRowNum_AssignmentList(id: _EDIT_ID_)]
            
            btnDeleteAssignment.isHidden = editAssignment.fromFocus
            vTitleBlocker.isHidden = !editAssignment.fromFocus
            
            btnAdd.setTitle("Done", for: .normal)
            
            btnSelectSubject.setTitle(editAssignment.subject, for: .normal)
            tmpSubject = editAssignment.subject
            updateTopBarUI()
            
            tfTitle.text = editAssignment.title
            showClearButton()
            
            tvComments.text = editAssignment.comments
            
            do {
                try sgcSetPriority.setIndex(UInt(editAssignment.priority))
            } catch { }
            
            vSetDueDayTime.isHidden = editAssignment.fromFocus
            
            tmpDueDate = editAssignment.dueDate
            sgcSetDueTime_firstOpens = true
            if (tmpDueDate.hour == 7 && tmpDueDate.minute == 30) {
                do {
                    try sgcSetDueTime.setIndex(0)
                } catch { }
            } else if (tmpDueDate.hour == 11 && tmpDueDate.minute == 59) {
                do {
                    try sgcSetDueTime.setIndex(1)
                } catch { }
            } else {
                do {
                    try sgcSetDueTime.setIndex(2)
                } catch { }
            }
            sgcSetDueTime_firstOpens = false
            
            notificationOn = false
            
            for item in UIApplication.shared.scheduledLocalNotifications! {
                if (item.userInfo!["id"] as! Int == _EDIT_ID_) {
                    notifyDateTime = item.fireDate!
                    notificationOn = true
                    break
                }
            }
            switchSetNotification.setOn(notificationOn, animated: false)
        } else {
            vTitleBlocker.isHidden = true
            btnDeleteAssignment.isHidden = true
            
            btnAdd.setTitle("Add", for: .normal)
            tfTitle.text = ""
            hideClearButton()
            tvComments.text = ""
            do {
                try sgcSetDueTime.setIndex(0)
            } catch { }
            
            tmpDueDate = Date(year: Date.tomorrow().year, month: Date.tomorrow().month, day: Date.tomorrow().day, hour: 7, minute: 30, second: 0)
            
            notificationOn = true
            updateNotificationTime ()
        }
        
        if (tvComments.text != "") {
            lbPlaceHolder_tfComments.isHidden = true
        } else {
            lbPlaceHolder_tfComments.isHidden = false
        }
        
        updateDateTime()
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "addedSubject"), object:nil, queue:nil, using:catchNotification)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (!_EDIT_MODE_) {
            showSuggestionArea()
        }
        let intro_frmNewAssignment = UserDefaults.standard.object(forKey: "intro_frmNewAssignment")
        if (intro_frmNewAssignment == nil && !_EDIT_MODE_) {
            coachMarksController.start(on: self)
        } else {
            //tfTitle.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coachMarksController.stop(immediately: true)
    }
    
    // MARK: - Animation Functions
    
    func showClearButton () {
        UIView.animate(withDuration: 0.2, animations: {
            self._layout_vClearWidthAnchor.constant = 80
            self.view.layoutIfNeeded()
        })
    }
    
    func hideClearButton () {
        UIView.animate(withDuration: 0.2, animations: {
            self._layout_vClearWidthAnchor.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func showSuggestionArea () {
        if (showSuggestions) {
            vSuggestions.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.3) {
                self._layout_vSuggestionsHeightAnchor.constant = 165
                self.vSuggestions.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideSuggestionArea () {
        vSuggestions.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self._layout_vSuggestionsHeightAnchor.constant = 0
            self.vSuggestions.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackground_Tapped(_ sender: Any) {
        hideSuggestionArea()
    }
    
    @IBAction func btnCancel_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAdd_Tapped(_ sender: Any) {
        if (!checkForm()) {
            return
        }
        if (_EDIT_MODE_) {
            let rowNumber: Int = getRowNum_AssignmentList(id: _EDIT_ID_)
            assignmentList[rowNumber].title = (tfTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            assignmentList[rowNumber].comments = tvComments.text
            assignmentList[rowNumber].subject = tmpSubject
            assignmentList[rowNumber].priority = tmpPriority
            assignmentList[rowNumber].dueDate = tmpDueDate
            
            assignmentList[rowNumber].notificationOn = notificationOn
            
            for item in UIApplication.shared.scheduledLocalNotifications! {
                if (item.userInfo!["id"] as! Int == _EDIT_ID_) {
                    UIApplication.shared.cancelLocalNotification(item)
                    break
                }
            }
            if (notificationOn) {
                let notification = UILocalNotification()
                notification.fireDate = notifyDateTime
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.userInfo = ["id": assignmentList[rowNumber].id]
                notification.alertBody = "[" + assignmentList[rowNumber].subject + "] " + assignmentList[rowNumber].title
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        } else {
            assignmentItem.id = curAssignmentID
            curAssignmentID += 1
            saveCurAssignmentID()
            assignmentItem.title = (tfTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
            assignmentItem.comments = tvComments.text
            assignmentItem.subject = tmpSubject
            assignmentItem.priority = tmpPriority
            assignmentItem.dueDate = tmpDueDate
            
            assignmentItem.notificationOn = notificationOn
            
            assignmentList.append(assignmentItem)
            
            if (notificationOn) {
                let notification = UILocalNotification()
                notification.fireDate = notifyDateTime
                //printDate(date: notification.fireDate!)
                notification.applicationIconBadgeNumber = 0
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.userInfo = ["id": assignmentItem.id]
                notification.alertBody = "[" + assignmentItem.subject + "] " + assignmentItem.title
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
        
        saveAssignmentList()
        
        UIView.animate(withDuration: 0.5) {
            curFrmAssignmentList.refreshTableAssignmentList()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSelectSubject_Tapped(_ sender: Any) {
        dropSelectSubject.show()
    }
    
    // MARK: Actions - Title Area
    
    @objc func tfTitle_TouchUpOutside() {
        hideSuggestionArea()
        view.endEditing(true)
    }
    
    @IBAction func tfTitle_EditingChanged(_ sender: Any) {
        if (tfTitle.text != "") {
            showClearButton()
            tfTitle.errorMessage = ""
        } else {
            hideClearButton()
        }
    }
    @IBAction func tfTitle_EditingDidBegin(_ sender: Any) {
        if (!_EDIT_MODE_) {
            //showSuggestionArea()
        }
    }
    @IBAction func tfTitle_EditingDidEnd(_ sender: Any) {
        if (!_EDIT_MODE_) {
            //hideSuggestionArea()
        }
    }
    
    @IBAction func btnClear_Tapped(_ sender: Any) {
        tfTitle.text = ""
        tfTitle_EditingChanged(self)
    }
    
    // MARK: Actions - Set Priority Settings
    
    @IBAction func sgcSetPriority_ValueChanged(_ sender: BetterSegmentedControl) {
        let selected: String = sender.titles[Int(sender.index)]
        if (selected == "Normal") {
            tmpPriority = 0
        } else if (selected == "!") {
            tmpPriority = 1
        } else if (selected == "!!") {
            tmpPriority = 2
        } else if (selected == "!!!") {
            tmpPriority = 3
        }
    }
    
    // MARK: Actions - Due Day Time Settings
    
    @IBAction func btnSetDueDate_Tapped(_ sender: Any) {
        let min = localDate()
        let max = localDate() + 10000000
        let picker = DateTimePicker.show(selected: tmpDueDate, minimumDate: min, maximumDate: max)
        picker.highlightColor = themeColor
        picker.darkColor = UIColor.darkGray
        //picker.doneButtonTitle = "Done"
        picker.todayButtonTitle = "Done"
        picker.resetTime()
        picker.is12HourFormat = true
        picker.dateFormat = "MM/dd/yyyy"
        picker.isDatePickerOnly = true
        picker.completionHandler = { date in
            self.tmpDueDate = Date(year: date.year, month: date.month, day: date.day, hour: self.tmpDueDate.hour, minute: self.tmpDueDate.minute, second: 0)
            self.updateDateTime()
            self.updateNotificationTime()
        }
    }
    
    @IBAction func sgcSetDueTime_ValueChanged(_ sender: BetterSegmentedControl) {
        if (sgcSetDueTime_firstOpens) {
            sgcSetDueTime_firstOpens = false
            return
        }
        let selected: String = sender.titles[Int(sender.index)]
        if (selected == "Morning") {
            tmpDueDate = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: 7, minute: 30, second: 0)
            updateDateTime()
            sgcSetDueTime_lastSelected = 0
            updateNotificationTime()
        } else if (selected == "Midnight") {
            tmpDueDate = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: 11, minute: 59, second: 0)
            updateDateTime()
            sgcSetDueTime_lastSelected = 1
            updateNotificationTime()
        } else if (selected == "Custom") {
            let min = localDate()
            let max = localDate() + 10000000
            let picker = DateTimePicker.show(selected: tmpDueDate, minimumDate: min, maximumDate: max)
            picker.highlightColor = themeColor
            picker.darkColor = UIColor.darkGray
            picker.doneButtonTitle = " "
            picker.todayButtonTitle = "Done"
            picker.resetTime()
            picker.is12HourFormat = true
            picker.dateFormat = "MM/dd/yyyy, mm:ss aa"
            picker.completionHandler = { date in
                self.tmpDueDate = Date(year: date.year, month: date.month, day: date.day, hour: date.hour, minute: date.minute, second: 0)
                self.updateDateTime()
                self.sgcSetDueTime_lastSelected = 3
                self.updateNotificationTime()
            }
            picker.dismissHandler = {
                do {
                    try self.sgcSetDueTime.setIndex(UInt(self.sgcSetDueTime_lastSelected))
                } catch { }
            }
        }
        
    }
    
    // MARK: Actions - Notification Settings
    
    
    @IBAction func switchSetNotification_ValueChanged(_ sender: Any) {
        if (switchSetNotification.isOn()) {
            updateNotificationTime()
            notificationOn = true
        } else {
            notificationOn = false
        }
    }
    
    @IBAction func btnSetNotification_Tapped(_ sender: Any) {
    }
    
    // MARK: Action - Delete Assignment
    
    @IBAction func btnDeleteAssignment_Tapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are You Sure You Want to Delete This Assignment?", message: "This operation cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (action) in
            self.deleteAssignment()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - TextView - tvComments
    
    func tvComments_FocusOn () {
        vComments.layer.borderWidth = 1.5
    }
    
    func tvComments_FocusOff () {
        vComments.layer.borderWidth = 0.7
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        hideSuggestionArea()
        tvComments_FocusOn()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        tvComments_FocusOff()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        lbPlaceHolder_tfComments.isHidden = (tvComments.text != "")
    }
    
    
    
    // MARK: - Functions
    
    func initializeUI () {
        
        btnSelectSubject_setup()
        
        btnAdd.layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        btnAdd.layer.shadowRadius = 6
        
        tfTitle.errorColor = redColor
        
        _layout_vClearWidthAnchor.constant = 0
        vSuggestions.isUserInteractionEnabled = false
        _layout_vSuggestionsHeightAnchor.constant = 0
        vSuggestions.alpha = 0
        
        vComments.backgroundColor = UIColor.white
        vComments.layer.cornerRadius = 4
        vComments.layer.borderColor = themeColor.cgColor
        tvComments_FocusOff()
        
        sgcSetPriority.layer.borderColor = themeColor.cgColor
        sgcSetPriority.layer.borderWidth = 0.8
        sgcSetPriority.titles = ["Normal", "!", "!!", "!!!"]
        
        sgcSetDueTime.layer.borderColor = themeColor.cgColor
        sgcSetDueTime.layer.borderWidth = 0.8
        sgcSetDueTime.titles = ["Morning", "Midnight", "Custom"]
        
        vSetNotification.layer.cornerRadius = 6
        switchSetNotification.layer.cornerRadius = 6
        
        self.view.layoutIfNeeded()
    }
    
    lazy var popupNewSubject: frmAssignmentList_NewAssignment_NewSubject = {
        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "sidNewSubject")
        return popupViewController as! frmAssignmentList_NewAssignment_NewSubject
    }()
    
    func setSubjectDropToNormalState () {
        btnSelectSubject.setTitleColor(themeColor, for: .normal)
        btnSelectSubject.layer.borderColor = themeColor.cgColor
        btnSelectSubject.layer.borderWidth = 0.8
    }
    
    func setSubjectDropToErrorState () {
        btnSelectSubject.setTitleColor(redColor, for: .normal)
        btnSelectSubject.layer.borderColor = redColor.cgColor
        btnSelectSubject.layer.borderWidth = 1.0
    }
    
    func updateSubjectDropDataSource () {
        dropSelectSubject.dataSource = [" + Add New Subject "]
        for subject: SubjectItem in subjectList {
            dropSelectSubject.dataSource.append(subject.name)
        }
        dropSelectSubject.reloadAllComponents()
    }
    
    func btnSelectSubject_setup () {
        
        setSubjectDropToNormalState()
        
        dropSelectSubject.anchorView = btnSelectSubject
        let appearance = DropDown.appearance()
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        
        updateSubjectDropDataSource()
        
        // Action triggered on selection
        dropSelectSubject.selectionAction = { [unowned self] (index, item) in
            if (index == 0) {
                let presenter: Presentr = {
                    let customPresentationType = PresentationType.custom(width: ModalSize.custom(size: 450.0), height: ModalSize.custom(size: 170.0), center: ModalCenterPosition.topCenter)
                    let presenter = Presentr(presentationType: customPresentationType)
                    presenter.transitionType = TransitionType.coverHorizontalFromRight
                    presenter.dismissOnSwipe = false
                    presenter.dismissOnTap = false
                    presenter.blurBackground = true
                    presenter.keyboardTranslationType = KeyboardTranslationType.moveUp
                    
                    return presenter
                }()
                self.customPresentViewController(presenter, viewController: self.popupNewSubject, animated: true, completion: {})
                curFrmAssignmentList_NewAssignment_NewSubject.initializeUI()
            } else {
                self.tmpSubject = item
                self.btnSelectSubject.setTitle(item, for: .normal)
                self.setSubjectDropToNormalState()
                self.updateTopBarUI()
            }
        }
    }
    
    func configureKeyboardHidingGestures () {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tfTitle_TouchUpOutside))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func checkForm () -> Bool { // Returns a Bool value that represents if the assignment is ready to be added to the assignmentList
        var result: Bool = true
        if (tfTitle.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "") {
            tfTitle.errorMessage = "The title of the assignment cannot be empty"
            result = false
        }
        if (tmpSubject == "") {
            setSubjectDropToErrorState()
            result = false
        }
        return result
    }
    
    func updateDateTime () {
        lbDueDate.text = "Assignment due " + (abs(daysDifference(date1: localDate(), date2: tmpDueDate)) > 1 ? "on " : "") + dateFormat_Word(date: tmpDueDate) + " "
        lbDueDate.text = lbDueDate.text! + displayDate(date: tmpDueDate)
    }
    
    func updateTopBarUI () {
        if (tmpSubject == "") {
            vTopBar.backgroundColor = UIColor.white
        } else {
            vTopBar.backgroundColor = subjectColor(string: tmpSubject)
        }
    }
    
    func refreshSubjectList () {
        setSubjectDropToNormalState()
        updateSubjectDropDataSource()
        tmpSubject = (subjectList.last?.name)!
        btnSelectSubject.setTitle(self.tmpSubject, for: .normal)
        updateTopBarUI()
    }
    
    
    func catchNotification(notification:Notification) -> Void {
        refreshSubjectList()
    }
    
    func updateNotificationTime () {
        if (localDate() > tmpDueDate) {
            switchSetNotification.setOn(false, animated: true)
            let alert = UIAlertController(title: "Cannot notify you", message: "This assignment is already over due.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        registerNotification()
        if (true) {
            if (abs(daysDifference(date1: localDate(), date2: tmpDueDate)) > 0) {
                notifyDateTime = tmpDueDate.addingTimeInterval(-86400)
                notifyDateTime = Date(year: notifyDateTime.year, month: notifyDateTime.month, day: notifyDateTime.day, hour: userSettings.defaultPushNotificationTime_hour, minute: userSettings.defaultPushNotificationTime_minute, second: 0)
                
                printDate(date: notifyDateTime)
            } else {
                notifyDateTime = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: userSettings.defaultPushNotificationTime_hour, minute: userSettings.defaultPushNotificationTime_minute, second: 0)
                
                if (!(localDate() < notifyDateTime && notifyDateTime < tmpDueDate)) {
                    notifyDateTime = Date(year: tmpDueDate.year, month: tmpDueDate.month, day: tmpDueDate.day, hour: (localDate().hour + tmpDueDate.hour) / 2, minute: 30, second: 0)
                }
            }
        } else {
            let alert = UIAlertController(title: "Cannot Setup Notification", message: "Notification is disabled for this app! Goto settings -> Assignments -> Notifications to turn on push notification for this app.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            notificationOn = false
            switchSetNotification.setOn(false, animated: true)
        }
    }
    
    func deleteAssignment () {
        assignmentList.remove(at: getRowNum_AssignmentList(id: _EDIT_ID_))
        curFrmAssignmentList.refreshTableAssignmentList()
        saveAssignmentList()
        self.dismiss(animated: true) {
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Coach
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 5
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        if (index == 0) {
            return coachMarksController.helper.makeCoachMark(for: btnSelectSubject)
        } else if (index == 1) {
            return coachMarksController.helper.makeCoachMark(for: tfTitle)
        } else if (index == 2) {
            return coachMarksController.helper.makeCoachMark(for: tvComments)
        } else if (index == 3) {
            return coachMarksController.helper.makeCoachMark(for: btnSetDueDate)
        } else if (index == 4) {
            return coachMarksController.helper.makeCoachMark(for: sgcSetDueTime)
        }
        return coachMarksController.helper.makeCoachMark(for: self.view)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        if (index == 0) {UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: subjectList), forKey: "subjectList")
            coachViews.bodyView.hintLabel.text = "First Step: Select the subject of the your new assignment"
            coachViews.bodyView.nextLabel.text = "Next"
        } else if (index == 1) {
            coachViews.bodyView.hintLabel.text = "Second, type in your assignment title"
            coachViews.bodyView.nextLabel.text = "Next"
        } else if (index == 2) {
            coachViews.bodyView.hintLabel.text = "You can put some other notes here, it's optional"
            coachViews.bodyView.nextLabel.text = "Next"
        } else if (index == 3) {
            coachViews.bodyView.hintLabel.text = "Tap here to pick the due date"
            coachViews.bodyView.nextLabel.text = "Next"
        } else if (index == 4) {
            coachViews.bodyView.hintLabel.text = "You can customize the due time here"
            coachViews.bodyView.nextLabel.text = "Ok"
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: true), forKey: "intro_frmNewAssignment")
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}


