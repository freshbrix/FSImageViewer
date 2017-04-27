platform :ios, '6.0'
inhibit_all_warnings!

def shared_pods
	pod 'AFNetworking', '~> 2.3.0'
	pod 'EGOCache', '~> 2.0'
	pod 'SDWebImage', '~> 3.7'
end

target 'FSImageViewer' do
    shared_pods
end

target 'FSImageViewerDemo' do
    shared_pods
end

target :FSImageViewerTests do
	shared_pods
	pod 'OCMock', '~> 2.2.4'
	pod 'FBSnapshotTestCase', '~> 1.1'
	pod 'Specta', '~> 0.2.1'
	pod 'EXPMatchers+FBSnapshotTest', '~> 1.1.0'
end