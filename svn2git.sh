#!/bin/bash

echo '开始迁移 ^_^'

#加载迁移配置文件
if [ -r "svn2git.conf" ]; then
	echo '加载 svn2git.conf ...'
	. "svn2git.conf"
else
	echo '当先目录下没有发现 svn2git.conf 文件，迁移失败'
	exit 0
fi

cd $WORK_SPACES
echo "cd $WORK_SPACES"

for((ai = 0; ai < $((${#APPLICATION_LIST[@]}));ai++))
do
	APP=${APPLICATION_LIST[$ai]}
	echo "开始迁移 $APP"

	# 开始迁移

	# 下载 SVN 上的代码，并转变成 git 格式的项目
	echo "git svn clone $SVN_PATH/$APP  --no-metadata --trunk=trunk --branches=branches --tags=tags $APP"
	git svn clone $SVN_PATH/$APP  --no-metadata --trunk=trunk --branches=branches --tags=tags $APP
	
	echo "cd $APP"
	cd $APP


	# 利用 gitlab 的 http api 接口创建 project
	echo "curl -d \"name=$APP&namespace_id=$GITLAB_GROUP_ID&wiki_enabled=true&visibility_level=0\" \"http://git.xxx.com/api/v3/projects?private_token=Csy2yXaBbwMprVRM7yUi\""
	curl -d "name=$APP&namespace_id=$GITLAB_GROUP_ID&wiki_enabled=true&visibility_level=0" "http://git.xxx.com/api/v3/projects?private_token=Csy2yXaBbwMprVRM7yUi"
	
	# 关联gitlab project
	echo "git remote add origin git@sunyi.git.xxx.com:$GITLAB_GROUP_NAME/$APP.git"
	git remote add origin git@sunyi.git.xxx.com:$GITLAB_GROUP_NAME/$APP.git

	# 先上传 master ，目前看起来  gitlab 将第一个上传的branch作为默认
	git checkout master
	git merge origin/trunk
	mvn clean
	if [ ! -f ".gitignore" ]; then

	echo ".idea" >>.gitignore
	echo "*.iml" >>.gitignore
	echo ".classpath" >>.gitignore
	echo ".project" >>.gitignore
	echo ".settings/" >>.gitignore
	echo "target/" >>.gitignore
	fi
		
	git add .
	git commit -m 'master init' 
	git push --set-upstream origin master

	echo "$APP master(trunk) 上传成功"

	# 上传分支
	B_LIST=`git branch -r | sed 's/origin\///g'`
	for i in $B_LIST; do
		if [[ $i =~ "trunk" ]]
		then
			continue
		elif [[ $i =~ "tags" ]]
		then
			continue
		elif [[ $i =~ "@" ]]
		then
			continue
		else
			echo "创建分支 $APP: $i"
			git branch $i origin/$i
		fi
	done

	B_LIST=`git branch |sed 's/\*//g'`
	for i in $B_LIST; do
        if [ $i = "master" ]; then
		echo "忽略 master"
        else
        	git checkout $i

    		mvn clean
		if [ ! -f ".gitignore" ]; then
			echo ".idea" >>.gitignore
			echo "*.iml" >>.gitignore
			echo ".classpath" >>.gitignore
			echo ".project" >>.gitignore
			echo ".settings/" >>.gitignore
			echo "target/" >>.gitignore
		fi
		git add .
		git commit -m "$i branch init"

        	git push origin $i:$i
        fi
	    echo "$APP $i branch 上传成功"
	done

	cd ..

	echo "$APP 迁移完毕..." >> svn2git.log

done

