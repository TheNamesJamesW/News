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
    
    var state: StateController.State! {
        didSet {
            self.contentView.backgroundColor = state == .latest ? .white : .newsyGreen
            self.source.textColor = state == .latest ? .newsyGreen : .darkText
        }
    }
    
    enum Action {
        case readLater
        case discard
    }
    struct ActionOptions {
        let left: Action?
        let right: Action?
        
        func contains(_ element: Action) -> Bool {
            return left == element || right == element
        }
    }
    
    weak var delegate: ArticleTableViewCellDelegate?
    var swipeOptions: ActionOptions!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.swipeRecogniser = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        swipeRecogniser.delegate = self
        self.addGestureRecognizer(swipeRecogniser)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    private func resetUI() {
        self.isUserInteractionEnabled = true
        self.contentView.alpha = 1
        self.contentView.backgroundColor = state == .latest ? .white : .newsyGreen
        self.source.textColor = state == .latest ? .newsyGreen : .darkText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translationThreshold: CGFloat = self.bounds.width * 5/9
        let velocityThreshold: CGFloat = (self.bounds.width/2) / 0.1 // (distance / time == speed)
        
        switch gestureRecognizer.state {
        case .began:
            self._original = self.contentView.center
        case .changed:
            let translation = gestureRecognizer.translation(in: self).x
            
            let provisionalAction: Action?
            if let option = swipeOptions.left, translation < 0 {
                provisionalAction = option
            } else if let option = swipeOptions.right, translation > 0 {
                provisionalAction = option
            } else {
                provisionalAction = nil
            }
            if let action = provisionalAction {
                self.contentView.center.x = _original.x + translation
                style(for: action, translation: translation)
            } else {
                self.contentView.center.x = _original.x + translation/4
            }
        case .ended:
            let translation = gestureRecognizer.translation(in: self).x
            let velocity = gestureRecognizer.velocity(in: self).x
            
            let action: Action?
            if let option = swipeOptions.left, translation < -translationThreshold || velocity < -velocityThreshold {
                action = option
            } else if let option = swipeOptions.right, translation > translationThreshold || velocity > velocityThreshold {
                action = option
            } else {
                action = nil
            }
            
            let newCenter: CGPoint
            if let action = action {
                let triggeredByVelocity = abs(velocity) > velocityThreshold
                if triggeredByVelocity {
                    var p = self.contentView.center
                    p.x += velocity * 2 * 0.1 // (speed * time == distance)
                    newCenter = p
                } else {
                    switch action {
                    case .discard:
                        var p = self.contentView.center
                        p.x -= self.bounds.width/2
                        newCenter = p
                        
                    case .readLater:
                        var p = self.contentView.center
                        p.x += self.bounds.width/2
                        newCenter = p
                    }
                }
            } else {
                newCenter = _original
            }
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.contentView.center = newCenter
                if let action = action {
                    self.contentView.alpha = action == .discard ? 0 : 1
                    self.contentView.backgroundColor = action == .readLater ? .newsyGreen : .white
                } else {
                    self.resetUI()
                }
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
    
    private func style(for action: Action?, translation: CGFloat) {
        let percent = min(abs(translation*1.5) / self.bounds.width, 1)
        contentView.alpha = action == .discard ? 1-percent : 1
        contentView.backgroundColor = action == .readLater ? UIColor.newsyGreen.withAlphaComponent(percent) : (state == .latest ? .white : .newsyGreen)
        source.textColor = action == .readLater ? UIColor.newsyGreen.fade(to: .white, distance: percent) : (state == .latest ? .newsyGreen : .white)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.swipeRecogniser {
            let translation = swipeRecogniser.translation(in: self)
            return abs(translation.x) > abs(translation.y)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
