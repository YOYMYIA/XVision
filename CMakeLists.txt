cmake_minimum_required(VERSION 3.15)

set(XVISION_VERSION 1.0.0)
#定义项目名称,设置项目版本为变量 指定项目语言为
project(
    XVision
    VERSION ${XVISION_VERSION}
    LANGUAGE CXX
)

#定义项目名称为 XVision
set(PROJECT_NAME_CAPITALIZED "XVision")

#在 macOS 上设置最低支持版本为 10.15 (Catalina)
if (APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15" CACHE STRING "Minimum OS X deployment version")
endif()

# Configuration options
#设置默认不原地运行（需要安装）
set(DEFAULT_RUN_IN_PLACE FALSE)
#设置默认原地运行  添加资源文件需要的版本宏定义
if(WIN32)
  set(DEFAULT_RUN_IN_PLACE TRUE)
  # For Windows RC file.
  add_definitions(-DXVISION_VERSION_MAJOR=${CMAKE_PROJECT_VERSION_MAJOR})
  add_definitions(-DXVISION_VERSION_MINOR=${CMAKE_PROJECT_VERSION_MINOR})
  add_definitions(-DXVISION_VERSION_BUGFIX=${CMAKE_PROJECT_VERSION_PATCH})
  add_definitions(-DXVISION_VERSION_BUILD=1)
  add_definitions(-DXVISION_VERSION_STRING="${PROJECT_VERSION}")

#macOS 特殊处理 设置 Qt5 路径（通过 Homebrew） 启用应用包生成 启用 RPATH
elseif(APPLE)
  set(Qt5_DIR "$(brew --prefix qt5)/lib/cmake/Qt5/" CACHE PATH "directory where Qt5Config.cmake exists.")
  set(CMAKE_MACOSX_BUNDLE ON)
  set(CMAKE_MACOSX_RPATH ON)
endif()

#创建可配置选项 RUN_IN_PLACE, 默认值来自平台设置
set(RUN_IN_PLACE  ${DEFAULT_RUN_IN_PLACE} CACHE BOOL "Run directly in source directory structure")

#p=配置功能选项
option(XVISION_DEBUG_CAPTURE "Enable mode to make debugging easier" OFF)
option(USE_MONOCHROME_ICON "Build using monochrome icon as default" OFF)
option(GENERATE_TS "Regenerate translation source files" OFF)
option(USE_EXTERNAL_SINGLEAPPLICATION "Use external QtSingleApplication library" OFF)
option(USE_LAUNCHER_ABSOLUTE_PATH "Use absolute path for the desktop launcher" ON)
option(USE_WAYLAND_CLIPBOARD "USE KF Gui Wayland Clipboard" OFF)
option(DISABLE_UPDATE_CHECKER "Disable check for updates" OFF)

#定义多个配置选项及其默认值
#包括调试模式、图标类型、翻译生成、外部库使用等
#如果禁用更新检查，添加对应的编译定义

if (DISABLE_UPDATE_CHECKER)
  add_compile_definitions(DISABLE_UPDATE_CHECKER)
endif ()

#包含标准配置
include(cmake/StandardProjectSettings.cmake)

# 编译器设置 创建接口库用于设置项目选项  要求 C++17 标准    创建接口库用于警告设置
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_17)
add_library(project_warnings INTERFACE)