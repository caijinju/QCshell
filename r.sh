#!/bin/bash

#########################################################################
# File Name   : r.sh
# Author      : CaiJinJu
# Mail        : 517402802@qq.com 
# Created Time: Sat Dec 16 21:10:52 2017
#------------------------------------------------------------------------
# Modified    :
#               2017-12-17 初版 V01 完成
#			   - 生成最终集成一起的单个文件，删除其他临时文件。
#
#               2017-12-18 修复生成文件“处理结果.txt”的排版
#			   - 1. 原排版大多为换行符，导致Windows下查看为一整行。
#			   - 2. 修改 echo ，改为识别转移字符，并在最后添加'\r'
#			   - 3. 修改 cat ，改为 printf ，并在最后添加'\r\n'
#			   - 4. 修改 sed ，添加正则匹配，将行尾符替换为'\r'
#			   - cat 的内容能够并不会改变，但经过sed后仍会变化，所以sed必须处理！
#########################################################################
function initcode () {
	sed -e "s/PowerOn/$1/g" -e "s/POWERON/$2/g" -e "s/$/\r/g" $3 >> $$.code
}

#########################################################################

binpath=$(which $0)
dealfiledir="${binpath%/*}/qcdealfiles"

rstart=10
str="PowerOn"
strUpper=$(echo $str|tr '[a-z]' '[A-Z]')

printf ";---------------------------------------------------------------------------\r\n" >> $$.reg
printf ";\t\t变 量 定 义\r\n" >> $$.reg
printf ";---------------------------------------------------------------------------\r\n" >> $$.reg

printf ";---------------------------------------------------------------------------\r\n" >> $$.sum
printf ";\t\t定 义\r\n" >> $$.sum
printf ";---------------------------------------------------------------------------\r\n" >> $$.sum

printf ";---------------------------------------------------------------------------\r\n" >> $$.offset
printf ";\t\t定 义\r\n" >> $$.offset
printf ";---------------------------------------------------------------------------\r\n" >> $$.offset

printf ";---------------------------------------------------------------------------\r\n" >> $$.tab
printf ";\t\t列 表\r\n" >> $$.tab
printf ";---------------------------------------------------------------------------\r\n" >> $$.tab
printf "Tab_PlayList:\r\n" >> $$.tab
printf "{\r\n" >> $$.tab

cat /dev/null > $$.code
cat /dev/null > 处理结果.txt
flag=1
while ((flag))
do
	read -p "请输入新的变量名（输入Q/q退出）：" temp
	if [ "${temp}"x == ""x ]
	then
		echo "输入为空！请重新输入！"
		continue
	fi

	case ${temp} in 
		q|Q)
			flag=0
			cat "${dealfiledir}/qcsysdef.txt" >> 处理结果.txt
			cat "${dealfiledir}/qcsysreg.txt" >> 处理结果.txt
			cat $$.reg >> 处理结果.txt
			echo -e "\r" >> 处理结果.txt
			cat $$.sum >> 处理结果.txt
			echo -e "\r" >> 处理结果.txt
			cat $$.offset >> 处理结果.txt
			echo -e "\r" >> 处理结果.txt
			cat $$.tab >> 处理结果.txt
			echo -e "[0x3ff, 0x3ff]\r"  >> 处理结果.txt
			echo -e "}\r"  >> 处理结果.txt
			echo -e "\r" >> 处理结果.txt
			cat $$.code >> 处理结果.txt
			cat "${dealfiledir}/qcplaycode.txt" >> 处理结果.txt
			rm $$.reg $$.sum $$.offset $$.code $$.tab
			echo "退出！"
			;;
		*)
			newstr="$(echo ${temp::1}|tr '[a-z]' '[A-Z]')${temp:1}"
			newstrupper=$(echo $newstr|tr '[a-z]' '[A-Z]')

			printf "; %s\r\n" ${newstr} >> $$.tab
			printf "[0x3ff, 0x3ff],\r\n"  >> $$.tab
			echo -e "R_${newstr}Index\t\t=\t\tR${rstart}\r" >> $$.reg
			((rstart++))
			echo -e "D_SUM_${newstrupper}\t\t=\t\t0\r" >> $$.sum
			echo -e "D_OFFSET_${newstrupper}\t\t=\t\t0\r" >> $$.offset
			initcode ${newstr} ${newstrupper} "${dealfiledir}/qcsedcode.txt"
			echo "处理完毕！"
			;;
	esac
done


