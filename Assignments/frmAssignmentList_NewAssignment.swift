//
//  frmAssignmentList_NewAssignment.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit
import DropDown
import Presentr

class frmAssignmentList_NewAssignment: UIViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    
    // Controls
    
    @IBOutlet weak var btnSelectSubject: ZFRippleButton!
    
    @IBOutlet weak var tfTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var vClear: UIView!
    
    @IBOutlet weak var vSuggestions: UIView!
    
    @IBOutlet weak var vComments: UIView!
    @IBOutlet weak var tvComments: UITextView!
    @IBOutlet weak var lbPlaceHolder_tfComments: UILabel!
    
    @IBOutlet weak var lbDueDate: UILabel!
    @IBOutlet weak var btnSetDueDate: ZFRippleButton!
    
    @IBOutlet weak var sgcSetDueTime: BetterSegmentedControl!
    @IBOutlet weak var btnSetDueTime: ZFRippleButton!
    
    @IBOutlet weak var vSetNotification: UIView!
    @IBOutlet weak var switchSetNotification: SevenSwitch!
    @IBOutlet weak var btnSetNotification: ZFRippleButton!
    
    
    // Constraints
    
    @IBOutlet weak var _layout_vClearWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var _layout_vSuggestionsHeightAnchor: NSLayoutConstraint!
    
    // MARK: - UI
    
    var dropSelectSubject = DropDown()
    var _suggestionPositions: [CGFloat] = [65, 113, 165]
    
    // MARK: - Class Open Var
    
    var _EDIT_MODE_: Bool = false
    var showSuggestions: Bool = false
    var assignmentItem: AssignmentItem = AssignmentItem()
    
    // MARK: - Variables used for private functions
    
    var sgcSetDueTime_lastSelected: Int = 0
    
    // MARK: - System Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        configureKeyboardHidingGestures()
        
        if (assignmentList.count > 0) {
            showSuggestions = true
        }
        
        if (!_EDIT_MODE_) {
            assignmentItem.dueDate = Date(year: Date.tomorrow().year, month: Date.tomorrow().month, day: Date.tomorrow().day, hour: 7, minute: 30, second: 0)
        }
        
        updateDateTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        showSuggestionArea()
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
        assignmentItem.title = (tfTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        assignmentItem.comments = tvComments.text
        
        assignmentList.append(assignmentItem)
        saveAssignmentList()
        
        UIView.animate(withDuration: 0.5) {
            curFrmAssignmentList.tblAssignmentList.reloadData()
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
        //showSuggestionArea()
        if (tfTitle.text != "") {
            showClearButton()
            tfTitle.errorMessage = ""
        } else {
            hideClearButton()
        }
    }
    @IBAction func tfTitle_EditingDidBegin(_ sender: Any) {
        showSuggestionArea()
    }
    @IBAction func tfTitle_EditingDidEnd(_ sender: Any) {
        hideSuggestionArea()
    }
    
    @IBAction func btnClear_Tapped(_ sender: Any) {
        tfTitle.text = ""
        tfTitle_EditingChanged(self)
    }
    
    // MARK: Actions - Due Day Time Settings
    
    @IBAction func btnSetDueDate_Tapped(_ sender: Any) {
        let min = Date.today()
        let max = Date.today() + 10000000
        let picker = DateTimePicker.show(selected: assignmentItem.dueDate, minimumDate: min, maximumDate: max)
        picker.highlightColor = themeColor
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "Done"
        picker.todayButtonTitle = "Today"
        picker.resetTime(showAnimation: false)
        picker.is12HourFormat = true
        picker.dateFormat = "MM/dd/yyyy"
        picker.isDatePickerOnly = false
        picker.completionHandler = { date in
            self.assignmentItem.dueDate = Date(year: date.year, month: date.month, day: date.day, hour: self.assignmentItem.dueDate.hour, minute: self.assignmentItem.dueDate.minute, second: 0)
            self.updateDateTime()
        }
    }
    
    @IBAction func sgcSetDueTime_ValueChanged(_ sender: BetterSegmentedControl) {
        let selected: String = sender.titles[Int(sender.index)]
        if (selected == "Morning") {
            assignmentItem.dueDate = Date(year: assignmentItem.dueDate.year, month: assignmentItem.dueDate.month, day: assignmentItem.dueDate.day, hour: 7, minute: 30, second: 0)
            updateDateTime()
            //sgcSetDueTime_lastSelected = 0
        } else if (selected == "Midnight") {
            assignmentItem.dueDate = Date(year: assignmentItem.dueDate.year, month: assignmentItem.dueDate.month, day: assignmentItem.dueDate.day, hour: 11, minute: 59, second: 0)
            updateDateTime()
            //sgcSetDueTime_lastSelected = 1
        } else if (selected == "Custom") {
            let min = Date.today()
            let max = Date.today() + 10000000
            let picker = DateTimePicker.show(selected: assignmentItem.dueDate, minimumDate: min, maximumDate: max)
            picker.highlightColor = themeColor
            picker.darkColor = UIColor.darkGray
            picker.doneButtonTitle = "Done"
            picker.todayButtonTitle = "Today"
            picker.resetTime(showAnimation: false)
            picker.is12HourFormat = false
            picker.dateFormat = "MM/dd/yyyy, mm:ss aa"
            picker.completionHandler = { date in
                self.assignmentItem.dueDate = Date(year: date.year, month: date.month, day: date.day, hour: date.hour, minute: date.minute, second: 0)
                self.updateDateTime()
                //self.sgcSetDueTime_lastSelected = 3
            }
            picker.dismissHandler = {
                //self.sgcSetDueTime.index = self.sgcSetDueTime_lastSelected
            }
        }
    }
    
    @IBAction func btnSetDueTime_Tapped(_ sender: Any) {
    }
    
    // MARK: Actions - Notification Settings
    
    @IBAction func switchSetNotification_ValueChanged(_ sender: Any) {
    }
    
    @IBAction func btnSetNotification_Tapped(_ sender: Any) {
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
        
        tfTitle.errorColor = redColor
        
        _layout_vClearWidthAnchor.constant = 0
        vSuggestions.isUserInteractionEnabled = false
        _layout_vSuggestionsHeightAnchor.constant = 0
        vSuggestions.alpha = 0
        
        vComments.backgroundColor = UIColor.white
        vComments.layer.cornerRadius = 4
        vComments.layer.borderColor = themeColor.cgColor
        tvComments_FocusOff()
        
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
    
    func btnSelectSubject_setup () {
        btnSelectSubject.layer.borderColor = themeColor.cgColor
        btnSelectSubject.layer.borderWidth = 0.8
        
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
        
        dropSelectSubject.dataSource = ["+"]
        for var subject: SubjectItem in subjectList {
            dropSelectSubject.dataSource.append(subject.name)
        }
        
        // Action triggered on selection
        dropSelectSubject.selectionAction = { [unowned self] (index, item) in
            if (index == 0) {
                let presenter: Presentr = {
                    let presenter = Presentr(presentationType: .alert)
                    presenter.transitionType = TransitionType.coverHorizontalFromRight
                    presenter.dismissOnSwipe = false
                    return presenter
                }()
                
                presenter.presentationType = .popup
                presenter.transitionType = nil
                presenter.dismissTransitionType = nil
                presenter.keyboardTranslationType = .compress
                self.customPresentViewController(presenter, viewController: self.popupNewSubject, animated: true, completion: nil)
                
            } else {
                self.btnSelectSubject.setTitle(item, for: .normal)
            }
        }
    }
    
    func configureKeyboardHidingGestures () {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tfTitle_TouchUpOutside))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func checkForm () -> Bool { // Returns a Bool value that represents if the assignment is ready to be added to the assignmentList
        if (tfTitle.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "") {
            tfTitle.errorMessage = "The title of the assignment cannot be empty"
            return false
        }
        return true
    }
    
    func updateDateTime () {
        lbDueDate.text = "Assignment due " + (abs(daysDifference(date1: Date.today(), date2: assignmentItem.dueDate)) > 1 ? "On " : "") + dateFormat_Word(date: assignmentItem.dueDate) + " At \(assignmentItem.dueDate.hour):\(assignmentItem.dueDate.minute)"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
