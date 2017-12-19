#!/usr/bin/awk
#########################################################################
# File Name   : b.awk
# Author      : CaiJinJu
# Mail        : 517402802@qq.com 
# Created Time: 2017/12/19 16:52:44
#########################################################################

{
	sub(/ *$/,"");
	if (NF !=0) 
	{
		offset=$NF;
		printf("[ "); 
		for (i=3;i<NF;i++) {
			if(i%2==1)
			{
				printf("%d, ",offset);
				offset++;
			}
			else
				printf("0x2%02X, ", $i*1000/8);
		}
		printf("0x3FF ],\t\t; %s %s\r\n",$1,$2);
	}
}
