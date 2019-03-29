platform :ios, '9.0'

targetsArray = ['ZZAVPlayer', 'ZZAVPlayerTests']
targetsArray.each do |t|
  target t do
    use_frameworks!

    # Pods for ZZAVPlayer
    pod 'RxCocoa', '4.3.1'
    pod 'RxSwift', '4.3.1'
    pod 'AlamofireImage', '3.5.0'
    pod 'HandyJSON', '4.2.0'
    
  end
end

#swift版本声名
#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        if target.name == 'ESPullToRefresh'
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '4.0'
#            end
#        end
#    end
#end
