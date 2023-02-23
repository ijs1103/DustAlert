//
//  DustCell.swift
//  dustAlert
//
//  Created by 이주상 on 2023/02/03.
//

import UIKit

final class DustCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dustConcentrationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var dust: Dust? {
        didSet {
            setUI()
        }
    }
    
    var handleLikeButtonTapped: ((DustCell, Bool) -> ()) = { (sender, pressed) in }
    
    private func setUI() {
        guard let dust = dust else { return }
        locationLabel.text = dust.location
        dustConcentrationLabel.text = dust.info?.grade ?? "관측 없음"
        self.backgroundColor = .clear
        self.contentView.layer.backgroundColor = dust.info?.color.cgColor ?? UIColor.gray.cgColor
        timeLabel.text = dust.time
        likeButton.contentHorizontalAlignment = .fill
        likeButton.contentVerticalAlignment = .fill
        likeButton.imageView?.contentMode = .scaleAspectFit
        setLikeButtonUI()
    }
    
    func setLikeButtonUI() {
        guard let isLiked = self.dust?.isLiked else { return }
        isLiked ? likeButton.setImage(UIImage(systemName: "star.fill"), for: .normal) : likeButton.setImage(UIImage(systemName: "star"), for: .normal)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setCornerRadius()
    }
    private func setCornerRadius() {
        self.contentView.layer.cornerRadius = 25
        self.contentView.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let isLiked = dust?.isLiked else { return }
        handleLikeButtonTapped(self, isLiked)
        setLikeButtonUI()
    }
    
    // frame에 inset을 지정하여, 결과적으로 tableCell간의 spacing을 주는 효과
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0))
    }
    
}
