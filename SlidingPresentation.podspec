Pod::Spec.new do |spec|
  spec.name         = 'SlidingPresentation'
  spec.version      = '0.0.1'
  spec.summary      = 'Simple presentation controller for "slide in" view controller presentation.'
  spec.description  = <<-DESC
    Simple presentation controller for "slide in" view controller presentation.
  DESC
  
  spec.homepage     = 'https://github.com/koenpunt/SlidingPresentation'
  spec.license      = 'MIT'
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { 'Koen Punt' => 'koen@koenpunt.nl' }
  spec.social_media_url   = 'https://twitter.com/koenpunt'

  spec.platform     = :ios
  spec.source       = { git: 'https://github.com/koenpunt/SlidingPresentation.git', tag: "#{spec.version}" }

  spec.source_files  = 'Source'
end
