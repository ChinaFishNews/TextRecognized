//
//  ViewController.swift
//  TextRecognized
//
//  Created by 新闻 on 2017/11/7.
//  Copyright © 2017年 Lvmama. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var btnImageView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btnPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else {
            fatalError("no image")
        }
        self.btnImageView.setBackgroundImage(image, for: .normal)
//        self.btnImageView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//        if self.btnImageView.layer.sublayers != nil {
//            for layer in self.btnImageView.layer.sublayers! {
//                layer.removeFromSuperlayer()
//            }
//        }
        
        var textLayers:[CAShapeLayer] = []
        if let cgImage = image.cgImage {
            let textRecognizedRequest = VNDetectTextRectanglesRequest.init(completionHandler: { (request:VNRequest, error:Error?) in
                
                if (request.results as? [VNTextObservation]) != nil {
                    textLayers = self.addShapesToText(obversations: request.results as! [VNTextObservation], view: self.btnImageView)
                    for layer in textLayers {
                        self.btnImageView.layer.addSublayer(layer)
                    }
                }
            })
            
            let handler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
            guard let _ = try? handler.perform([textRecognizedRequest]) else {
                fatalError("failed")
            }
        }
    }
    
    func addShapesToText(obversations:[VNTextObservation],view:UIView) -> [CAShapeLayer] {
        let layers: [CAShapeLayer] = obversations.map { observation in
            
            let w = observation.boundingBox.size.width * view.bounds.width
            let h = observation.boundingBox.size.height * view.bounds.height
            let x = observation.boundingBox.origin.x * view.bounds.width
            let y = view.bounds.height - observation.boundingBox.origin.y * view.bounds.height - h
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: x , y: y, width: w, height: h)
            layer.borderColor = UIColor.green.cgColor
            layer.borderWidth = 2
            layer.cornerRadius = 3
            
            return layer
        }
        return layers
    }
}

