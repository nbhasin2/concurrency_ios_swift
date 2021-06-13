//
//  ViewController.swift
//  Actors
//
//  Created by Nishant Bhasin on 2021-06-13.
//

import UIKit

let API_KEY = "YOUR NASA API KEY"
struct NasaModel: Codable {
    let copyright, date, explanation, mediaType: String
    let serviceVersion, title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getData()

    }
    
    func setup() {
        self.view.backgroundColor = .white
        self.view.addSubview(imageView)
        indicator.startAnimating()
    }

    // MARK: URL session
    func getData() {
        var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: API_KEY),
            URLQueryItem(name: "date", value: "2021-06-12")
        ]
        let session = URLSession.shared
        let request = URLRequest(url: urlComponents.url!)
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode(NasaModel.self, from: data) as NasaModel {
                    print(decoded.url)
                    let imageUrl = URL(string: decoded.url)
                    self.getImageData(from: imageUrl!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        print("Download Finished")
                        // always update the UI from the main thread
                        DispatchQueue.main.async() { [weak self] in
                            // Hide indicator
                            self?.indicator.isHidden = true
                            // Display image
                            self?.imageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        })
        task.resume()
    }

    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}


