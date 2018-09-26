#
# Be sure to run `pod lib lint FalconVOIP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FalconVOIP'
  s.version          = '1.0.0'
  s.summary          = 'A private pod for the VOIP module.'

  s.description      = <<-DESC
  This private pod contains the UI and managers for the VOIP module functionality. Currently using Sinch for VOIP.
                       DESC

    s.homepage         = 'https://github.com/Basim-Alamuddin/Sinch-Pod-Lint-Demo'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Basim Alamuddin' => 'basim.alamuddin@technivance.com' }
    s.source           = { :git => 'https://github.com/Basim-Alamuddin/Sinch-Pod-Lint-Demo.git', :tag => s.version.to_s }

    s.ios.deployment_target = '9.0'
    s.swift_version = '3.1'
    s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '3.1',
    }
    
    s.source_files = 'FalconVOIP/Classes/**/*.swift', 'FalconVOIP/Classes/**/*.{h,m}'
    
    s.requires_arc = true
    
    s.static_framework = true
    
    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
    
    s.dependency 'SinchRTC', '~> 3.12'
end
