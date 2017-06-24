#!/usr/bin/env bash
if [[  -d ".git" ]]; then
	if [[ $# == 1 ]]; then
		git add .
		git commit -m "feat : $1"
		echo "---------->>> commit end"
		git push
		echo "---------->>> push end"
	elif [[ $# == 2 ]]; then
		git add .
		git commit -m "$1 : $2"
		echo "---------->>> commit end"
		git push
		echo "---------->>> push end"
	else
		echo "Illegal Argument List"
	fi
else 
	echo "Not a git repository"
fi
exit 0