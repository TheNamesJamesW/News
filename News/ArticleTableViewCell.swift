//
//  ArticleTableViewCell.swift
//  News
//
//  Created by James Wilkinson on 21/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

protocol ArticleTableViewCellDelegate: class {
    func articleCell(_ cell: ArticleTableViewCell, didCommit action: ArticleTableViewCell.Action)
}

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet var headline: UILabel!
    @IBOutlet var source: UILabel!
    
    private var swipeRecogniser: UIPanGestureRecognizer!
    
    private var _original: CGPoint!
    
    enum Action {
        case readLater
        case discard
    }
    
    weak var delegate: ArticleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.swipeRecogniser = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        swipeRecogniser.delegate = self
        self.addGestureRecognizer(swipeRecogniser)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self._original = self.contentView.center
        case .changed:
            self.contentView.center.x = _original.x + gestureRecognizer.translation(in: self).x
        case .ended:
            let translation = gestureRecognizer.translation(in: self).x
            let velocity = gestureRecognizer.velocity(in: self).x
            
            let translationThreshold: CGFloat = self.bounds.width * 5/9
            let velocityThreshold: CGFloat = 2000
            
            let action: Action?
            if translation < -translationThreshold || velocity < -velocityThreshold {
                action = .discard
            } else if translation > translationThreshold || velocity > velocityThreshold {
                action = .readLater
            } else {
                action = nil
            }
            
            let newCenter: CGPoint
            if let action = action {
                let triggeredByVelocity = abs(velocity) > velocityThreshold
                if triggeredByVelocity {
                    var p = self.contentView.center
                    p.x += velocity * 0.1 // (speed * time == distance)
                    newCenter = p
                } else {
                    switch action {
                    case .discard:
                        var p = self.contentView.center
                        p.x -= self.bounds.width/2 // (0.1 == time)
                        newCenter = p
                        
                    case .readLater:
                        var p = self.contentView.center
                        p.x += self.bounds.width/2 // (0.1 == time)
                        newCenter = p
                    }
                }
            } else {
                newCenter = _original
            }
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.contentView.center = newCenter
            }, completion: { _ in
                self.isUserInteractionEnabled = action == nil
                if let action = action {
                    self.delegate?.articleCell(self, didCommit: action)
                }
            })
            
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.swipeRecogniser {
            let translation = swipeRecogniser.translation(in: self)
            return abs(translation.x) > abs(translation.y)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
