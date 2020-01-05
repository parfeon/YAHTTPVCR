Pod::Spec.new do |spec|
    spec.name     = 'YAHTTPVCR'
    spec.version  = '1.4.0'
    spec.summary  = 'Yet Another HTTP VCR.'
    spec.homepage = 'https://github.com/parfeon/YAHTTPVCR'
    spec.documentation_url = 'https://github.com/parfeon/YAHTTPVCR/wiki'

    spec.authors = {
        'Serhii Mamontov' => 'parfeon@me.com'
    }
    spec.social_media_url = 'https://twitter.com/parfeon'
    spec.source = {
        :git => 'https://github.com/parfeon/YAHTTPVCR.git',
        :tag => "v#{spec.version}"
    }

    spec.ios.deployment_target = '9.0'
    spec.osx.deployment_target = '10.11'
    spec.tvos.deployment_target = '9.0'
    spec.requires_arc = true

    spec.source_files = 'YAHTTPVCR/**/*', 'YAHTTPVCR/YAHTTPVCR.h'
    spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    spec.private_header_files = [
        'YAHTTPVCR/Core/YHVVCR+{Recorder,Player}.h',
        'YAHTTPVCR/Matchers/*.h',
        'YAHTTPVCR/Misc/{Categories,Helpers}/*.h',
        'YAHTTPVCR/Misc/Protocols/{YHVNSURLProtocol,YHVSerializableDataProtocol}.h',
        'YAHTTPVCR/Misc/YHVPrivateStructures.h',
        'YAHTTPVCR/Data/YHVScene.h',
        'YAHTTPVCR/**/*Private.h'
    ]

    spec.framework = 'XCTest'
    spec.license = 'MIT'
end
