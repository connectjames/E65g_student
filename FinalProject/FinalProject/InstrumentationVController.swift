//
//  InstrumentationVController.swift
//  FinalProject
//
//
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
// ICON Ref: https://cdn4.iconfinder.com/data/icons/ionicons/512/icon-ios7-gear-outline-512.png

import UIKit
import Foundation
let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

struct GridInit {
    var title: String
    let contents: [[Int]]
    let maxDim: Int
}

var jsonTitles:Array<String> = Array<String>()

class InstrumentationVController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var blurredView: UIVisualEffectView!
    
    @IBOutlet weak var rowTxtFld: UITextField!
    
    @IBOutlet weak var colTxtFld: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var rowStepper: UIStepper!
    
    @IBOutlet weak var colStepper: UIStepper!
    
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    @IBOutlet weak var refreshOnOff: UISwitch!
    
    var engine = StandardEngine.shared()
    var jsonTitles2:Array<String> = Array<String>()
    public var gridInits: [GridInit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //userDefaultSetBlank()
        if let x = retrieveUserDefault() as? [Any] {
            if(x.count < 4) {
                
                let fetch = getJSON()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                fetch.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
                    guard message == nil else {
                        print(message ?? "nil")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                    guard let json = json else {
                        print("not json")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                    
                    var maxDim: Int
                    var temp: Int
                    _ = (json as AnyObject).description
                    let jsonArray = json as! NSArray
                    
                    for i in 0..<jsonArray.count {
                        let jsonDictionary = jsonArray[i] as! NSDictionary
                        
                        let jsonTitle = jsonDictionary["title"] as! String
                        let jsonContents = jsonDictionary["contents"] as! [[Int]]
                        
                        maxDim = 0
                        temp = 0
                        for j in 0..<(jsonContents.count) {
                            if (jsonContents[j][0] > jsonContents[j][1])
                            {
                                temp = jsonContents[j][0]
                            }
                            else
                            {
                                temp = jsonContents[j][1]
                            }
                            if (temp > maxDim)
                            {
                                maxDim = temp
                            }
                        }
                        let gridInit = GridInit(title: jsonTitle, contents: jsonContents, maxDim: maxDim)
                        self.gridInits.append(gridInit)
                    }
                    
                    OperationQueue.main.addOperation ({
                        self.tableView.reloadData()
                        print("Loading into userdefaults")
                        self.saveAllGrid(grids: self.gridInits)
                        //                self.userDefaultSetBlank()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    })
                }
            }
            else {
               // print("Got Data \(retrieveUserDefault())")
                userDefaultToGridInit()
            }
        }
        

        // Do any additional setup after loading the view.
        blurredView.layer.cornerRadius = 15
        blurredView.layer.masksToBounds = true
        blurredView.clipsToBounds = true

        //engine = StandardEngine.shared()
        
        refreshOnOff.setOn(false, animated: false)
        
        rowStepper.value = Double(engine.rows)
        colStepper.value = Double(engine.cols)
        
        rowTxtFld.text = "\(engine.rows)"
        colTxtFld.text = "\(engine.cols)"
        tableView.dataSource = self
        tableView.delegate = self

//        refreshRateSlider.value = refreshRateSlider.minimumValue
//        refreshRateSlider.isEnabled = true

        
        

    }
    func userDefaultToGridInit(){
        let g = retrieveUserDefault() as? [Any]
        if(g != nil) {
            for i in g!{
                if let k: [String:Any] = i as? [String:Any] {
                    let j = GridInit(title: k["title"] as! String, contents: k["contents"] as! [[Int]], maxDim: k["maxDim"] as! Int)
                    self.gridInits.append(j)
                }
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will appear")
        
        engine = StandardEngine.shared()
        setEngineValues()
//        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func rowTxtFldAction(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.grid.size.rows)"
            }
            return
        }
        rowStepper.value = Double(val)
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", num: val)
    }

    @IBAction func colTxtFldAction(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.grid.size.cols)"
            }
            return
        }
        colStepper.value = Double(val)
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", num: val)
    }
    
    @IBAction func rowStepperAction(_ sender: UIStepper) {
        let numRows = Int(sender.value)
        rowTxtFld.text = "\(numRows)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "row", num: numRows)
        
    }

    @IBAction func colStepperAction(_ sender: UIStepper) {
        let numCols = Int(sender.value)
        colTxtFld.text = "\(numCols)"
        StandardEngine.shared().updateNumRowsOrCols(rowOrCol: "col", num: numCols)
    }
    @IBAction func updateTimerRefreshRate(_ sender: UISlider) {
                print(sender.value)
                engine.refreshTimer?.invalidate()
                engine.refreshRate = Double(Double(sender.value))
    }

    @IBAction func refreshToggle(_ sender: UISwitch) {
         StandardEngine.shared().toggleTimer(switchOn: refreshOnOff.isOn)
        
    }
