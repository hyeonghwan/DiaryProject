
import UIKit

class DiaryUpdateViewController: UIViewController {
    
  
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak  var contentField: UITextView!
    @IBOutlet weak  var dateFiled: UITextField!
    var buttonItem: UIBarButtonItem?
    var diary: DiaryInfo?
    var indexPath: IndexPath?
    var date: Date?
    var datePicker = UIDatePicker()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataFiled()
        self.configurationDatePicker()
        self.configureTextColor()
    }
  
    
    func configureTextColor(){
        self.view.backgroundColor = .black
        self.titleLabel.textColor = .white
        self.titleLabel.font = .boldSystemFont(ofSize: 20)
        self.contentLabel.textColor = .white
        self.dateLabel.textColor = .white
        self.titleField.layer.borderColor = UIColor.white.cgColor
        self.titleField.setPlaceholderColor(.red)
        self.titleField.placeholder = "제목을 입력해주세요"
        self.contentField.layer.borderColor = UIColor.white.cgColor
        self.dateFiled.layer.borderColor = UIColor.white.cgColor
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeStar(_ :)),
                                               name: Notification.Name("StarDiary"),
                                               object: nil)
    }
    @objc func changeStar(_ notification: Notification) {
     
    }
    
    func configureDataFiled() {
        guard let title = self.diary?.title else {return}
        guard let content = self.diary?.content else {return}
        guard let date = self.diary?.date else {return}
        guard let star = self.diary?.isStar else {return}
        self.titleField.text = title
        self.contentField.text = content
        self.dateFiled.text = dateToString(date)
        
        self.buttonItem = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(clickedStarButton))
        self.buttonItem?.image = star ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.buttonItem?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.buttonItem
    }//configureDataFiled()
    
    
    @objc private func clickedStarButton() {
        guard let isStar = self.diary?.isStar else {return}
//        guard let cellindex = self.indexPath else {return}
        guard let uuid = self.diary?.uuidString else {return}
    
        self.diary?.isStar = !isStar
        guard let diary = self.diary else {return}
        guard let star = self.diary?.isStar else {return}
    
        NotificationCenter.default.post(
            name: Notification.Name("StarDiary"),
            object: [
                "diary" : diary,
                "uuidString" : uuid,
                "isStar" : star
            ],
            userInfo: nil)
        
        switch star {
        case true:
            self.buttonItem?.image = UIImage(systemName: "star.fill")
        default:
            self.buttonItem?.image = UIImage(systemName: "star")
        }
       
    }//clickedStarButton()
    
    
    func configurationDatePicker() {
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.datePickerMode = .date
        self.datePicker.addTarget(self, action: #selector(datepickerDidChange), for: .valueChanged)
        self.dateFiled.inputView = self.datePicker
    }
    @objc private func datepickerDidChange(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 년 MM 월 dd 일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        self.date = datePicker.date
        self.dateFiled.text = formatter.string(from: datePicker.date)
    }
    

    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        let dateStr = formatter.string(from: date)
        return dateStr
    }
 
    
    //수정 버튼 클릭시 발동 이벤트 
    @IBAction func addBtnClicked(_ sender: UIButton) {
        guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return}
        guard let diary = self.diary else {return}
        guard let uuid = self.diary?.uuidString else {return}
//        guard let indexPath = self.indexPath else {return}
        detailViewController.diaryEditMode = .edit( diary, uuid)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editDiaryNotification(_ :)),
                                               name: Notification.Name("editDiary"), object: nil)
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    @objc func editDiaryNotification(_ notification: Notification){
        guard let diary = notification.object as? DiaryInfo else {return}
        //guard let index = notification.userInfo?["indexPath.row"] as? Int else {return}
        self.diary = diary
        self.configureDataFiled()
    }
  
    
    
    @IBAction func DeleteBtnClicked(_ sender: UIButton) {
        
        guard let index = self.diary?.uuidString else {return}
        print(index)
        NotificationCenter.default.post(
            name: Notification.Name("DeleteDiary"),
            object: index,
            userInfo: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("updateVIew Deinit")
    }
}



// 이것은 DiaryUpdateViewController 에서 Delegate 연결해서 직접 수정하는 코드
//@IBAction func addBtnClicked(_ sender: UIButton) {
//    guard let title = self.titleField.text else {return}
//    guard let content = self.contentField.text else {return}
//    guard let date = self.date else {return}
//    guard let cellindex = self.indexPath else {return}
//    let diary = DiaryInfo(title: title, content: content, date: date, isStar: false)
//    self.updateDelegate?.sendUpdateData(diary: diary, indexPath: cellindex)
//    self.navigationController?.popViewController(animated: true)
//
//}
