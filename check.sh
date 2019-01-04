#!/bin/bash
# 用来检查有哪些项目的目录格式不是默认格式


APP=`svn ls svn://192.168.1.100:443/xxx | sed 's/\///g'`

for i in $APP; do
	
	DIR=`svn ls svn://192.168.1.100:443/xxx/$i | sed 's/\///g'`
	for d in $DIR; do
	
		if [ $d = "trunk" ]; then
			continue;
		elif [ $d = "branches" ]; then
			continue;
		elif [ $d = "tags" ]; then
			continue;
		else
			echo "$i --->  $d"
		fi
	done

done 
