//
//  CertificateService.swift
//  AppToolkit
//
//  Created by Vasily Kolosovsky on 10/25/17.
//  Copyright © 2017 Jibo Inc. All rights reserved.
//

import Foundation

protocol CertificateServiceProtocol: Service {
    typealias CertificateClosure = ((CertificateInfoBaseProtocol?, Error?) -> ())

    func retrieveCertificate(for robotId: String, authorizer: RequestAuthorizer, completion: CertificateClosure?) -> URLRequest?
    func createCertificate(for robotId: String, authorizer: RequestAuthorizer, completion: CertificateClosure?) -> URLRequest?
}

final class CertificateService: CertificateServiceProtocol {
    
    let executor: RequestExecutor
    
    required init(executor: RequestExecutor) {
        self.executor = executor
    }
}

extension CertificateService {

    @discardableResult
    func retrieveCertificate(for robotId: String, authorizer: RequestAuthorizer, completion: CertificateClosure?) -> URLRequest? {
        guard let request = retrieveCertificateRequest(robotId) else {
            completion?(nil, ApiError.certificateFetchError)
            return nil
        }

        executor.execute(request: request, authorizer: authorizer) { result in
            switch result {
            case .failure(let errorResponse):
                completion?(nil, errorResponse.error)
            case .success(let response):
                if let apiResponse = response.body as? ApiCallResponse,
                    let certificate = apiResponse.data as? CertificateInfo {
                    completion?(certificate, nil)
                } else {
                    completion?(nil, ApiError.certificateFetchError)
                }
            }
        }
        
        return request
    }
    
    @discardableResult
    func createCertificate(for robotId: String, authorizer: RequestAuthorizer, completion: CertificateClosure?) -> URLRequest? {
        guard let request = createCertificateRequest(robotId) else {
            completion?(nil, ApiError.certificateCreateError)
            return nil
        }
        
        executor.execute(request: request, authorizer: authorizer) { result in
            switch result {
            case .failure(let errorResponse):
                completion?(nil, errorResponse.error)
            case .success(let response):
                if let apiResponse = response.body as? ApiCallResponse,
                    let certificate = apiResponse.data as? CertificateCreateInfo {
                    completion?(certificate, nil)
                } else {
                    completion?(nil, ApiError.certificateCreateError)
                }
            }
        }
        
        return request
    }

    ///MARK: Private
    private func retrieveCertificateRequest(_ robotId: String) -> URLRequest? {
        let certificate = CertificatesParamFactory.retrieve(robotId: robotId)

        let certificateRequest = RequestBuilder()
            .addParams(certificate.requestParams.asRequestParams())
            .urlString(certificate.path)
            .httpMethod(.get)
            .build()

        return certificateRequest.request
    }

    private func createCertificateRequest(_ robotId: String) -> URLRequest? {
        let certificate = CertificatesParamFactory.create(robotId: robotId)
        
        let certificateRequest = RequestBuilder()
            .addBody(certificate.requestParams.asRequestParams())
            .urlString(certificate.path)
            .httpMethod(.post)
            .build()

        return certificateRequest.request
    }
}
