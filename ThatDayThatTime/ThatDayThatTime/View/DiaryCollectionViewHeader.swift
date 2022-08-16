//
//  DiaryCollectionViewHeader.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/15.
//

import UIKit
import SnapKit

final class DiaryCollectionViewHeader: UICollectionReusableView {
    
    static let identifier = "SearchDiaryCollectinViewHeader"
    
    // MARK: - ViewProperties
    private let diaryKindLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private let dateLineView = DateLineView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .viewBackgroundColor
        diaryKindLabel.isHidden = true
        dateLineView.isHidden = true
        configureSubViews()
        setConstraintsOfStackView()
        setConstraintsOfDiaryKindLabel()
        setConstraintsOfDateLineView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method
extension DiaryCollectionViewHeader {
    override func prepareForReuse() {
        super.prepareForReuse()
        diaryKindLabel.isHidden = true
        dateLineView.isHidden = true
    }
    
    func configureHeader(diary: Diary?, section: Int) {
        if diary is TimeDiary {
            diaryKindLabel.text = "시간의 기록"
            dateLineView.configureDateLabel(date: diary?.date ?? "")
            if section != 0 {
                diaryKindLabel.isHidden = true
                dateLineView.isHidden = false
            } else {
                diaryKindLabel.isHidden = false
                dateLineView.isHidden = false
            }
        } else if diary is DayDiary {
            dateLineView.isHidden = true
            diaryKindLabel.isHidden = false
            diaryKindLabel.text = "하루의 기록"
        }
    }
    
    func configureHeader(date: String) {
        diaryKindLabel.isHidden = false
        dateLineView.isHidden = true
        diaryKindLabel.text = date
        diaryKindLabel.font = .systemFont(ofSize: 22, weight: .semibold)
    }
}

// MARK: - UI
extension DiaryCollectionViewHeader {
    private func configureSubViews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        [diaryKindLabel, dateLineView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setConstraintsOfStackView() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setConstraintsOfDiaryKindLabel() {
        diaryKindLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
        }
    }
    
    private func setConstraintsOfDateLineView() {
        dateLineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
}
