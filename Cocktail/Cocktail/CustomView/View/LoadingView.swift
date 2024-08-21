import UIKit
import SnapKit
import Lottie

final class LoadingView: UIView {
    
    let explainLabel = UILabel()
    
    let animationView = LottieAnimationView(name: "LoadingAnimation")
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(explainLabel)
        self.addSubview(animationView)

        animationView.contentMode = .scaleAspectFit
        animationView.play(fromFrame: 0, toFrame: 120, loopMode: .loop , completion: nil)
        
        self.backgroundColor = .gray.withAlphaComponent(0.5)
        
        self.addSubview(explainLabel)
        explainLabel.textColor = .black
        explainLabel.font = .nexonFont(ofSize: 20, weight: .bold)
        explainLabel.textAlignment = .center
        explainLabel.numberOfLines = 0
        
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(150)
        }
        
        explainLabel.snp.makeConstraints {
            $0.top.equalTo(animationView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(self).inset(40)
            $0.centerX.equalToSuperview()
        }
    }
}
