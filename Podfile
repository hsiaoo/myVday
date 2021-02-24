# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'myVday' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for myVday
  pod 'SwiftLint'
  pod 'Firebase/Firestore'
  source 'https://github.com/CocoaPods/Specs.git'
  pod 'GooglePlaces', '4.0.0'
  pod 'GoogleMaps', '4.0.0'
  pod 'Firebase/Storage'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Auth'
  pod 'lottie-ios'
  pod 'Firebase/Crashlytics'
  pod 'Floaty', '~> 4.2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
