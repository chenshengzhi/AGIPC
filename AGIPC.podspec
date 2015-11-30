
Pod::Spec.new do |s|

  s.name         = "AGIPC"

  s.version      = "0.0.2"

  s.summary      = "pick and preview photos, based on MWPhotoBrowser and AGImagePickerController"

  s.homepage     = "https://github.com/chenshengzhi/AGIPC"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "陈圣治" => "csz2136@163.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/chenshengzhi/AGIPC.git", :tag => s.version.to_s }

  s.source_files = "AGIPC/*.{h,m}"

  s.resources    = 'AGIPC/AGIPC.xcassets'

  s.requires_arc = true

end
