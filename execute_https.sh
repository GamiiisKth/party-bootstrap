# -al/bin/bash


##############################################################################
#
# The script works by executing a command in each repository accodring to the
# order specified in the buildOrder array specifie dat the top of the script
#
# There are a number of predefined commands setup for the user like,
# execute.sh clone
# execute.sh addAll
# execut.sh pull
#
##############################################################################
# exit if any command returns exit code
set -e

##Add modules in prefered order here
buildOrder=(
	'backend-party'
	'endpoint-party'
	'pu-party'     
 )

commit(){
  if [ -n "$(git status --porcelain)" ]; then
    git commit -m $1
  fi
}

addAll(){
  if [ -n "$(git status --porcelain)" ]; then
    git add -A
  fi
}

delete(){
  for subdir in "${buildOrder[@]}"; do
    pushd . > /dev/null
    echo -en "removing \033[1;30m $subdir \033[0m \n"
    rm -rf $subdir
    popd > /dev/null
  done
}

execute(){
  for subdir in "${buildOrder[@]}"; do
    pushd . > /dev/null
    cd "$subdir"
    echo -en "\033[1;34m $subdir \033[0m \n"
    echo -en "\033[1;34m -------------------------------------------------------------------- \033[0m \n"
    "$@"
    popd > /dev/null
  done
}

cleanM2Repo() {
  rm -rf ~/.m2/repository/$1;
  ls ~/.m2/repository/$1;
}

#start_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')

case "$1" in
  "clone")
    for subdir in "${buildOrder[@]}"; do
      if [ ! -d "$subdir" ];
      then
        echo "Cloning repository git@github.com:SO4IT/$subdir"
        git clone https://${GITUSER}:${GITPASS}@github.com/SO4IT/$subdir.git
      else
        echo "Not cloning repository git@github.com:SO4IT/$subdir since it alredy exists"
      fi
    done
    ;;
  "pull")
    execute git pull
    ;;
  "clean")
    delete
    ;;
  "addAll")
    execute addAll
    ;;
  "m2clean")
    if [ -z "$2" ]
      then
        echo "You MUST provide a path to clean from .m2 repository"
        echo " example com/so4it/*"
      else
        cleanM2Repo $2
    fi
    ;;
  "commit")
    if [ -z "$2" ]
      then
        echo "You MUST provide a commit messager when commiting to the GIT repository"
      else
        execute commit $2;
      fi
    ;;
  "build")
    execute mvn -B clean install -T 1C
    ;;
  "deploy")
    execute mvn -B deploy -T 1C
    ;;
  "push")
    execute git push
    ;;
  "status")
    execute git status
  ;;
  "fetch")
    execute git fetch
  ;;
  "behind")
    execute git fetch && execute git log ..@{u} "${@:2}"
  ;;
  "ahead")
    execute git log @{u}.. "${@:2}"
  ;;
  "diff")
    execute git diff "${@:2}"
  ;;
  "buildOffline")
    execute mvn -o clean install -T1C
  ;;
  "buildNoTest")
    execute mvn clean install -T1C -Dmaven.test.skip=true
  ;;
  "help")
    echo "usage: execute.sh [command]"
    echo "  clone - Clones all the GIT repositories the bootstrap is depending on as specified in the 'buildOrder' array at the top of this script"
    echo "  addAll - Adds all uncommited changes to the local GIT repository in all sub directories"
    echo "  commit 'commit message' - Commit all uncommited changes in all sub directories to GIT with the provided commit message."
    echo "                             If no commit message is provided will fail"
    echo "  pull - Pulls changes from GIT in all sub directories"
    echo "  status - Runs git status in all sub directories"
    echo "  build - Builds all sub directories"
    echo "  diff - Show local changes in all sub directories"
    echo "  behind [ -p ] - Show upstream commits which have not been pulled. Accepts diff flags like -p."
    echo "  build - Builds all sub directories"
    echo "  buildOffline - mvn -o clean install -T1C all sub directories"
    echo "  buildNoTest -  mvn clean install -T1C -Dmaven.test.skip=true all sub directories"
    ;;
  *)
  if [ -z "$1" ]
    then
      echo "You MUST provide a command to execute if you are not using any of the prdefined command as listed by the 'help' command"
    else
      execute $@
    fi
  ;;
esac



#end_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')

#elapsed_ms=$((end_ms - start_ms))


#echo "The total time it took to execute the command was $elapsed_ms milliseconds"
