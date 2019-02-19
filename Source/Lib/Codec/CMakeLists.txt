# 
# Copyright(c) 2019 Intel Corporation
# SPDX - License - Identifier: BSD - 2 - Clause - Patent
# 
# EncoderLib Directory CMakeLists.txt

option(ENABLE_SHARED "Build shared library" ON)

# Include Encoder Subdirectories
include_directories (${PROJECT_SOURCE_DIR}/Source/API/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/Codec/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/C_DEFAULT/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSE2/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSSE3/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSE4_1/)
include_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_AVX2/)

link_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSE2/)
link_directories (${PROJECT_SOURCE_DIR}/Source/Lib/C_DEFAULT/)
link_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSSE3/)
link_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_SSE4_1/)
link_directories (${PROJECT_SOURCE_DIR}/Source/Lib/ASM_AVX2/)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Bin/${CMAKE_BUILD_TYPE}/)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Bin/${CMAKE_BUILD_TYPE}/)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Bin/${CMAKE_BUILD_TYPE}/)

if(NOT MINGW AND ${CMAKE_SYSTEM_NAME} MATCHES "Windows")
   SET(CMAKE_C_FLAGS "/MP")    
endif()

file(GLOB all_files
    "*.h"
    "*.c")
 
if(UNIX)
    list(APPEND PLATFORM_LIBS pthread m)
endif()

if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR "lib")
endif()

if(ENABLE_SHARED)
    # Encoder Lib Source Files
    add_library(SvtAv1EncShared SHARED
        ${all_files}
        $<TARGET_OBJECTS:C_DEFAULT>
        $<TARGET_OBJECTS:ASM_SSE2>
        $<TARGET_OBJECTS:ASM_SSSE3>
        $<TARGET_OBJECTS:ASM_SSE4_1>
        $<TARGET_OBJECTS:ASM_AVX2>
    )
    set_target_properties(SvtAv1EncShared PROPERTIES OUTPUT_NAME SvtAv1Enc)
    target_link_libraries(SvtAv1EncShared ${PLATFORM_LIBS})
    install(TARGETS SvtAv1EncShared DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endif(ENABLE_SHARED)

add_library(SvtAv1EncStatic STATIC
    ${all_files}
    $<TARGET_OBJECTS:C_DEFAULT>
    $<TARGET_OBJECTS:ASM_SSE2>
    $<TARGET_OBJECTS:ASM_SSSE3>
    $<TARGET_OBJECTS:ASM_SSE4_1>
    $<TARGET_OBJECTS:ASM_AVX2>
)
set_target_properties(SvtAv1EncStatic PROPERTIES OUTPUT_NAME SvtAv1Enc)
target_link_libraries(SvtAv1EncStatic ${PLATFORM_LIBS})
install(TARGETS SvtAv1EncStatic DESTINATION "${CMAKE_INSTALL_LIBDIR}")

if(NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
    set(CMAKE_INSTALL_INCLUDEDIR "include/svt-av1")
endif()
    
configure_file(../pkg-config.pc.in ${CMAKE_BINARY_DIR}/SvtAv1Enc.pc @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/SvtAv1Enc.pc DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
install(DIRECTORY ../../API/ DESTINATION "${CMAKE_INSTALL_PREFIX}/include/svt-av1" FILES_MATCHING PATTERN "*.h")
