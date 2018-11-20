Pod::Spec.new do |s|
s.name        = "DXScaleFlowLayout"
s.version     = "1.0.4"
s.summary     = "Custom collectionView layout that display scaled up/down cells"
s.homepage    = "https://github.com/SiriDx/DXScaleFlowLayout"
s.license     = { :type => "MIT" }
s.authors     = { "DeanChen" => "dxchen321@gmail.com" }
s.requires_arc = true

s.platform     = :ios, '8.0'
s.ios.deployment_target = "8.0"
s.source   = { :git => "https://github.com/SiriDx/DXScaleFlowLayout.git", :tag => s.version }
s.source_files = "Source/*.swift"
end
