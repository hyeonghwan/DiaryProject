

import UIKit

class ViewController: UIViewController{
   
  
    @IBOutlet weak var collectionView: UICollectionView!
    private var diaryList: [DiaryInfo] = [] {
        didSet {
            print("didset SaveData")
            self.saveData()
        }
    }
    var tempArray: [DiaryInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        print("load data")
        self.configurationLayout()
        self.loadData()
        self.configureRefreshController()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editDiaryNotification(_ :)),
                                               name: Notification.Name("editDiary"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(starSelectNotification(_ :)),
                                               name: Notification.Name("StarDiary"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deleteDiaryNotification(_ :)),
                                               name: Notification.Name("DeleteDiary"),
                                               object: nil)
        
    }
    fileprivate func configureRefreshController() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "땡겨!~", attributes: [
            .foregroundColor : UIColor.orange.cgColor,
            .font : UIFont.boldSystemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(handleRefreshControll), for: .valueChanged)
        refreshControl.tintColor = .orange
        self.collectionView.refreshControl = refreshControl
    }
    @objc fileprivate func handleRefreshControll(){
        self.collectionView.visibleCells.forEach{
            $0.alpha = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self = self else {return}
            self.collectionView.visibleCells.forEach{
                $0.alpha = 1.0
            }
            self.collectionView.refreshControl?.endRefreshing()
        })
      
    }
    @objc private func editDiaryNotification(_ notification: Notification) {
        print("editDiaryNotification")
        guard let diary = notification.object as? DiaryInfo else {return}
//        guard let index = notification.userInfo?["indexPath.row"] as? Int else {return}
//        self.diaryList[index] = diary
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == diary.uuidString}) else {return}
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func starSelectNotification(_ notification: Notification){
        guard let starAndIndex = notification.object as? [String : Any] else {return}
        guard let star = starAndIndex["isStar"] as? Bool else {return}
        guard let uuid = starAndIndex["uuidString"] as? String else {return}
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuid}) else {return}
        self.diaryList[index].isStar = star
        self.collectionView.reloadData()
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification){
        guard let uuid = notification.object as? String else {return}
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuid}) else {return}
        self.diaryList.remove(at: index)
        self.collectionView.reloadData()
    }
    
    private func configurationLayout() {
        
        self.view.backgroundColor = .black
        self.navigationController?.navigationBar.backgroundColor = .black
        self.navigationController?.navigationBar.tintColor = .orange
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        self.tabBarController?.tabBar.tintColor = .orange
        
        
        self.collectionView.backgroundColor = .black
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? DiaryDetailViewController else {return}
        viewController.diaryDelegate = self
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        let dateStr = formatter.string(from: date)
        return dateStr
    }
    
    private func saveData() {
        let data = self.diaryList.map {
            [
             "uuidString" : $0.uuidString,
             "title" : $0.title,
             "date" : $0.date,
             "content" : $0.content,
             "isStar" : $0.isStar
            ]
        }
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "DiaryList")
        self.collectionView.reloadData()
    }
    
    private func loadData() {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.object(forKey: "DiaryList") as? [[String : Any]] else {return}
        self.diaryList = data.compactMap{
            guard let uuid = $0["uuidString"] as? String else {return nil}
            guard let title = $0["title"] as? String else {return nil}
            guard let date = $0["date"] as? Date else {return nil}
            guard let content = $0["content"] as? String else {return nil}
            guard let isStar = $0["isStar"] as? Bool else {return nil}
            return DiaryInfo(uuidString: uuid,title: title, content: content, date: date, isStar: isStar)
        }
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
 
}

extension ViewController: DiaryDelegate {
    func sendDiaryInfo(diary: DiaryInfo) {
        self.diaryList.append(diary)
        self.collectionView.reloadData()
    }
}


extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryUpdateViewController") as? DiaryUpdateViewController else {return}
        viewController.diary = self.diaryList[indexPath.row]
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}


extension ViewController: UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath)
                as? DiaryCell else {return UICollectionViewCell()}
        let diary = self.diaryList[indexPath.row]
        cell.diaryCellTitle.text = diary.title
        cell.diaryCellDate.text = self.dateToString(diary.date)
        cell.diaryCellDate.textColor = .white
        cell.diaryCellTitle.textColor = .white
        return cell
    }
}
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: (UIScreen.main.bounds.width / 2) - 20)
    }
}


