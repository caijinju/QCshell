#!/bin/bash

#########################################################################
# File Name   : r.sh
# Author      : CaiJinJu
# Mail        : 517402802@qq.com 
# Created Time: Sat Dec 16 21:10:52 2017
#########################################################################
function initcode () {
##	exec 6>&1
##	exec 1>$$.code
#
#	echo ";---------------------------------------------------------------------------" >> $$.code
#	echo -e ";\t\t$1" >> $$.code
#	echo ";---------------------------------------------------------------------------" >> $$.code
#	echo "L_$1:" >> $$.code
#	echo -e "\t\t\t\tR_$1Index++," >> $$.code
#	echo -e "\t\t\t\tR_$1Index<D_SUM_$2?L_$1_Play,L_$1_Init" >> $$.code
#	echo "" >> $$.code
#	echo -e "\t\tL_$1_Init:" >> $$.code
#	echo -e "\t\t\t\tR_$1Index=0,L_$1_Play" >> $$.code
#	echo "" >> $$.code
#	echo -e "\t\tL_$1_Play:" >> $$.code
#	echo -e "\t\t\t\tX_PlayIndex=R_$1Index+D_OFFSET_$2,L_PlayList" >> $$.code
#	echo "" >> $$.code
##	exec 1>&6
##	exec 6>&-	# 关闭 fd 6描述符
	sed -e "s/PowerOn/$1/g" -e "s/POWERON/$2/g" $3 >> $$.code
}

#########################################################################

binpath=$(which $0)
dealfiledir="${binpath%/*}/qcdealfiles"

rstart=10
str="PowerOn"
strUpper=$(echo $str|tr '[a-z]' '[A-Z]')

cat > $$.reg << EOF
;---------------------------------------------------------------------------
;		变 量 定 义
;---------------------------------------------------------------------------
EOF

cat > $$.sum << EOF
;---------------------------------------------------------------------------
;		数 量 定 义
;---------------------------------------------------------------------------
EOF


cat > $$.offset << EOF
;---------------------------------------------------------------------------
;		位 置 定 义
;---------------------------------------------------------------------------
EOF

cat > $$.tab << EOF
;---------------------------------------------------------------------------
;		播 放 列 表
;---------------------------------------------------------------------------
Tab_PlayList:
{
EOF

cat /dev/null > $$.code
cat /dev/null > 处理结果.txt
flag=1
while ((flag))
do
	read -p "请输入新的变量名（输入Q/q退出）：" temp
	case ${temp} in 
		q|Q)
			flag=0
			cat "${dealfiledir}/qcsysdef.txt" >> 处理结果.txt
			cat "${dealfiledir}/qcsysreg.txt" >> 处理结果.txt
			cat $$.reg >> 处理结果.txt
			echo "" >> 处理结果.txt
			cat $$.sum >> 处理结果.txt
			echo "" >> 处理结果.txt
			cat $$.offset >> 处理结果.txt
			echo "" >> 处理结果.txt
			cat $$.tab >> 处理结果.txt
			echo '[, 0x3ff]'  >> 处理结果.txt
			echo '}'  >> 处理结果.txt
			echo "" >> 处理结果.txt
			cat $$.code >> 处理结果.txt
			# sed 's/\\n/\\r\\n/g' $$.reg >> 处理结果.txt
			# sed 's/\\n/\\r\\n/g' $$.sum >> 处理结果.txt
			# sed 's/\\n/\\r\\n/g' $$.offset >> 处理结果.txt
			cat "${dealfiledir}/qcplaycode.txt" >> 处理结果.txt
			rm $$.reg $$.sum $$.offset $$.code $$.tab
			echo "退出！"
			;;
		*)
			newstr="$(echo ${temp::1}|tr '[a-z]' '[A-Z]')${temp:1}"
			newstrupper=$(echo $newstr|tr '[a-z]' '[A-Z]')

			echo "; ${newstr}" >> $$.tab
			echo '[, 0x3ff],'  >> $$.tab
			echo -e "R_${newstr}Index\t\t=\t\tR${rstart}" >> $$.reg
			((rstart++))
			echo -e "D_SUM_${newstrupper}\t\t=\t\t0" >> $$.sum
			echo -e "D_OFFSET_${newstrupper}\t\t=\t\t0" >> $$.offset
			initcode ${newstr} ${newstrupper} "${dealfiledir}/qcsedcode.txt"
			echo "处理完毕！"
			;;
	esac
done


