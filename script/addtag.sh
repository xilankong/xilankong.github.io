#!/usr/bin/env bash
if [[  -d ".git" ]]; then
	if [[ $# == 1 ]]; then
		git add .
		git commit -m "addTag : $1"
		echo "---------->>> commit end"
		git push
		echo "---------->>> push end"
		git tag $1
		git push origin $1
		echo "---------->>> addTag:$1 end"
	elif [[ $# == 3 ]]; then
		git add .
		git commit -m "addTag : $1"
		echo "---------->>> commit end"
		git push
		echo "---------->>> push end"
		git tag $1
		git push origin $1
		echo "---------->>> addTag:$1 end"
		pod repo push $2 $3 --verbose --allow-warnings
		if [[ $? == 0 ]]; then
			echo -e "\033[32m---------->>> pod repo push succeed ！！！\033[0m\n"
		else
			echo -e "\033[31m---------->>> pod repo push failed ！！！\033[0m\n"
		fi
	else
		echo "Illegal Argument List"
	fi
else 
	echo "Not a git repository"
fi
exit 0