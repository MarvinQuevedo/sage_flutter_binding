#
# Sage Flutter binding — the native library is built from Rust by Cargokit.
# Run `pod lib lint sage_flutter_binding.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sage_flutter_binding'
  s.version          = '0.1.0'
  s.summary          = 'Flutter binding for the Sage Chia wallet.'
  s.description      = <<-DESC
In-process Flutter binding that links the Sage Chia wallet core and exposes
its endpoints over a generic JSON API.
                       DESC
  s.homepage         = 'https://github.com/xch-dev/sage'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'IMX' => 'osielquevedo@gmail.com' }

  # Classes/ contains the C forwarder that imports ../src/*; required so the
  # FFI symbols are visible to the Dart VM.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.swift_version = '5.0'

  # Build the Rust static library before compiling the pod.
  s.script_phase = {
    :name => 'Build Sage Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust sage_flutter_binding',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony_out'],
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain an i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # Force-load the whole staticlib so the FFI symbols are not stripped.
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libsage_flutter_binding.a',
  }
end
