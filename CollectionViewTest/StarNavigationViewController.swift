
import UIKit

class StarNavigationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var collectionViewCell: [UICollectionViewCell] = []
    var diaryList: [DiaryInfo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "즐겨찾기"
        self.navigationController?.navigationBar.tintColor = .orange
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor : UIColor.orange,
            .font : UIFont.boldSystemFont(ofSize: 20)
        ]
      
        
        print("starViewDidLoad")
        self.configureCollectionView()
        self.configureView()
        self.configureRefreshController()
     
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editNotifiCation(_:)),
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
    } //viewDidLoad

    
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
    
    
    
    
    @objc func editNotifiCation(_ notification: Notification){
        print("starNavigationEditNotifiCation")
        guard let diary = notification.object as? DiaryInfo else {return}
        if let index = self.diaryList.firstIndex(where: {$0.uuidString == diary.uuidString}){
            self.diaryList[index] = diary
        }else {print("오류 발생")}
        self.configureView()
    }
    
    @objc func starSelectNotification(_ notification: Notification){
        guard let starAndIndex = notification.object as? [String : Any] else {return}
        guard let diary = starAndIndex["diary"] as? DiaryInfo else {return}
        guard let uuid = starAndIndex["uuidString"] as? String else {return}
        guard let isStar = starAndIndex["isStar"] as? Bool else {return}
        
        if let index = self.diaryList.firstIndex(where: {$0.uuidString == uuid})
        {
            self.diaryList[index].isStar = isStar
        }
        else {
            self.diaryList.append(diary)
        }
        self.configureView()
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification){
        guard let uuid = notification.object as? String else {return}
        print(uuid)
        if let index = self.diaryList.firstIndex(where: {$0.uuidString == uuid}){
            self.diaryList.remove(at: index)
            self.configureView()
        }
    }
  
    private func configureView() {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.object(forKey: "DiaryList") as? [[String : Any]] else {return}
        self.diaryList = data.compactMap {
            guard let uuid = $0["uuidString"] as? String else {return nil}
            guard let title = $0["title"] as? String else {return nil}
            guard let content = $0["content"] as? String else {return nil}
            guard let date = $0["date"] as? Date else {return nil}
            guard let isStar = $0["isStar"] as? Bool else {return nil}
            return DiaryInfo(uuidString: uuid,title: title, content: content, date: date, isStar: isStar)
        }.filter{
            $0.isStar == true
        }.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    } //configureView DiaryList 구성 함수
    
    private func configureCollectionView() {
        
        self.collectionView.backgroundColor = UIColor.black
        self.view.backgroundColor = UIColor.black
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        let dateStr = formatter.string(from: date)
        return dateStr
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("starNavigationView Deinit")
    }
}

extension StarNavigationViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryUpdateViewController") as? DiaryUpdateViewController else {return}
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.diary = self.diaryList[indexPath.row]
        viewController.indexPath = indexPath
    }
    
   
}

extension StarNavigationViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else {return UICollectionViewCell()}
        let diary = self.diaryList[indexPath.row]
      
        cell.titleCell.text = diary.title
        cell.dateCell.text = self.dateToString(diary.date)
        cell.titleCell.textColor = .white
        cell.dateCell.textColor = .white
        self.collectionViewCell.append(cell)
        return cell
    }
}

extension StarNavigationViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 20), height: 100)
    }
    
}


