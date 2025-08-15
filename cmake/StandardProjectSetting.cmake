# Set a default build type if none was specified
#当用户没有指定构建类型（build type）时，设置一个默认的构建类型，并配置一些相关选项
#如果当前两个变量都不存在或为空时：
#CMAKE_BUILD_TYPE单配置生成器（如Unix Makefiles, Ninja等）
#CMAKE_CONFIGURATION_TYPES使用的构建类型（如Debug, Release等
#当用户未指定构建类型时，自动选择折衷方案 RelWithDebInfo（优化执行速度同时保留调试信息）

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    #RelWithDebInfo 带调试信息的发布版本
    message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")

    #将 CMAKE_BUILD_TYPE 的值设为 RelWithDebInfo
    # STRING：将变量存入 CMake 缓存（用户可通过 GUI 修改）
    #FORCE：强制覆盖可能已存在的旧值
    set(CMAKE_BUILD_TYPE
            RelWithDebInfo
            CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui, ccmake
    #配置 GUI 选项:
    #Debug：调试版本(无优化，带调试符号)
    #Release：发布版本(完全优化，无调试符号)
    #MinSizeRel：最小体积版本(优化大小)
    #RelWithDebInfo：(带调试信息的发布版本 优化+调试符号)
    set_property(
            CACHE CMAKE_BUILD_TYPE
            PROPERTY STRINGS
            "Debug"
            "Release"
            "MinSizeRel"
            "RelWithDebInfo")
endif()


# Generate compile_commands.json to make it easier to work with clang based tools
# 当这个选项开启时，CMake会在构建目录中生成一个名为`compile_commands.json`的文件
# 这个文件包含了项目中所有源文件的编译命令（编译器、编译选项、源文件路径等）
# 这个文件可以被一些工具（如clangd、clang-tidy、ccls等）使用，以提供代码补全、静态分析等功能
# 使 IDE 能提供精确的代码补全、跳转和静态分析 支持运行 clang-tidy 等代码检查工具
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#配置过程间优化（IPO/LTO）选项 描述说明 IPO 即链接时优化（LTO）
#用户可通过 -DENABLE_IPO=ON 启用此功能
#在 CMake GUI 中会显示此选项
# 禁用IPO（默认） cmake -B build

option(ENABLE_IPO "Enable Interprocedural Optimization, aka Link Time Optimization (LTO)" OFF)

#条件启用 IPO
#包含 CMake 内置模块 CheckIPOSupported
#结果保存到变量 result（TRUE/FALSE）
#诊断信息保存到变量 output

if(ENABLE_IPO)
    include(CheckIPOSupported)
    check_ipo_supported(
            RESULT
            result
            OUTPUT
            output)
    if(result)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    else()
        message(SEND_ERROR "IPO is not supported: ${output}")
    endif()
endif()

#IPO/LTO 技术说明
#优化原理	链接时进行全程序分析，跨文件内联/优化
#优点	提升运行时性能(5-20%)，减小二进制体积
#代价	显著增加编译/链接时间，增加内存占用
#支持要求	需编译器(Clang≥4.0/GCC≥4.5/MSVC≥2017)和链接器支持
#常用场景	发布版本优化，性能关键组件