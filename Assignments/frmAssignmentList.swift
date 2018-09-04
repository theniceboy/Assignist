//
//  frmAssignmentList.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

var tableAssignmentList: [AssignmentItem] = [] // The assignment list that is displayed
var tableAssignmentCurrentCell: frmAsignmentList_tblAssignmentListCell?
//var tableAssignmentList_checked: [AssignmentItem] = []
//var tableAssignmentListDivider: Int = 0 // The index of the first item that shoud be in the completed section
var tableAssignmentListCompletedCount: Int = 0 // The number of assignment items in the table that were completed.
var visibleCompletedAssignmentCount: Int = 0 // The number of assignment items that are both visible and completed.

var tableSubjectList: [SubjectItem] = []
var tableSubjectList_selectedRow: Int = 0

var tableLongTerm: [AssignmentItem] = []

var calendarEvents: [String: Int] = [:]

var checkedIDBeforeFocusSync: [Int] = []

var overdueUnchecked = true


func syncAssignmentListWithFocus () {
    
    DispatchQueue.main.async {
        curFrmAssignmentList.ckeckInternet()
    }
    
    let request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)
    curFrmAssignmentList.webView.loadHTMLString("", baseURL: URL(string: "about:blank")!)
    curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
    curFrmAssignmentList.webView.reload()
    curFrmAssignmentList.webView.loadRequest(request)
    
    curFrmAssignmentList.activityStart()
    
}


