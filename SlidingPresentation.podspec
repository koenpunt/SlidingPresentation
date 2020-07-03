Pod::Spec.new do |spec|
  spec.name         = 'SlidingPresentation'
  spec.version      = '0.0.1'
  spec.summary      = 'Simple presentation controller for "slide in" view controller presentation.'
  spec.description  = <<-DESC
    Simple presentation controller for "slide in" view controller presentation.
    
    The `preferredContentSize` of the presented view controller controls the size of the presented view controller.

    Updates to `preferredContentSize` after the view controller is presented are also reflected in the UI.
  DESC
  
  spec.homepage     = 'https://github.com/koenpunt/SlidingPresentation'
  spec.license      = 'MIT'
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { 'Koen Punt' => 'koen@koenpunt.nl' }
  spec.social_media_url   = 'https://twitter.com/koenpunt'

  spec.swift_versions = ['5.0']
  spec.platform       = :ios, '10.0'
  spec.source         = { git: 'https://github.com/koenpunt/SlidingPresentation.git', tag: "v#{spec.version}" }

  spec.source_files  = 'Source'
end
