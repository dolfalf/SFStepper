Pod::Spec.new do |s|
  s.name        = "SFStepper"
  s.version      = "0.1"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = "Objective-C categories"
  s.homepage     = "https://github.com/dolfalf/SFStepper"
  s.author       = { "Jaeeun Lee" => "dolfalf@gmail.com" }
  s.source       = { :git => "https://github.com/dolfalf/SFStepper.git", :tag => "#{s.version}" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.public_header_files = 'SFStepper/*.h'
  s.source_files  = 'SFStepper/**/*.{h,m}'
end
