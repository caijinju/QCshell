#!/bin/bash
#########################################################################
# File Name   : c.sh
# Author      : CaiJinJu
# Mail        : 517402802@qq.com 
# Created Time: 2017/12/19 11:19:29
#########################################################################
# 说明：
#	b.sh 的进化版
#########################################################################
# Version Log :
#		2017-12-19 版本 V01 初版完成！
#			   1. list 文件无需写起始地址，无需注意行尾是否有空格。
#########################################################################


savedir="0_脚本处理结果/组合语音表格/"
mkdir -p ${savedir}

savefile="${savedir}组合语音列表.txt"
filevoicetemp="${savedir}voicetemp.txt"				# 临时参考内容
filevoicelist="${savedir}voiceList.txt"				# 放入程序中的序列

find "$PWD" -type f -iname "*.wav" -print > ${filevoicetemp}
sed -e 's/\/d/D:/' -e 's/\//\\/g' -e 's/$/\r/g' ${filevoicetemp} | awk '
{
	printf("V%d = %s /5\r\n",NR-1,$1);
}
'  > ${filevoicelist}

dealfile="c.txt"

case $# in 
	0)
		;;
	1)
		dealfile=$1
		;;
	2)
		dealfile="/tmp/$$.tmp"
		echo " $*" > ${dealfile}
		;;
	3)
		dealfile="/tmp/$$.tmp"
		echo "$*" > ${dealfile}
		;;
	*)
		;;
esac

# if [ $# -eq 1 ]
# then
# 	dealfile=$1
# elif [ $# -ne 0 ]
# then
# 	echo "参数错误！"
# 	echo "用法： $0 文件名"
# 	echo "或 当存在文件 list.txt 时，直接使用：$0 "
# 	exit
# fi
 
if [ ! -f ${dealfile} ]
then
	echo "不存在文件 ${dealfile}"
	exit
fi

echo "开始处理序列..."
awk -F "[ =+]*" '
# function getmatchnum(str)
# {
# 	i=0;
# 	while("cat 0_脚本处理结果/组合语音表格/voicetemp.txt"|getline line)
# 	{
# 		if (match(tolower(line),tolower(str))!=0)
# 		{
# 			close("cat 0_脚本处理结果/组合语音表格/voicetemp.txt");
# 			break;
# 		} 
# 		i++;
# 	}
# 	return i;
# }

{   	
	sub(/ *$/,"");				# 去除行尾空格，避免在循环中NF出错。
	if (NF !=0) 
	{
		printf("[ "); 
		for (i=3;i<=NF;i++) {
			if(i%2==1)
			{
#				offset=getmatchnum($i);		# 经测试，使用函数老是报错，只能将函数内容直接放入。
				j=0;
				while("cat 0_脚本处理结果/组合语音表格/voicetemp.txt"|getline line)
				{
					n=split(line,arr,"/");
					if (match(tolower(arr[n]),tolower($i))!=0)
					{
						close("cat 0_脚本处理结果/组合语音表格/voicetemp.txt");
						break;
					} 
					j++;
				}
				printf("%d, ",j);
			}
			else
				printf("0x2%02X, ", $i*1000/8);
		}
		printf("0x3FF ],\t\t; %s %s\r\n",$1,$2);
	}

}' $dealfile > ${savefile}

if [ "${dealfile}" == "/tmp/$$.tmp" ]
then
	rm ${dealfile}
fi
# cat ${savefile}
echo "处理完毕！请见 “${savefile}” ！"

exit

