#!/usr/bin/env bash

#!/usr/bin/env bash

if [[ $# == 0 ]]; then
    echo "Usage: $0 -d debug_level"
    exit 1
fi

# 读取脚本的命令行选项参数，并将选项赋值给变量argument。
while getopts d: argument
do
    case $argument in
        d) debug_level=$OPTARG
            ;;
        \?) echo "Usage: $0 -d debug_level"
            exit 1
            ;;
    esac
done

# 如果debug此时的值为空或者不是0-9之间的数字，给debug变量赋缺省值0.
if [[ -z $debug_level || $debug_level != [0-9] ]]; then
    debug_level=0
fi
echo "The current debug_level is $debug_level"

echo -n "Tell me your name: "
read name
name=`echo $name | tr [a-z] [A-Z]`
if [[ $name == "STEPHEN" ]]; then
    # 根据当前脚本的调试级别判断是否输出其后的调试信息，此时当debug_level > 0时输出该调试信息。
    test $debug_level -gt 0 && echo "This is Stephen"
    # do something you want here
elif [[ $name == "ANN" ]]; then
    test $debug_level -gt 0 && echo "This is Ann"
    # do something you want here
else
    test $debug_level -gt 0 && echo "This is others"
    # do something you want here
fi
