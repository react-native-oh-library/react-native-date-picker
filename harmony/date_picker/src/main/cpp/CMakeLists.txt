cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

set(rnoh_date_picker_generated_dir "${CMAKE_CURRENT_SOURCE_DIR}/generated")
file(GLOB_RECURSE rnoh_date_picker_generated_SRC "${rnoh_date_picker_generated_dir}/**/*.cpp")
file(GLOB rnoh_date_picker_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_date_picker SHARED ${rnoh_date_picker_SRC} ${rnoh_date_picker_generated_SRC})
target_include_directories(rnoh_date_picker PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${rnoh_date_picker_generated_dir})
target_link_libraries(rnoh_date_picker PUBLIC rnoh)