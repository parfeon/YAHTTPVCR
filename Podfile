install! 'cocoapods', :lock_pod_sources => false
platform :ios, "9.0"
use_frameworks!

pod 'YAHTTPVCR', :path => './'
abstract_target 'Tests' do
  pod 'OCMock', '~> 3.4'
  target '[Test] iOS Unit'
  target '[Test] iOS Integration'
  target '[Test] iOS Code Coverage (Unit)'
  target '[Test] iOS Code Coverage (Integration)'
  target '[Test] iOS Code Coverage (Full)'
end


# Making all interfaces visible for all targets on explicit import
pre_install do |installer_representation|
    installer_representation.aggregate_targets.each do |aggregate_target|
        aggregate_target.spec_consumers.each do |spec_consumer|
            unless spec_consumer.private_header_files.empty?
                spec_consumer.spec.attributes_hash['private_header_files'].clear
            end 
        end
    end
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'YES'
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = target.name =~ /YAHTTPVCR/ ? 'YES' : 'NO' 
            config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = target.name =~ /YAHTTPVCR/ ? 'YES' : 'NO' 
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES' unless target.name =~ /YAHTTPVCR/
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = target.name =~ /Test/ ? 'YES' : 'NO' 
            if target.name =~ /YAHTTPVCR/ then
                config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = 'NO'
                config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'NO'
                config.build_settings['CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING'] = 'YES_ERROR'
                config.build_settings['CLANG_WARN_NON_LITERAL_NULL_CONVERSION'] = 'YES_ERROR'
                config.build_settings['GCC_WARN_ABOUT_RETURN_TYPE'] = 'YES_ERROR'
                config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'YES'
                config.build_settings['CLANG_WARN_COMMA'] = 'YES'
                config.build_settings['GCC_WARN_UNINITIALIZED_AUTOS'] = 'YES_AGGRESSIVE'
                config.build_settings['CLANG_WARN_RANGE_LOOP_ANALYSIS'] = 'YES'
                config.build_settings['CLANG_WARN_DIRECT_OBJC_ISA_USAGE'] = 'YES_ERROR'
                config.build_settings['CLANG_WARN_OBJC_LITERAL_CONVERSION'] = 'YES'
                config.build_settings['CLANG_WARN_OBJC_ROOT_CLASS'] = 'YES_ERROR'
                config.build_settings['GCC_WARN_SHADOW'] = 'YES'
                config.build_settings['GCC_WARN_ABOUT_MISSING_NEWLINE'] = 'YES'
                config.build_settings['CLANG_WARN_ASSIGN_ENUM'] = 'YES'
                config.build_settings['GCC_WARN_UNUSED_LABEL'] = 'YES'
                config.build_settings['GCC_WARN_UNUSED_PARAMETER'] = 'YES'
                config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'YES'
            end
        end
    end
end