//    @IBAction func refreshSliderAction(_ sender: UISlider) {
//        print(sender.value)
////        engine.refreshTimer?.invalidate()
////        engine.refreshRate = Double(Double(sender.value))
//
//
//    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gridInits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = gridInits[indexPath.item].title
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Configurations"
    }
    //MARK: AlertController Handling
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let gridStruct = gridInits[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
//                vc.navigationItem.title = "Grid Editor"
              //  vc.textF.text = gridStruct.title
                vc.gridStruct = gridStruct
                vc.instrument = self
                vc.saveClosure = { newValue in
                    self.gridInits[indexPath.row] = gridStruct
                    self.tableView.reloadData()
                }
            }
        }

    }
    func setEngineValues() {
        if(rowStepper.value != Double(StandardEngine.shared().rows) || colStepper.value != Double(StandardEngine.shared().cols)) {
            rowStepper.value = Double(StandardEngine.shared().rows)
            colStepper.value = Double(StandardEngine.shared().cols)
            
            rowTxtFld.text = "\(StandardEngine.shared().rows)"
            colTxtFld.text = "\(StandardEngine.shared().cols)"
            //StandardEngine.shared().engineUpdateNotify()
        }
    }
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        let saveAlertController = UIAlertController(title: "Add a name", message: nil, preferredStyle: .alert)
        saveAlertController.addTextField { (_) in
            
        }
        let saveAlertAction  = UIAlertAction(title: "Save", style: .default) { (_) in
          
            let tField = saveAlertController.textFields?.first?.text
            if (tField?.characters.count)! >= 1{
                if tField != nil{
                    //print(tField ?? "pill")
                    self.gridInits.append(GridInit(title: tField!, contents:[[]], maxDim: (Int(self.rowStepper.value) + Int(self.colStepper.value)) / 2))
                    DispatchQueue.global(qos: .background).async {
                        DispatchQueue.main.async {
                            self.userDefaultSetBlank()
                            
                            self.saveAllGrid(grids: self.gridInits)
                           // self.saveToUserDefaults(gridData: GridInit(title: tField!, contents:[[]], maxDim: 5))
//                            let f = FMan()
//                            f.saveToJsonFile(gridData: GridInit(title: tField!, contents:[[]], maxDim: 5))
                            self.tableView.reloadData()
                        }
                    }
                }else{
                    print("No Value")
                }

            }else{
                print("Too small")
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("Cancel")
        }
        saveAlertController.addAction(saveAlertAction)
        saveAlertController.addAction(cancelAction)
        present(saveAlertController, animated: true,completion: nil)
        
    }
    func saveAllGrid(grids: [GridInit]) {
        //clearing current
       // userDefaultSetBlank()
        //adding all updated back
        var arr = Array<Any>()
        
        for i in grids {
            var dic = Dictionary<String, Any>()
            dic["title"] = i.title
            dic["maxDim"] = i.maxDim
            dic["contents"] = i.contents
          //  print("APPENDING: \(dic)")
            arr.append(dic)
        }
        UserDefaults.standard.set(arr, forKey: "dataJson")
    }
//    func saveToUserDefaults(gridData: GridInit){
//        
//        if let dic: [[String: Any]] = [["title": gridData.title],["size": gridData.maxDim],["contents": gridData.contents]] {
//            UserDefaults.standard.set(dic , forKey: gridData.title)
//        }
//        //print("Saved Data in var: \(String(describing: lastgrid))")
////        let defaults = UserDefaults.standard
////        let arr = [[gridData.title : gridData.contents]]
////        defaults.set(arr, forKey: "Configurations")
//    }
    func retrieveUserDefault() -> Any? {
        return UserDefaults.standard.object(forKey: "dataJson")
//        print("GOT THE USER DEFAULTS: \(array)")
    }
//    func retrieveUserDefaultsData(){
//        let defaults = UserDefaults.standard
//        print(JSON.parse(defaults.object(forKey: "Configurations") as! String))
//    }
    func userDefaultSetBlank(){
        let arr = Array<Any>()
         UserDefaults.standard.set(arr, forKey: "dataJson")
        
    }
    
}
