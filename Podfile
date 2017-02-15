source 'git@github.com:onshape/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

workspace 'anusmriti'
project   'anusmriti'

target 'anusmriti' do
    pod 'SVProgressHUD', '~> 1.0'
    pod 'ReactiveObjC', '2.1.2'
    pod 'GoogleAnalytics', '~> 3.14.0'
    pod 'Crashlytics', '3.6.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts target.name
  end
end

# Disable stats, to avoid slowing down developers working on slow connections.
ENV["COCOAPODS_DISABLE_STATS"] = "true"
