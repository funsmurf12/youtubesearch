//
//  YoutubeSearchTableViewCell.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import UIKit
import Kingfisher

class YoutubeSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myImv: UIImageView!
    static var identifier: String! {
        get {
            return "\(self.typeName(self))"
        }
    }
    
    // MARK: - Functions
    
    private static func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.myImv.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(url: String) {
        guard let videoThumb = URL(string: url) else { return }
        
        let scale = UIScreen.main.scale
        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: self.myImv.frame.width * scale, height: self.myImv.frame.height * scale))
        
        myImv.kf.setImage(with: videoThumb, options: [.processor(resizingProcessor),.fromMemoryCacheOrRefresh])
    }
    
}
