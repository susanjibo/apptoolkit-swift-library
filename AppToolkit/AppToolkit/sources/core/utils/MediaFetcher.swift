//
//  MediaFetcher.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 11/20/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

//MARK: - Base

// Base class for image/video fetch, establishes secure connection to the robot and gets media data
class MediaFetcher: NSObject {
    fileprivate enum FetchStatus {
        case stop
        case loading
        case fetch
    }
    
    var didStartLoading: (() -> ())?
    var didFinishLoading: (() -> ())?
    var didFetchImage: ((UIImage) -> ())?
    
    fileprivate var status: FetchStatus = .stop
    fileprivate var url: URL!
    fileprivate var session: Foundation.URLSession!
    fileprivate var receivedData: NSMutableData?
    fileprivate var dataTask: URLSessionTask?
    fileprivate let identity: SecIdentity?
    fileprivate let certificate: SecCertificate?
    
    init(_ url: URL, certificate: CertificateInfo) {
        self.identity = certificate.clientIdentity()
        self.certificate = certificate.clientCertificate()
        
        super.init()
        
        self.url = url
        session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    deinit {
        stop()
    }
    
    func dataTask(with request: URLRequest) -> URLSessionTask {
        return session.dataTask(with: request)
    }
    
    func start() {
        guard status == .stop else { return }
        
        status = .loading
        DispatchQueue.main.async { [unowned self] in self.didStartLoading?() }
        
        receivedData = NSMutableData()
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
    
    func stop() {
        status = .stop
        dataTask?.cancel()
    }
    
    func disposition() -> URLSession.ResponseDisposition {
        return .allow
    }
}

extension MediaFetcher: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> ()) {
        processImage()
        self.receivedData = NSMutableData()
        completionHandler(disposition())
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData?.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> ()) {
        guard let identity = identity, let certificate = certificate else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        let credential = URLCredential(identity: identity, certificates: [certificate], persistence: .forSession)
        
        completionHandler(.useCredential, credential)
    }

    fileprivate func processImage() {
        if let imageData = receivedData, imageData.length > 0,
            let image = UIImage(data: imageData as Data) {
            if status == .loading {
                status = .fetch
                DispatchQueue.main.async { [unowned self] in self.didFinishLoading?() }
            }
            
            DispatchQueue.main.async { [unowned self] in self.didFetchImage?(image) }
        }
    }
}

//MARK: - Video

final class CommandVideoFetcher: MediaFetcher {
}

//MARK: - Photo

final class CommandPhotoFetcher: MediaFetcher {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Failed to download photo: \(error)")
        } else {
            processImage()
        }
        stop()
    }
}

