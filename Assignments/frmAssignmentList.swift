//
//  frmAssignmentList.swift
//  Assignments
//
//  Created by David Chen on 8/31/17.
//  Copyright © 2017 David Chen. All rights reserved.
//

import UIKit

var tableAssignmentList: [AssignmentItem] = [] // The assignment list that is displayed
var tableAssignmentList_checked: [AssignmentItem] = []
var tableAssignmentListDivider: Int = 0 // The index of the first item that shoud be in the completed section
var uncheckedTableAssignmentCount: Int = 0

var tableSubjectList: [SubjectItem] = []
var tableSubjectList_selectedRow: Int = 0


func syncAssignmentListWithFocus () {
    let request = URLRequest(url: URL(string: "https://focus.mvcs.org/focus")!)
    curFrmAssignmentList.webView.loadHTMLString("", baseURL: URL(string: "about:blank")!)
    curFrmAssignmentList.webView.loadRequest(URLRequest(url: URL(string: "about:blank")!))
    curFrmAssignmentList.webView.reload()
    curFrmAssignmentList.webView.loadRequest(request)
    
    curFrmAssignmentList.activityStart()
    
    /*
    let when = DispatchTime.now() + 40
    DispatchQueue.main.asyncAfter(deadline: when) {
        curFrmAssignmentList.LoginOvertime()
    }
 */
}


