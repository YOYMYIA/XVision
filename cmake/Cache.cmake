#这段 CMake 代码用于配置编译器缓存（如 ccache 或 sccache）以加速编译过程
#缓存启用选项  定义选项 ENABLE_CACHE，默认启用  用户可通过 -DENABLE_CACHE=OFF 禁用
option(ENABLE_CACHE "Enable cache if available" ON)
if(NOT ENABLE_CACHE)
    return()
endif()

#创建缓存变量 CACHE_OPTION，默认值为 "ccache"  类型为字符串（STRING） 描述："要使用的编译器缓存"
set(CACHE_OPTION
        "ccache"
        CACHE STRING "Compiler cache to be used")

#定义支持的编译器缓存工具列表 ccache：传统的编译器缓存  sccache：Mozilla 开发的分布式缓存（支持云存储）
set(CACHE_OPTION_VALUES "ccache" "sccache")

#配置 GUI 下拉菜单 为 CACHE_OPTION 变量设置可选值  在 CMake GUI 中显示为下拉菜单选项
set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})
#检查用户选择的缓存工具是否在支持列表中
list(
        FIND
        CACHE_OPTION_VALUES
        ${CACHE_OPTION}
        CACHE_OPTION_INDEX)
#如果不在列表中（返回索引为 -1），显示状态消息： 告知用户正在使用自定义缓存工具  列出明确支持的工具
if(${CACHE_OPTION_INDEX} EQUAL -1)
    message(
            STATUS
            "Using custom compiler cache system: '${CACHE_OPTION}', explicitly supported entries are ${CACHE_OPTION_VALUES}")
endif()

#查找缓存程序
#在系统路径中查找指定的缓存工具可执行文件  结果存储在 CACHE_BINARY 变量中
find_program(CACHE_BINARY ${CACHE_OPTION})

#配置或警告
if(CACHE_BINARY)
    message(STATUS "${CACHE_OPTION} found and enabled")
    #显示状态消息（如 ccache found and enabled） 设置 CMAKE_CXX_COMPILER_LAUNCHER 变量  例如：实际调用变为 ccache g++ -c file.cpp
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY})
else()
    #显示警告消息（如 ccache is enabled but was not found. Not using it） 不修改编译器调用
    message(WARNING "${CACHE_OPTION} is enabled but was not found. Not using it")
endif()

#首次编译：轻微减速（需计算和存储哈希）
#后续编译：显著加速（缓存命中时速度提升10-100倍）
#典型加速场景：
#全量清洁构建后再次构建
#切换分支后重新构建
#CI/CD 系统中共享缓存