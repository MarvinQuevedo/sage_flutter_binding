# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(sage_flutter_binding_library VERSION 0.0.1 LANGUAGES C)

add_library(sage_flutter_binding SHARED
  "sage_flutter_binding.c"
)

set_target_properties(sage_flutter_binding PROPERTIES
  PUBLIC_HEADER sage_flutter_binding.h
  OUTPUT_NAME "sage_flutter_binding"
)

target_compile_definitions(sage_flutter_binding PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(sage_flutter_binding PRIVATE "-Wl,-z,max-page-size=16384")
endif()
