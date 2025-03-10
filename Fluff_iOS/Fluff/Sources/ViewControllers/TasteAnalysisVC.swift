//
//  TasteAnalysisVC.swift
//  Fluff_iOS
//
//  Created by 윤동민 on 2019/12/23.
//  Copyright © 2019 TaeJin Oh. All rights reserved.
//

import UIKit

class TasteAnalysisVC: UIViewController {

    @IBOutlet weak var tasteCollectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var oneDescriptionLabel: UILabel!
    @IBOutlet weak var twoDescriptionLabel: UILabel!
    
    private var userToken: String?
    private var selectedCount: Int = 0
    private var surveyResult: SurveyResult = SurveyResult()
    
    private var isSelected: [Bool] = []
    // 임시변수 선택 정할
    private var analysisStatus: AnalysisStatus?
    private var clothesInformation: [ClotheInformation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.layoutIfNeeded()
        tasteCollectionView.dataSource = self
        tasteCollectionView.delegate = self
        initialButton()
        initFont()
        
        selectButton.setTitle("3개 이상 선택해주세요", for: .normal)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initToken()
        requestClothImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userToken = nil
        analysisStatus = nil
    }
    
    private func initToken() {
        guard let userToken = UserDefaults.standard.value(forKey: "token") as? String else { return }
        self.userToken = userToken
    }

    private func initialButton() {
        selectButton.makeCornerRounded(radius: selectButton.frame.width / 15)
        selectButton.isUserInteractionEnabled = false
    }
    
    private func initFont() {
        titleLabel.attributedText = NSMutableAttributedString(string: "당신의 스타일을 선택해주세요!", attributes: [
            .font: UIFont(name: "S-CoreDream-5Medium", size: 24.0)!,
          .foregroundColor: UIColor.black,
          NSAttributedString.Key.kern: CGFloat(-1.92)
        ])
        oneDescriptionLabel.attributedText = NSMutableAttributedString(string: "평소에 좋아하는 옷 스타일을 선택해주세요", attributes: [.font: UIFont(name: "KoPubWorldDotumPM", size: 15)!, .foregroundColor: UIColor.greyishBrown, NSAttributedString.Key.kern: CGFloat(-0.3)
        ])
        twoDescriptionLabel.attributedText = NSMutableAttributedString(string: "플러프가 당신이 좋아할만한 옷을 추천해드립니다!", attributes: [.font: UIFont(name: "KoPubWorldDotumPM", size: 15)!, .foregroundColor: UIColor.greyishBrown, NSAttributedString.Key.kern: CGFloat(-0.3)])
    }
    
    func setAnalysisStatus(_ analysisStatus: AnalysisStatus) {
        self.analysisStatus = analysisStatus
    }
    
    @IBAction func goAnalysisNext(_ sender: Any) {
        guard let userToken = self.userToken else { return }
        guard let analysisStatus = self.analysisStatus else { return }
        switch analysisStatus {
        case .signup:
            print("초기 설정")
            if selectedCount >= 3 {
                // 서버 열리면 추가하기
                RecommendService.shared.recommendPutData(surveyResult: self.surveyResult, token: userToken) { networkResult in
                    switch networkResult {
                    case .success(let data):
                        guard let recomendedData = data as? RecommendedJSONData else { return }
                        // 로그 찍어보기
                        print(recomendedData.message)
                        print("Hi")
                        guard let nextAnalysisVC = self.storyboard?.instantiateViewController(identifier: "ThreeTasteAnalysisVC") as? NextTasteAnalysisVC else { return }
                        nextAnalysisVC.modalPresentationStyle = .fullScreen
                        nextAnalysisVC.setAnalysisStatus(analysisStatus)
                        self.present(nextAnalysisVC, animated: true, completion: nil)
                    case .requestErr(let data):
                        guard let recommendedData = data as? RecommendedJSONData else { return }
                        self.presentAlertController(title: recommendedData.message, message: nil)
                    case .pathErr:
                        self.presentAlertController(title: "경로 에러", message: "경로가 잘못되었습니다.")
                    case .serverErr:
                        self.presentAlertController(title: "서버 내부 오류", message: "서버내부에 오류가 발생하였습니다.")
                    case .networkFail:
                        self.presentAlertController(title: "네트워크 연결 실패", message: "네트워크 연결이 필요합니다.")
                    }
                }
            }
        default:
            print("재설정 실행")
            if selectedCount >= 3 {
                // 서버 열리면 추가하기
                RecommendService.shared.recommendPutData(surveyResult: self.surveyResult, token: userToken) { networkResult in
                    switch networkResult {
                    case .success(let data):
                        guard let recomendedData = data as? RecommendedJSONData else { return }
                        print(recomendedData.message)
                        guard let nextAnalysisVC = self.storyboard?.instantiateViewController(identifier: "ThreeTasteAnalysisVC") as? NextTasteAnalysisVC else { return }
                        nextAnalysisVC.setAnalysisStatus(analysisStatus)
                        self.navigationController?.pushViewController(nextAnalysisVC, animated: true)
                    case .requestErr(let data):
                        guard let recommendedData = data as? RecommendedJSONData else { return }
                        self.presentAlertController(title: recommendedData.message, message: nil)
                    case .pathErr:
                        self.presentAlertController(title: "경로 에러", message: "경로가 잘못되었습니다.")
                    case .serverErr:
                        self.presentAlertController(title: "서버 내부 오류", message: "서버내부에 오류가 발생하였습니다.")
                    case .networkFail:
                        self.presentAlertController(title: "네트워크 연결 실패", message: "네트워크 연결이 필요합니다.")
                    }
                }
            }
        }
    }
}

