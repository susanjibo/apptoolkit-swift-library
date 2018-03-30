platform :ios, '9.0'

def shared_pods
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire', '4.6.0'
    pod 'OAuthSwift', '1.1.2'
    pod 'Starscream', :git => 'https://github.com/jiborobot/starscream-jibo.git', :branch => 'master'
    pod 'ObjectMapper', '3.1.0'
    pod 'PromiseKit', '4.5.2'
    pod 'ReactiveCocoa', '7.1.0'
	pod 'KeychainAccess', '~> 3.1.0'
    pod 'AlamofireObjectMapper', '~> 5.0'
    pod 'ReachabilitySwift', '4.1.0'
    pod 'CommonCryptoModule', '1.0.2'
end

source 'https://github.com/CocoaPods/Specs.git'

target 'AppToolkit' do
    workspace 'AppToolkit'
    project 'AppToolkit'
    shared_pods
end

target 'AppToolkitTests' do
    workspace 'AppToolkit'
    project 'AppToolkit'
    inherit! :search_paths
    shared_pods
#    pod 'JSONSchema', :git => 'https://github.com/kylef/JSONSchema.swift.git', :branch => 'swift-3-4'
    pod 'VVJSONSchemaValidation'
end

target 'AppToolkitSampleApp' do
    workspace 'AppToolkit'
    project 'AppToolkitSampleApp'
    shared_pods
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
