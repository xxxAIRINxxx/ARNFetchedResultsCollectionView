#
# Be sure to run `pod lib lint ARNFetchedResultsCollectionView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ARNFetchedResultsCollectionView"
  s.version          = "0.1.0"
  s.summary          = "UICollectionView + NSFetchedResultsController"
  s.homepage         = "https://github.com/xxxAIRINxxx/ARNFetchedResultsCollectionView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Airin" => "xl1138@gmail.com" }
  s.source           = { :git => "https://github.com/xxxAIRINxxx/ARNFetchedResultsCollectionView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'ARNFetchedResultsCollectionView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreData'
  s.dependency 'ARNFetchedResultsController'
end
