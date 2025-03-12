//
//  TimeRangePickerView.swift
//  Powerly
//
//  Created by ADMIN on 16/08/24.
//  
//

import UIKit

class TimeRangePickerView: UIView {
    @IBOutlet weak var minuteCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    let timeArray = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 21, 23, 24, 1, 2, 3, 4, 5, 6, 7]
    let minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    let numberOfColumns = 6
    let numberOfRows = 4
    var selectedTime = -1
    var selectedMinute = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "TimeRangePickerView", bundle: Bundle(for: type(of: self)))
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        timeCollectionView.register(UINib(nibName: TimeCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: TimeCollectionViewCell.className)
        
        minuteCollectionView.register(UINib(nibName: MinuteCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: MinuteCollectionViewCell.className)
    }
}

extension TimeRangePickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == timeCollectionView {
            return timeArray.count
        } else {
            return minutes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == timeCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCollectionViewCell.className, for: indexPath) as? TimeCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.timeLabel.text = "\(timeArray[indexPath.item])"
            if selectedTime == indexPath.item {
                cell.outView.backgroundColor = (indexPath.item < 12) ? UIColor(named: "008CE9"):UIColor(named: "666666")
                cell.timeLabel.textColor = UIColor(named: "WHITE")
                cell.amPmLabel.textColor = UIColor(named: "WHITE")
            } else {
                cell.outView.backgroundColor = .clear
                cell.timeLabel.textColor = UIColor(named: "222222")
                cell.amPmLabel.textColor = UIColor(named: "999999")
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MinuteCollectionViewCell.className, for: indexPath) as? MinuteCollectionViewCell else {
                return UICollectionViewCell()
            }
            let minute = minutes[indexPath.item]
            let formattedMinute = String(format: ":%02d", minute)
            cell.minuteLabel.text = formattedMinute
            if selectedMinute == indexPath.item {
                cell.outView.backgroundColor = UIColor(named: "E8E8E8")
            } else {
                cell.outView.backgroundColor = .clear
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == timeCollectionView {
            let padding: CGFloat = 10
            let collectionViewWidth = collectionView.frame.width - padding
            let collectionViewHeight = collectionView.frame.height - padding
            
            let itemWidth = collectionViewWidth / CGFloat(numberOfColumns)
            let itemHeight = collectionViewHeight / CGFloat(numberOfRows)
            
            return CGSize(width: itemWidth, height: itemHeight)
        } else {
            return CGSize(width: 48, height: 48)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == timeCollectionView {
            selectedTime = indexPath.item
            timeCollectionView.reloadData()
        } else {
            selectedMinute = indexPath.item
            minuteCollectionView.reloadData()
        }
    }
}