extension TasteAnalysisVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothesInformation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tasteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tasteCell", for: indexPath) as? TasteCollectionViewCell else { return UICollectionViewCell() }
        if isSelected[indexPath.row] { tasteCell.setCoverView() }
        else { tasteCell.hideCoverView() }
        tasteCell.setClotheImage(url: clothesInformation[indexPath.row].img)
        return tasteCell
    }
}

extension TasteAnalysisVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 5) / 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
}

extension TasteAnalysisVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? TasteCollectionViewCell else { return }
        selectedCell.selected(isSelected[indexPath.row])
        countSelectedItem(selectedIndex: indexPath.row)
        
        if selectedCount >= 3 {
            selectButton.backgroundColor = .black
            selectButton.titleLabel?.textColor = . white
            selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            selectButton.setTitle("다음", for: .normal)
            selectButton.isUserInteractionEnabled = true
        } else {
            selectButton.backgroundColor = UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1.0)
            selectButton.titleLabel?.textColor = .white
            selectButton.setTitle("3개 이상을 선택해주세요", for: .normal)
            selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            selectButton.isUserInteractionEnabled = false
        }
        isSelected[indexPath.row] = !isSelected[indexPath.row]
    }
    
    private func countSelectedItem(selectedIndex: Int) {
        let selectedStyle = clothesInformation[selectedIndex].style
        if isSelected[selectedIndex] && selectedCount != 0 {
            for eachStyle in selectedStyle {
                surveyResult.setCount(by: eachStyle, isPlus: false)
            }
            selectedCount -= 1
        } else {
            selectedCount += 1
            for eachStyle in selectedStyle {
                surveyResult.setCount(by: eachStyle, isPlus: true)
            }
        }
    }
}

extension TasteAnalysisVC {
    private func requestClothImage() {
        guard let userToken = self.userToken else { return }
        TasteAnalysisService.shared.tasteAnalysis(token: userToken) { networkResult in
            switch networkResult {
            case .success(let data):
                guard let surveyInform = data as? SurveyInformation else { return }
                self.clothesInformation = surveyInform.surveyList
                for _ in self.clothesInformation {
                    self.isSelected.append(false)
                }
                self.tasteCollectionView.reloadData()
            case .requestErr(let data):
                guard let clotheData = data as? TasteAnalysisData else { return }
                self.presentAlertController(title: clotheData.json.message, message: nil)
            case .pathErr:
                self.presentAlertController(title: "path Error", message: nil)
            case .serverErr:
                self.presentAlertController(title: "서버 오류", message: "서버 내부 오류가 있습니다.")
            case .networkFail:
                self.presentAlertController(title: "네트워크 연결 실패", message: "네트워크 연결이 필요합니다")
            }
        }
    }
}
