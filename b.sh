#!/bin/bash
#########################################################################
# File Name   : b.sh
# Author      : CaiJinJu
# Mail        : 517402802@qq.com 
# Created Time: Mon Dec 18 17:36:27 2017
#########################################################################
# 说明：
#	准备文件 
#		检测有传入参数
#			- 若无，检测是否存在文件 list.txt
#			- 若有，直接处理参数文件。
#		文件内容格式为： 
#		声音名 序号=小段1+延时时间（毫秒ms）+小段2+延时时间（毫秒ms）... 起始地址
#	
#	直接运行
#		b.sh list.txt  或者 ./b.sh 文件名
#	
#	注意事项
#		行首和行尾不能有多余的空格，否则造成读取错误。如：
#			'静夜思 A9=A9_1+0.55+A9_2+0.75+A9_3+0.72+A9_4+0.624+A9_5+0.605+A9_6  38'
#		当组合语音不想有文件名时，可在行首增加空格跳过。如：
#			' D2=d2_1+0.258+D2_2+0.13+D2_3 53'
#########################################################################
# Version Log :
#		2017-12-18 版本 V01 初版完成！
#			   1. 提供2种使用方式：无参数和1个参数。
#				- 无参数： 需准备1个 list.txt 文件
#				- 1个参数：参数为文件名
#
#		2017-12-19 版本 V1.01 增加部分功能
#			   1. 增加2个参数，和3个参数的处理
#			   2. 增加处理保存文件夹及文件
#			   3. 过滤行尾的空格，避免造成NF读取错误。
#			   4. 将 awk 内容写成一个文件 b.awk 处理。
#########################################################################

dealfile="list.txt"

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

savedir="0_脚本处理结果/组合语音表格/"

binpath=$(which $0)
bindir="${binpath%/*}/"

mkdir -p ${savedir}
savefile="${savedir}组合语音列表.txt"

awk -F "[ =+]*" -f ${bindir}b.awk $dealfile > ${savefile}
# awk -F "[ =+]*" '
# {   	
# #	sub(/ *$/,"");
# 	if (NF !=0) 
# 	{
# 		offset=$NF;
# 		printf("[ "); 
# 		for (i=3;i<NF;i++) {
# 			if(i%2==1)
# 			{
# 				printf("%d, ",offset);
# 				offset++;
# 			}
# 			else
# 				printf("0x2%02X, ", $i*1000/8);
# 		}
# 		printf("0x3FF ],\t\t; %s %s\r\n",$1,$2);
# 	}
# 
# }' $dealfile > ${savefile}

if [ "${dealfile}" == "/tmp/$$.tmp" ]
then
	rm ${dealfile}
fi
# cat ${savefile}
echo "处理完毕！请见 “${savefile}” ！"

exit