class frmAssignmentList: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIWebViewDelegate, FSCalendarDelegate, FSCalendarDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    // MARK: Form Outlets
    
    @IBOutlet weak var btnListIsEmpty: UIButton!
    
    
    @IBOutlet weak var vLeft: UIView!
    @IBOutlet weak var tblSubjectList: UITableView!
    
    @IBOutlet weak var vRight: UIView!
    @IBOutlet weak var vRightCenter: UIView!
    @IBOutlet weak var tblAssignmentList: UITableView!
    @IBOutlet weak var btnShowCompleted: ZFRippleButton!
    @IBOutlet weak var lbPullToRefresh: UILabel!
    
    @IBOutlet weak var btnAddNew: ZFRippleButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lbSyncingWithFocus: UILabel!
    
    @IBOutlet weak var btnSettings: ZFRippleButton!
    
    @IBOutlet weak var vRightExt: UIView!
    @IBOutlet weak var tblLongTerm: UITableView!
    @IBOutlet weak var fsCalendar: FSCalendar!
    @IBOutlet weak var btnToggleCalendar: ZFRippleButton!
    
    let coachMarksController = CoachMarksController()
    
    private let refreshControl = UIRefreshControl()
    
    // Layout

    @IBOutlet weak var _layout_vRightTopHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var _layout_vRightExt_WidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var _layout_vRight_Trailing: NSLayoutConstraint!
    
    // Variables
    
    var showAllSubjectAssignment: Bool = true
    var currentSubjectName: String = ""
    
    var loadedFromSystem: Bool = false
    
    // MARK: - UI Setup
    
    func UISetup () {
        
        
        _layout_vRightTopHeightAnchor.constant = 46
        lbSyncingWithFocus.alpha = 1
        
        //btnToggleCalendar.layer.borderColor = themeColor.cgColor
        //btnToggleCalendar.layer.borderWidth = 0.5
        
        btnToggleCalendar.layer.shadowColor = themeColor.cgColor
        btnToggleCalendar.layer.shadowOffset = CGSize.zero
        btnToggleCalendar.layer.shadowOpacity = 0.3
        btnToggleCalendar.layer.shadowRadius = 7
 
        lbPullToRefresh.alpha = 0
        
        
        vRightExt.layer.shadowColor = UIColor.black.cgColor
        vRightExt.layer.shadowOffset = CGSize.zero
        vRightExt.layer.shadowOpacity = 0.0
        vRightExt.layer.shadowRadius = 12
 
        
        hideCalendar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        if (userSettings.focusUsername != "" && userSettings.focusPassword != "") {
            setupRefreshControl()
        }
    }
    
    func setupRefreshControl () {
        refreshControl.addTarget(self, action: #selector(refreshFocusAssignments), for: .valueChanged)
        tblAssignmentList.addSubview(refreshControl)
    }
    
    var wasShowingCalendarInLandscape: Bool = false
    @objc func rotated () {
        if (ShowingCalendar) {
            showCalendar()
        }
    }
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAssignmentList.delegate = self
        tblAssignmentList.dataSource = self
        tblSubjectList.delegate = self
        tblSubjectList.dataSource = self
        coachMarksController.dataSource = self
    
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        curFrmAssignmentList = self
        
        if (!loadedFromSystem) {
            let nsuserSettings = UserDefaults.standard.object(forKey: "userSettings")
            if (nsuserSettings != nil) {
                userSettings = NSKeyedUnarchiver.unarchiveObject(with: nsuserSettings as! Data) as! UserSettings
            }
            
            let nsAssignments = UserDefaults.standard.object(forKey: "assignmentList")
            if (nsAssignments != nil) {
                assignmentList = NSKeyedUnarchiver.unarchiveObject(with: nsAssignments as! Data) as! [AssignmentItem]
            }
            
            let nsSubjects = UserDefaults.standard.object(forKey: "subjectList")
            if (nsSubjects != nil) {
                subjectList = NSKeyedUnarchiver.unarchiveObject(with: nsSubjects as! Data) as! [SubjectItem]
            }
            
            let nsCurAssignmentID = UserDefaults.standard.object(forKey: "curAssignmentID")
            if (nsCurAssignmentID != nil) {
                curAssignmentID = NSKeyedUnarchiver.unarchiveObject(with: nsCurAssignmentID as! Data) as! Int
            }
            
            loadedFromSystem = true
        }
        
        if (subjectList.count == 0) {
            let defaultSubject = SubjectItem()
            defaultSubject.name = __DEFAULT_SUBJECT_NAME
            defaultSubject.color = UIColor.darkGray
            subjectList.append(defaultSubject)
            saveSubjectList()
        }
        
        let nsfirstOpen = UserDefaults.standard.object(forKey: "replacedSpecial")
        if (nsfirstOpen == nil) {
            for item in assignmentList {
                item.title = item.title.replacingOccurrences(of: "&amp;", with: "&")
                item.subject = item.subject.replacingOccurrences(of: "&amp;", with: "&")
            }
            for item in subjectList {
                item.name = item.name.replacingOccurrences(of: "&amp;", with: "&")
            }
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: true), forKey: "replacedSpecial")
        }
        
        
        for i in 0 ... (subjectList.count - 1) {
            if (subjectList[i].name.contains("&amp;")) {
                if (assignmentList.count > 0) {
                    var j = 0
                    while (j < assignmentList.count) {
                        if (assignmentList[j].subject == subjectList[i].name) {
                            assignmentList.remove(at: j)
                            j -= 1
                        }
                        j += 1
                    }
                }
                subjectList.remove(at: i)
            }
        }
        
        
        saveAssignmentList()
        saveSubjectList()
        
        refreshTableAssignmentList()
        
        activityStop()
        
        UISetup()
    }
    
    // Internet Check
    func ckeckInternet() {
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            activityStop()
            webView.stopLoading()
            Drop.down("Internet is currently not available", state: .warning, duration: 1.5, action: {
            })
        case .online(.wwan):
            print("Connected via WWAN")
        case .online(.wiFi):
            print("Connected via WiFi")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (userSettings.focusUsername != "" && userSettings.focusPassword != "") {
            loggedInFocus = true
            loginFromSettigns = false
            syncAssignmentListWithFocus()
        } else {
            loggedInFocus = false
        }
        
        
        let nsfirstOpen = UserDefaults.standard.object(forKey: "firstOpen")
        if (nsfirstOpen == nil) {
            print("start")
            coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.3)
            coachMarksController.overlay.allowTap = true
            coachMarksController.start(on: self)
        }
        
        if overdueUnchecked {
            overdueUnchecked = false
            var overdues: [AssignmentItem] = []
            for item in tableAssignmentList {
                if daysDifference(date1: item.dueDate, date2: Date.today()) > 0 && !item.checked {
                    overdues.append(item)
                }
            }
            if (overdues.count > 9) {
                let alert = UIAlertController(title: "You have \(overdues.count) overdue (due yesterday or earlier) assignment item\(overdues.count > 1 ? "s" : ""), do you want to check them off?", message: "You can always uncheck them later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) in
                    self.showingChecked = 1
                    for item in overdues {
                        item.checked = true
                        assignmentList[getRowNum_AssignmentList(id: item.id)].checked = true
                        self.partialCheckedItemIndex[item.id] = 1
                    }
                    saveAssignmentList()
                    self.refreshTableAssignmentList()
                    if tableAssignmentList.count > 4 {
                        var _targetRow: Int = 0, _targetValue: Int = 10000, _tmpValue: Int = 0
                        for i in 0 ..< tableAssignmentList.count {
                            _tmpValue = abs(daysDifference(date1: tableAssignmentList[i].dueDate, date2: Date.today()))
                            if _tmpValue < _targetValue {
                                _targetValue = _tmpValue
                                _targetRow = i
                            }
                        }
                        if ((_targetRow - 1 < 0 ? _targetRow : _targetRow - 1) < tableAssignmentList.count) {
                            self.tblAssignmentList.scrollToRow(at: IndexPath(row: (_targetRow - 1 < 0 ? _targetRow : _targetRow - 1), section: 0), at: .middle, animated: true)
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Focus Login Handler
    
    @objc func refreshFocusAssignments () {
        loginFromSettigns = false
        syncAssignmentListWithFocus()
        refreshControl.endRefreshing()
    }
    
    func LoginOvertime () {
        activityStop()
        if (!loggedInFocus) {
            Drop.down("Loggin Timeout. Please Check Your Internet.", state: .warning)
            webView.stopLoading()
            myTimer.invalidate()
        }
    }
    
    func activityStart () {
        startProgressView()
        UIView.animate(withDuration: 0.3) {
            self._layout_vRightTopHeightAnchor.constant = 60
            self.lbSyncingWithFocus.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func activityStop () {
        stopProgressView()
        UIView.animate(withDuration: 0.3) {
            self._layout_vRightTopHeightAnchor.constant = 46
            self.lbSyncingWithFocus.alpha = 0
            self.progressView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    var progressDone: Bool = false
    var myTimer: Timer = Timer()
    func startProgressView() {
        progressView.progress = 0.0
        progressView.alpha = 1
        timerStart()
        invalidLoginInfoCount = 0
    }
    
    func timerStart () {
        progressDone = false
        myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
    }
    
    func stopProgressView() {
        progressDone = true
    }
    
    
    var invalidLoginInfoCount: Int = 0
    @objc func timerCallback() {
        if progressDone {
            invalidLoginInfoCount = 0
            if self.progressView.progress >= 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.progressView.alpha = 0
                })
                self.myTimer.invalidate()
            } else {
                self.progressView.progress += 0.1
            }
        } else {
            if (webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('form-error')[0].innerHTML")?.contains("Invalid username/password"))! {
                invalidLoginInfoCount += 1
            } else {
                self.progressView.progress += (loggedInFocus ? 0.0015 : 0.0011)
                if self.progressView.progress >= 0.95 {
                    self.progressView.progress = 0.95
                }
            }
            if (invalidLoginInfoCount > 10) {
                progressDone = true
                if (loginFromSettigns) {
                    SwiftSpinner.sharedInstance.innerColor = UIColor.white
                    SwiftSpinner.sharedInstance.outerColor = UIColor.red.withAlphaComponent(0.5)
                    SwiftSpinner.show(duration: 2.0, title: "Invalid username/password", animated: false)
                } else {
                    Drop.down("Invalid username/password", state: .error)
                    activityStop()
                }
                userSettings.focusUsername = ""
                userSettings.focusPassword = ""
                saveUserSettings()
                myTimer.invalidate()
            }
        }
    }
    
    // MARK: - WebView Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if ((webView.request?.url?.absoluteString)!.contains("Modules")) {
            let htmlstr = webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('BoxContent')[0].getElementsByTagName('ul')[0].innerHTML")
            let periodhtml = webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('Programs')[0].innerHTML")
            if (loginFromSettigns) {
                SwiftSpinner.sharedInstance.innerColor = UIColor.white
                SwiftSpinner.sharedInstance.outerColor = UIColor.white
                SwiftSpinner.show("Authenticating Focus Account", animated: true)
            }
            parseFocusHTML(html: htmlstr!, subjectstr: periodhtml!)
        } else {
            webView.stringByEvaluatingJavaScript(from: "document.getElementById('username-input').value='" + userSettings.focusUsername + "';document.getElementsByName('password')[0].value='" + userSettings.focusPassword + "';document.getElementsByClassName('form-button')[0].click()")
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("error")
        print(error)
    }
    
    
    
    // MARK: - Actions
    
    lazy var popupNewSubject: frmAssignmentList_NewAssignment_NewSubject = {
        let popupViewController = self.storyboard?.instantiateViewController(withIdentifier: "sidNewSubject")
        return popupViewController as! frmAssignmentList_NewAssignment_NewSubject
    }()
    
    @IBAction func btnAddSubject_Tapped(_ sender: Any) {
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
    }
    
    @IBAction func btnAdd_Tapped(_ sender: Any) {
        _EDIT_MODE_ = false
    }
    
    var showingChecked: Int = 0 // 0: not showing, 1: partial, 2: showing all
    var partialCheckedItemIndex: [Int: Int] = [:]
    var legacyTableAssignment: AssignmentItem?
    @IBAction func btnShowCompleted_Tapped(_ sender: Any) {
        var tableRow: Int = 0
        if let currentCell = tableAssignmentCurrentCell {
            for i in 0 ..< tableAssignmentList.count {
                if tableAssignmentList[i].id == assignmentList[currentCell.assignmentRow].id {
                    tableRow = i
                    break
                }
            }
        } else {
            if let firstCell = tblAssignmentList.visibleCells.first {
                tableAssignmentCurrentCell = firstCell as! frmAsignmentList_tblAssignmentListCell
            }
        }
        if tableAssignmentList.count > 0 {
            for i in 0 ... 1000 {
                if tableRow - i > -1 {
                    if !tableAssignmentList[tableRow - i].checked {
                        legacyTableAssignment = tableAssignmentList[tableRow - i]
                        break
                    }
                }
                if tableRow + i < tableAssignmentList.count {
                    if !tableAssignmentList[tableRow + i].checked {
                        legacyTableAssignment = tableAssignmentList[tableRow + i]
                        break
                    }
                }
            }
        }
    
        if showingChecked == 0 {
            showingChecked = 2
        } else if showingChecked == 1 || showingChecked == 2 {
            showingChecked = 0
        }
        
        refreshTableAssignmentList(formatTable: true, refreshSubject: true)
        for i in 0 ..< tableAssignmentList.count {
            if (tableAssignmentList[i].id == legacyTableAssignment?.id) {
                //print("scroll to:", tableAssignmentList[i].title, legacyTableAssignment?.title)
                tblAssignmentList.scrollToRow(at: IndexPath(row: (i - 1 < 0 ? i : i - 1), section: 0), at: UITableViewScrollPosition.top, animated: false)
                break
            }
        }
        
        refreshShowCompletedButton()
 
    }
    
    var ShowingCalendar: Bool = false
    
    func showCalendar () {
        btnToggleCalendar.setImage(UIImage(named: "arrow-right"), for: .normal)
        btnToggleCalendar.setTitle("  Hide", for: .normal)
        UIView.animate(withDuration: 0.2, animations: {
            self._layout_vRightExt_WidthAnchor.constant = 250
            if (self.interfaceOrientation == UIInterfaceOrientation.portrait || self.interfaceOrientation == UIInterfaceOrientation.portraitUpsideDown) {
                self._layout_vRight_Trailing.constant = 0
            } else {
                self._layout_vRight_Trailing.constant = 250
            }
            self.vRightExt.layer.shadowOpacity = 0.2
            self.view.layoutIfNeeded()
        })
        ShowingCalendar = true
        fsCalendar.reloadData()
        
        refreshLongTerm()
    }
    
    func hideCalendar () {
        btnToggleCalendar.setImage(UIImage(named: "arrow-left"), for: .normal)
        btnToggleCalendar.setTitle("  More", for: .normal)
        UIView.animate(withDuration: 0.2, animations: {
            self._layout_vRightExt_WidthAnchor.constant = 0
            self._layout_vRight_Trailing.constant = 0
            self.vRightExt.layer.shadowOpacity = 0.0
            self.view.layoutIfNeeded()
        })
        ShowingCalendar = false
    }
    
    @IBAction func btnToggleCalendar_Tapped(_ sender: Any) {
        if (ShowingCalendar) {
            hideCalendar()
        } else {
            showCalendar()
        }
    }
    
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == tblSubjectList) {
            if (indexPath.row == 0) {
                showAllSubjectAssignment = true
            } else {
                if currentSubjectName != tableSubjectList[indexPath.row].name && showingChecked == 1 {
                    showingChecked = 0
                }
                showAllSubjectAssignment = false
                currentSubjectName = tableSubjectList[indexPath.row].name
            }
            
            
            tableSubjectList_selectedRow = indexPath.row
            refreshTableAssignmentList(formatTable: true, refreshSubject: true)
            if tableAssignmentList.count > 4 && showingChecked > 0 {
                var _targetRow: Int = 0, _targetValue: Int = 10000, _tmpValue: Int = 0
                for i in 0 ..< tableAssignmentList.count {
                    _tmpValue = abs(daysDifference(date1: tableAssignmentList[i].dueDate, date2: Date.today()))
                    if _tmpValue < _targetValue {
                        _targetValue = _tmpValue
                        _targetRow = i
                    }
                }
                if ((_targetRow - 1 < 0 ? _targetRow : _targetRow - 1) < tableAssignmentList.count) {
                    tblAssignmentList.scrollToRow(at: IndexPath(row: (_targetRow - 1 < 0 ? _targetRow : _targetRow - 1), section: 0), at: .middle, animated: true)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == tblAssignmentList) {
            return 1
        } else if (tableView == tblSubjectList) {
            return 1
        } else if (tableView == tblLongTerm) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblAssignmentList) {
            return tableAssignmentList.count
        } else if (tableView == tblSubjectList) {
            return tableSubjectList.count
        } else if (tableView == tblLongTerm) {
            return tableLongTerm.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView == tblAssignmentList) {
            return ""
        } else if (tableView == tblSubjectList) {
            return ""
        } else if (tableView == tblLongTerm) {
            return ""
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tblAssignmentList) {
            let cell: frmAsignmentList_tblAssignmentListCell = tableView.dequeueReusableCell(withIdentifier: "tblAssignmentListCell_Identifier", for: indexPath) as! frmAsignmentList_tblAssignmentListCell
            cell.rowNumber = indexPath.row
            cell.loadCell()
            return cell
        } else if (tableView == tblSubjectList) {
            let cell: frmAssignmentList_tblSubject_Cell = tableView.dequeueReusableCell(withIdentifier: "tblSubjectListCell_Identifier", for: indexPath) as! frmAssignmentList_tblSubject_Cell
            cell.rowNumber = indexPath.row
            cell.loadCell()
            return cell
        } else if (tableView == tblLongTerm) {
            let cell: frmAssignmentList_tblLongTerm_Cell = tableView.dequeueReusableCell(withIdentifier: "tblLongTermCell_Identifier", for: indexPath) as! frmAssignmentList_tblLongTerm_Cell
            cell.rowNumber = indexPath.row
            cell.loadCell()
            return cell
        }
        return UITableViewCell()
    }
    
    var tblAssignmentsScrollState: Int = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == tblAssignmentList) {
            if (scrollView.contentOffset.y < -40) {
                lbPullToRefresh.alpha = (scrollView.contentOffset.y < -100.0 ? -140.0 : scrollView.contentOffset.y + 40) / -140.0
            } else {
                lbPullToRefresh.alpha = 0
            }
            if (tblAssignmentsScrollState == 0 && ShowingCalendar) {
                refreshCalendarSelection()
            }
            if let cell: UITableViewCell = tblAssignmentList.visibleCells.first {
                tableAssignmentCurrentCell = cell as! frmAsignmentList_tblAssignmentListCell
            } else {
                tableAssignmentCurrentCell = nil
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (scrollView == tblAssignmentList) {
            tblAssignmentsScrollState = 0
        }
    }
    
    // MARK: - Table View Data
    
    func swaptable (a: Int, b: Int) {
        let c = tableAssignmentList[a]
        tableAssignmentList[a] = tableAssignmentList[b]
        tableAssignmentList[b] = c
    }
    /*
    func swaptable_checked (a: Int, b: Int) {
        let c = tableAssignmentList_checked[a]
        tableAssignmentList_checked[a] = tableAssignmentList_checked[b]
        tableAssignmentList_checked[b] = c
    }
 */
    
    func formatTableData () {
        tableAssignmentList = []
        tableAssignmentListCompletedCount = 0
        visibleCompletedAssignmentCount = 0
        calendarEvents = [:]
        if (showingChecked == 0) {
            partialCheckedItemIndex = [:]
        }
        if (assignmentList.count == 0) {
            return
        }
        if (assignmentList.count == 1) {
            if (showAllSubjectAssignment || currentSubjectName == assignmentList[0].subject) {
                if (assignmentList[0].checked) {
                    if (showingChecked == 2) {
                        tableAssignmentList.append(assignmentList[0])
                        visibleCompletedAssignmentCount += 1
                    } else if (showingChecked == 1) {
                        if let _ = partialCheckedItemIndex[assignmentList[0].id] {
                            tableAssignmentList.append(assignmentList[0])
                            visibleCompletedAssignmentCount += 1
                        }
                    }
                    tableAssignmentListCompletedCount = 1
                } else {
                    tableAssignmentList.append(assignmentList[0])
                }
            }
        } else {
            for i in 0 ..< assignmentList.count {
                if (!showAllSubjectAssignment && currentSubjectName != assignmentList[i].subject) {
                    continue
                }
                if (assignmentList[i].checked) {
                    if (showingChecked == 2) {
                        tableAssignmentList.append(assignmentList[i])
                        visibleCompletedAssignmentCount += 1
                    } else if (showingChecked == 1) {
                        if let _ = partialCheckedItemIndex[assignmentList[i].id] {
                            tableAssignmentList.append(assignmentList[i])
                            visibleCompletedAssignmentCount += 1
                        }
                    }
                    tableAssignmentListCompletedCount += 1
                } else {
                    tableAssignmentList.append(assignmentList[i])
                }
            }
            if (tableAssignmentList.count > 1) {
                for i in 0 ... (tableAssignmentList.count - 2) {
                    for j in (i + 1) ..< tableAssignmentList.count {
                        if (tableAssignmentList[i].dueDate.timeIntervalSince1970 > tableAssignmentList[j].dueDate.timeIntervalSince1970) {
                            swaptable(a: i, b: j)
                        } else if (tableAssignmentList[i].dueDate == tableAssignmentList[j].dueDate) {
                            if (tableAssignmentList[i].priority < tableAssignmentList[j].priority) {
                                swaptable(a: i, b: j)
                            } else if (tableAssignmentList[i].priority == tableAssignmentList[j].priority) {
                                if (tableAssignmentList[i].subject.compare(tableAssignmentList[j].subject) == ComparisonResult.orderedDescending) {
                                    swaptable(a: i, b: j)
                                } else if (tableAssignmentList[i].subject == tableAssignmentList[j].subject) {
                                    if (tableAssignmentList[i].title.compare(tableAssignmentList[j].title) == ComparisonResult.orderedDescending) {
                                        swaptable(a: i, b: j)
                                    }
                                }
                            }
                        }
                    }
                }
                for i in 0 ..< tableAssignmentList.count {
                    if (calendarEvents["\(tableAssignmentList[i].dueDate.year)-\(tableAssignmentList[i].dueDate.month)-\(tableAssignmentList[i].dueDate.day)"] == nil) {
                        calendarEvents["\(tableAssignmentList[i].dueDate.year)-\(tableAssignmentList[i].dueDate.month)-\(tableAssignmentList[i].dueDate.day)"] = 1
                    } else {
                        calendarEvents["\(tableAssignmentList[i].dueDate.year)-\(tableAssignmentList[i].dueDate.month)-\(tableAssignmentList[i].dueDate.day)"]! += 1
                    }
                }
            }
            /*
            if (showingChecked) {
                if (tableAssignmentList_checked.count > 1) {
                    for i in 0 ... (tableAssignmentList_checked.count - 2) {
                        for j in (i + 1) ... (tableAssignmentList_checked.count - 1) {
                            if (tableAssignmentList_checked[i].checkedDate.timeIntervalSince1970 < tableAssignmentList_checked[j].checkedDate.timeIntervalSince1970) {
                                swaptable_checked(a: i, b: j)
                            }
                        }
                    }
                }
                tableAssignmentList.append(contentsOf: tableAssignmentList_checked)
            }
 */
        }
    }
    
    public func refreshShowCompletedButton () {
        visibleCompletedAssignmentCount = 0
        for item in tableAssignmentList {
            if item.checked {
                visibleCompletedAssignmentCount += 1
            }
        }
        if (visibleCompletedAssignmentCount == 0) {
            if (tableAssignmentListCompletedCount == 0) {
                //showingChecked = false
                //btnShowCompleted.setTitle("Show Completed", for: .normal)
                btnShowCompleted.isEnabled = false
                btnShowCompleted.setTitleColor(scrollGray, for: .normal)
            } else {
                //showingChecked = true
                btnShowCompleted.setTitle("Show Completed", for: .normal)
                btnShowCompleted.isEnabled = true
                btnShowCompleted.setTitleColor(themeColor, for: .normal)
            }
        } else {
            btnShowCompleted.isEnabled = true
            btnShowCompleted.setTitle("Hide Completed", for: .normal)
            btnShowCompleted.setTitleColor(themeColor, for: .normal)
        }
        
    }
    
    func refreshTableAssignmentList (formatTable: Bool = true, refreshSubject: Bool = true) {
        if (formatTable) {
            formatTableData()
            btnListIsEmpty.isHidden = !(tableAssignmentList.count == 0)
        }
        refreshShowCompletedButton()
        tblAssignmentList.reloadData()
        refreshTableSubject()
        if (ShowingCalendar) {
            refreshCalendarSelection()
            refreshLongTerm()
        }
        /*
        var tableRow: Int = 0
        if let currentCell = tableAssignmentCurrentCell {
            for i in 0 ..< tableAssignmentList.count {
                if tableAssignmentList[i].id == assignmentList[currentCell.assignmentRow].id {
                    tableRow = i
                    break
                }
            }
        } else {
            tableAssignmentCurrentCell = tblAssignmentList.visibleCells.first as! frmAsignmentList_tblAssignmentListCell
        }
        for i in 0 ... 1000 {
            if tableRow - i > -1 {
                if !tableAssignmentList[tableRow - i].checked {
                    legacyTableAssignment = tableAssignmentList[tableRow - i]
                    break
                }
            }
            if tableRow + i < tableAssignmentList.count {
                if !tableAssignmentList[tableRow + i].checked {
                    legacyTableAssignment = tableAssignmentList[tableRow + i]
                    break
                }
            }
        }
 */
    }
    
    func refreshTableSubject() {
        tableSubjectList = []
        let allSubject = SubjectItem()
        allSubject.name = "All Assignments"
        tableSubjectList.append(allSubject)
        tableSubjectList.append(contentsOf: subjectList)
        
        tblSubjectList.reloadData()
    }
    
    func refreshLongTerm () {
        tableLongTerm = []
        if (assignmentList.count > 0) {
            for i in 0 ... (assignmentList.count - 1) {
                if (!assignmentList[i].checked && assignmentList[i].longTerm) {
                    tableLongTerm.append(assignmentList[i])
                }
            }
        }
        tblLongTerm.reloadData()
    }
    
    // MARK: - Table View Action
    
    func editAssignment (id: Int) {
        _EDIT_ID_ = id
        _EDIT_MODE_ = true
        self.performSegue(withIdentifier: "segueShowFrmNewAssignment", sender: self)
    }
    
    // MARK: - FSCalendar Functions
    
    func refreshCalendarSelection () {
        if (tblAssignmentList.indexPathsForVisibleRows == nil) {
            return
        }
        let visibleRows: [IndexPath] = tblAssignmentList.indexPathsForVisibleRows!
        if (visibleRows.count > 0) {
            fsCalendar.select(tableAssignmentList[visibleRows[0].row].dueDate)
        }
    }

    // MARK: - FSCalendarDataSource
    
    func min (a: Int, b: Int) -> Int {
        return a < b ? a : b
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if (calendarEvents["\(date.year)-\(date.month)-\(date.day)"] == nil) {
            return ""
        }
        var str = ""
        for _ in 1 ... min(a: calendarEvents["\(date.year)-\(date.month)-\(date.day)"]!, b: 3) {
            str = str + "•"
        }
        return str
    }
    
    // MARK: - FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.fsCalendar.layoutIfNeeded()
        fsCalendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var flag = true
        if (tableAssignmentList.count > 0) {
            for i in 0 ... (tableAssignmentList.count - 1) {
                if (onSameDay(date1: tableAssignmentList[i].dueDate, date2: date)) {
                    if (flag) {
                        tblAssignmentsScrollState = 1
                        tblAssignmentList.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.middle)
                        flag = false
                    }
                    if let row = curFrmAssignmentList.tblAssignmentList.cellForRow(at: IndexPath(row: i, section: 0)) {
                        (row as! frmAsignmentList_tblAssignmentListCell).highLight()
                    } else {
                        let when = DispatchTime.now() + 0.2
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            if let row = curFrmAssignmentList.tblAssignmentList.cellForRow(at: IndexPath(row: i, section: 0)) {
                                (row as! frmAsignmentList_tblAssignmentListCell).highLight()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //fsCalendar.reloadData()
    }
    
    // MARK: - Test Only
    
    @IBAction func clearAll(_ sender: Any) {
        printAssignments()
        /*
        assignmentList = []
        subjectList = []
        let defaultSubject = SubjectItem()
        defaultSubject.name = __DEFAULT_SUBJECT_NAME
        defaultSubject.color = UIColor.darkGray
        subjectList.append(defaultSubject)
        saveAssignmentList()
        saveSubjectList()
        refreshTableAssignmentList()
 */
    }
    
    // MARK
    
    
    // MARK: - Coach
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        if (index == 0) {
            return coachMarksController.helper.makeCoachMark(for: btnAddNew)
        } else if (index == 1) {
            return coachMarksController.helper.makeCoachMark(for: btnSettings)
        }
        return coachMarksController.helper.makeCoachMark(for: self.view)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        if (index == 0) {UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: subjectList), forKey: "subjectList")
            coachViews.bodyView.hintLabel.text = "Tap here to add a new assignment."
            coachViews.bodyView.nextLabel.text = "OK"
        } else if (index == 1) {
            coachViews.bodyView.hintLabel.text = "See more options in settings. You can connect to MVC Focus if you are a MVCS student."
            coachViews.bodyView.nextLabel.text = "OK"
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: true), forKey: "firstOpen")
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
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

