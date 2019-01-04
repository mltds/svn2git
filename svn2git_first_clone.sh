#!/bin/bash

#加载迁移配置文件
if [ -r "svn2git.conf" ]; then
	echo '加载 svn2git.conf ...'
	. "svn2git.conf"
else
	echo '当先目录下没有发现 svn2git.conf 文件，迁移失败'
	exit 0
fi

cd $WORK_SPACES

for((i = 0; i < $((${#APPLICATION_LIST[@]})); i++))
do
	APP=${APPLICATION_LIST[$i]}
	echo "Clone $APP"

	# 开始迁移
	echo "git svn clone -r$SVN_VERSION:HEAD $SVN_PATH/$APP  --no-metadata --trunk=trunk --branches=branches --tags=tags $APP"
	git svn clone -r$SVN_VERSION:HEAD $SVN_PATH/$APP  --no-metadata --trunk=trunk --branches=branches --tags=tags $APP
	
	cd $APP
	git merge origin/trunk
	cd ..

	echo "Clone $APP over"
done
