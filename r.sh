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
#
#               2017-12-18 版本 V1.02 -- 修改部分功能
#			   - 1. 添加区块标签 [Symbol] [Table]，将原标签替换后只需操作剪切复制代码块。
#			   - 2. 修复上一版本注释定义误删除内容。
#			   - 3. 语音列表改为 Tab_VoiceList，此修改是为了根据需要添加 Tab_MidiList；
#				相应的，qcdealfiles/qcplaycode.txt 也需要修改表名。
#
#               2017-12-19 版本 V1.03 -- 修改部分功能
#			   - 1. 创建文件夹“脚本处理结果”保留脚本处理文件。
#			   - 2. 将删除的临时文件保留，并重新命名为 txt 文件。
#			   - 3. 将生成的模版文件保存在“脚本处理结果”中，并重命名为 demo_code.txt
#########################################################################

binpath=$(which $0)
dealfiledir="${binpath%/*}/qcdealfiles"

rstart=10
str="PowerOn"
strUpper=$(echo $str|tr '[a-z]' '[A-Z]')

dealresultdir="0_脚本处理结果/变量生成模板/"
mkdir -p ${dealresultdir}
filereg="${dealresultdir}reg.txt"
filesum="${dealresultdir}sum.txt"
fileoffset="${dealresultdir}offset.txt"
filetab="${dealresultdir}table.txt"
filecode="${dealresultdir}code.txt"
fileresult="${dealresultdir}demo_code.txt"

#########################################################################
function initcode () {
	sed -e "s/PowerOn/$1/g" -e "s/POWERON/$2/g" -e "s/$/\r/g" $3 >> ${filecode}
}

#########################################################################
cat /dev/null > ${filereg}
cat /dev/null > ${filesum}
cat /dev/null > ${fileoffset}
cat /dev/null > ${filetab}
cat /dev/null > ${filecode}
cat /dev/null > ${fileresult}

printf ";---------------------------------------------------------------------------\r\n" >> ${filereg}
printf ";\t\t变 量 定 义\r\n" >> ${filereg}
printf ";---------------------------------------------------------------------------\r\n" >> ${filereg}

printf ";---------------------------------------------------------------------------\r\n" >> ${filesum}
printf ";\t\t数 量 定 义\r\n" >> ${filesum}
printf ";---------------------------------------------------------------------------\r\n" >> ${filesum}

printf ";---------------------------------------------------------------------------\r\n" >> ${fileoffset}
printf ";\t\t位 置 定 义\r\n" >> ${fileoffset}
printf ";---------------------------------------------------------------------------\r\n" >> ${fileoffset}

printf ";---------------------------------------------------------------------------\r\n" >> ${filetab}
printf ";\t\t语 音 列 表\r\n" >> ${filetab}
printf ";---------------------------------------------------------------------------\r\n" >> ${filetab}
printf "Tab_VoiceList:\r\n" >> ${filetab}
printf "{\r\n" >> ${filetab}

clear

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
			echo -e "[0x3ff, 0x3ff]\r"  >> ${filetab}
			echo -e "}\r"  >> ${filetab}

			echo -e "[Symbol]\r" >> ${fileresult}
			cat "${dealfiledir}/qcsysdef.txt" >> ${fileresult}
			cat "${dealfiledir}/qcsysreg.txt" >> ${fileresult}
			cat ${filereg} >> ${fileresult}
			echo -e "\r" >> ${fileresult}
			cat ${filesum} >> ${fileresult}
			echo -e "\r" >> ${fileresult}
			cat ${fileoffset} >> ${fileresult}
			echo -e "\r" >> ${fileresult}
			echo -e "[Table]\r" >> ${fileresult}
			cat ${filetab} >> ${fileresult}
			echo -e "\r" >> ${fileresult}
			cat ${filecode} >> ${fileresult}
			cat "${dealfiledir}/qcplaycode.txt" >> ${fileresult}
#			rm ${filereg} ${filesum} ${fileoffset} ${filecode} ${filetab}
			clear
			echo "退出！"
			;;
		*)
			newstr="$(echo ${temp::1}|tr '[a-z]' '[A-Z]')${temp:1}"
			newstrupper=$(echo $newstr|tr '[a-z]' '[A-Z]')

			printf "; %s\r\n" ${newstr} >> ${filetab}
			printf "[0x3ff, 0x3ff],\r\n"  >> ${filetab}
			echo -e "R_${newstr}Index\t\t=\t\tR${rstart}\r" >> ${filereg}
			((rstart++))
			echo -e "D_SUM_${newstrupper}\t\t=\t\t0\r" >> ${filesum}
			echo -e "D_OFFSET_${newstrupper}\t\t=\t\t0\r" >> ${fileoffset}
			initcode ${newstr} ${newstrupper} "${dealfiledir}/qcsedcode.txt"
			echo "处理完毕！"
			;;
	esac
done


