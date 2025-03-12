# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!
target 'Powerly' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'FirebaseMessaging'
  pod 'JVFloatLabeledTextField'
  pod 'GoogleMaps'
  pod 'KDCircularProgress'
  pod 'GoogleAnalytics'
  pod 'Moya'#, '~> 15.0'
  pod 'SwiftyJSON'#, '~> 5.0.1'
  pod 'IQKeyboardManagerSwift'#, '6.5.6'
  pod 'SDWebImage'#, '~> 5.12.1'
  pod 'AEXML'#, '~> 4.6.1'
  pod 'ReachabilitySwift'
  pod 'RxSwift'#, '6.5.0'
  pod 'RxCocoa'#, '6.5.0'
  pod 'SkeletonView'
  pod 'Moya/RxSwift'
  pod 'lottie-ios'
  pod 'RxGoogleMaps'
  pod 'GoogleSignIn'
  pod 'SwiftLint'
  # Pods for PowerShare
  
end

post_install do |installer|
          installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                  config.build_settings['ENABLE_BITCODE'] = 'NO'
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                end
           if ['PayFortSDK'].include? target.name
           target.build_configurations.each do |config|
           config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
           end
        end
    end
end

