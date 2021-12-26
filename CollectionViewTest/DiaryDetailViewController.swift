
import UIKit

protocol DiaryDelegate: AnyObject {
    func sendDiaryInfo(diary: DiaryInfo)
}
enum DiaryEditMode {
    case new
    case edit(_ diary: DiaryInfo,_ uuid: String)
}

class DiaryDetailViewController: UIViewController {
    
    @IBOutlet var addBtn: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var dateTextField: UITextField!
   
    weak var diaryDelegate: DiaryDelegate?
    private let datePicker = UIDatePicker()
    private var date: Date?
    
    var diary: DiaryInfo?
    var diaryEditMode: DiaryEditMode = .new
    var star: Bool?
    
    
    override func viewDidLoad() {
        
        self.contentTextView.layer.borderColor = UIColor.red.cgColor
        self.contentTextView.layer.borderWidth = 1.0
        self.addBtn.isEnabled = false
        self.configureDatePicker()
        self.inputTextChangeConfigure()
        self.configureEditMode()
    }
    private func configureEditMode() {
        switch self.diaryEditMode {
        case let .edit(diary,_):
            self.titleTextField.text = diary.title
            self.contentTextView.text = diary.content
            self.dateTextField.text = self.dateToString(diary.date)
            self.date = diary.date
            self.star = diary.isStar
            self.addBtn.title = "수정"
        default:
            break
        }
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        let dateStr = formatter.string(from: date)
        return dateStr
    }

    private func configureDatePicker() {
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.datePickerMode = .date
        self.datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldConfigure), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldConfigure), for: .editingChanged)
    }
    
    @objc private func datePickerDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 년 MM월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        self.date = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        self.TextInvalidInput()
    }
    
    //Text View Delegate ViewController 에게 위임
    private func inputTextChangeConfigure() {
        self.contentTextView.delegate = self
    }
    @objc private func titleTextFieldConfigure() {
        self.TextInvalidInput()
    }
    @objc private func dateTextFieldConfigure() {
        self.TextInvalidInput()
    }
    
    private func TextInvalidInput(){
        self.addBtn.isEnabled =
        !(self.titleTextField.text?.isEmpty ?? true)
        && !(self.dateTextField.text?.isEmpty ?? true)
        && !(self.contentTextView.text.isEmpty)
    }
    
    @IBAction func addBtnClicked(_ sender: UIBarButtonItem) {
       
        guard let title = self.titleTextField.text else {return}
        guard let content = self.contentTextView.text else {return}
        guard let date = self.date else {return}
         
        switch self.diaryEditMode {
    
        case .new:
            let uuid = UUID().uuidString
            let diary = DiaryInfo(uuidString: uuid, title: title, content: content, date: date, isStar: false)
            self.diaryDelegate?.sendDiaryInfo(diary: diary)
            
        case let .edit(_,uuid):
            guard let isStar = self.star else {return}
            let diary = DiaryInfo(uuidString: uuid, title: title, content: content, date: date, isStar: isStar)
            
            NotificationCenter.default.post(
                name: Notification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension DiaryDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.TextInvalidInput()
    }
    
}
public extension UITextField {
    func setPlaceholderColor(_ placeholderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
    
}