class frmAssignmentList: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    // MARK: Form Outlets
    
    @IBOutlet weak var vLeft: UIView!
    @IBOutlet weak var tblSubjectList: UITableView!
    
    @IBOutlet weak var vRight: UIView!
    @IBOutlet weak var vRightCenter: UIView!
    @IBOutlet weak var tblAssignmentList: UITableView!
    @IBOutlet weak var btnShowCompleted: ZFRippleButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lbSyncingWithFocus: UILabel!
    
    // Layout
    
    @IBOutlet weak var _layout_vRightTopHeightAnchor: NSLayoutConstraint!
    
    // Variables
    
    var showAllSubjectAssignment: Bool = true
    var currentSubjectName: String = ""
    
    var loadedFromSystem: Bool = false
    
    // MARK: - System Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAssignmentList.delegate = self
        tblAssignmentList.dataSource = self
        tblSubjectList.delegate = self
        tblSubjectList.dataSource = self
    
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
        
        _layout_vRightTopHeightAnchor.constant = 46
        lbSyncingWithFocus.alpha = 1
        
        refreshTableAssignmentList()
        
        activityStop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (userSettings.focusUsername != "" && userSettings.focusPassword != "") {
            loggedInFocus = true
            loginFromSettigns = false
            syncAssignmentListWithFocus()
        } else {
            loggedInFocus = false
        }
    }
    
    // MARK: - Focus Login Handler
    
    func LoginOvertime () {
        activityStop()
        if (!loggedInFocus) {
            Drop.down("Loggin Overtime. Please Check Your Internet.", state: .warning)
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
                self.progressView.progress += 0.0011
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
    
    @IBAction func btnAdd_Tapped(_ sender: Any) {
        _EDIT_MODE_ = false
    }
    
    var showingChecked: Bool = false
    @IBAction func btnShowCompleted_Tapped(_ sender: Any) {
        showingChecked = !showingChecked
        btnShowCompleted.setTitle((showingChecked ? "Hide Completed" : "Show Completed"), for: .normal)
        self.refreshTableAssignmentList()
        if (showingChecked) {
            tblAssignmentList.scrollToRow(at: IndexPath(row: uncheckedTableAssignmentCount, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == tblSubjectList) {
            if (indexPath.row == 0) {
                showAllSubjectAssignment = true
            } else {
                showAllSubjectAssignment = false
                currentSubjectName = tableSubjectList[indexPath.row].name
            }
            
            tableSubjectList_selectedRow = indexPath.row
            refreshTableAssignmentList(formatTable: true, refreshSubject: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (tableView == tblAssignmentList) {
            return 1
        } else if (tableView == tblSubjectList) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tblAssignmentList) {
            return tableAssignmentList.count
        } else if (tableView == tblSubjectList) {
            return tableSubjectList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (tableView == tblAssignmentList) {
            return ""
        } else if (tableView == tblSubjectList) {
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
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Data
    
    func swaptable (a: Int, b: Int) {
        let c = tableAssignmentList[a]
        tableAssignmentList[a] = tableAssignmentList[b]
        tableAssignmentList[b] = c
    }
    
    func swaptable_checked (a: Int, b: Int) {
        var c = tableAssignmentList_checked[a]
        tableAssignmentList_checked[a] = tableAssignmentList_checked[b]
        tableAssignmentList_checked[b] = c
    }
    
    func formatTableData () {
        tableAssignmentList = []
        tableAssignmentList_checked = []
        if (assignmentList.count == 0) {
            return
        }
        if (assignmentList.count == 1) {
            if (showAllSubjectAssignment) {
                if (assignmentList[0].checked) {
                    tableAssignmentList_checked.append(assignmentList[0])
                } else {
                    tableAssignmentList.append(assignmentList[0])
                }
            } else if (currentSubjectName == assignmentList[0].subject) {
                if (assignmentList[0].checked) {
                    tableAssignmentList_checked.append(assignmentList[0])
                } else {
                    tableAssignmentList.append(assignmentList[0])
                }
            }
        } else {
            for i in 0 ... (assignmentList.count - 1) {
                if (!showAllSubjectAssignment && currentSubjectName != assignmentList[i].subject) {
                    continue
                }
                if (assignmentList[i].checked) {
                    tableAssignmentList_checked.append(assignmentList[i])
                } else {
                    tableAssignmentList.append(assignmentList[i])
                }
            }
            tableAssignmentListDivider = tableAssignmentList.count
            if (tableAssignmentList.count > 1) {
                for i in 0 ... (tableAssignmentList.count - 2) {
                    for j in (i + 1) ... (tableAssignmentList.count - 1) {
                        if (tableAssignmentList[i].dueDate.timeIntervalSince1970 > tableAssignmentList[j].dueDate.timeIntervalSince1970) {
                            swaptable(a: i, b: j)
                        } else if (tableAssignmentList[i].dueDate == tableAssignmentList[j].dueDate) {
                            if (tableAssignmentList[i].priority < tableAssignmentList[j].priority) {
                                swaptable(a: i, b: j)
                            } else if (tableAssignmentList[i].priority == tableAssignmentList[j].priority) {
                                if (tableAssignmentList[i].subject.compare(tableAssignmentList[j].subject) == ComparisonResult.orderedDescending) {
                                    swaptable(a: i, b: j)
                                }
                            }
                        }
                    }
                }
            }
            if (tableAssignmentList_checked.count > 1) {
                for i in 0 ... (tableAssignmentList_checked.count - 2) {
                    for j in (i + 1) ... (tableAssignmentList_checked.count - 1) {
                        if (tableAssignmentList_checked[i].dueDate.timeIntervalSince1970 > tableAssignmentList_checked[j].dueDate.timeIntervalSince1970) {
                            swaptable_checked(a: i, b: j)
                        }
                    }
                }
            }
            uncheckedTableAssignmentCount = tableAssignmentList.count
            if (showingChecked) {
                tableAssignmentList.append(contentsOf: tableAssignmentList_checked)
            }
        }
    }
    
    func refreshShowCompletedButton () {
        if (tableAssignmentList_checked.count == 0) {
            showingChecked = false
            btnShowCompleted.setTitle("Show Completed", for: .normal)
            btnShowCompleted.isEnabled = false
            btnShowCompleted.setTitleColor(scrollGray, for: .normal)
        } else {
            btnShowCompleted.isEnabled = true
            btnShowCompleted.setTitleColor(themeColor, for: .normal)
        }
    }
    
    func refreshTableAssignmentList (formatTable: Bool = true, refreshSubject: Bool = true) {
        
        if (formatTable) {
            formatTableData()
        }
        //printTableAssignments()
        refreshShowCompletedButton()
        tblAssignmentList.reloadData()
        
        refreshTableSubject()
    }
    
    func refreshTableSubject() {
        tableSubjectList = []
        let allSubject = SubjectItem()
        allSubject.name = "All Assignments"
        tableSubjectList.append(allSubject)
        tableSubjectList.append(contentsOf: subjectList)
        
        tblSubjectList.reloadData()
    }
    
    // MARK: - Table View Action
    
    func editAssignment (id: Int) {
        _EDIT_ID_ = id
        _EDIT_MODE_ = true
        self.performSegue(withIdentifier: "segueShowFrmNewAssignment", sender: self)
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
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

