#!/bin/bash
source ./git_mirror_constants.txt

PREFIX="path_with_namespace"
TIME=$(date +%Y-%m-%d:%R)
PATHS=$(
curl --header "PRIVATE-TOKEN: $TOKEN" \
$GITLAB_URL \
| grep -o "\"$PREFIX\":[^ ,]\+")

UPDATED_REPOS=0;
ALL_REPOS=0;
# $1=$O $2=$S $3=$P
handleProject() {
  echo "########## $(date +%s%N | cut -b1-13) Starting with" $P
  ALL_REPOS=$(($ALL_REPOS + 1))

  if [ -z $S ]
   then
     git clone --mirror $HOST/$O/$P.git &> /dev/null
   else
     git clone --mirror $HOST/$O/$S/$P.git &> /dev/null
   fi
 pushd $P.git &> /dev/null
 git remote update &> /dev/null
 popd &> /dev/null
 git clone $P.git Projects/$P-working-dir &> /dev/null
 pushd Projects/$P-working-dir &> /dev/null
 commit=$(git log --pretty=format:'%h' -n 1)
 git pull &> /dev/null
 newCommit=$(git log --pretty=format:'%h' -n 1)
 if [[ $commit != $newCommit ]]
   then
     echo "########## $(date +%s%N | cut -b1-13) updating to commit $newCommit"
     UPDATED_REPOS=$(($UPDATED_REPOS + 1))
   fi
   popd &> /dev/null
   echo "########## $(date +%s%N | cut -b1-13) Finished with" $P
   echo ""
   echo "----------------------------------------"
   echo ""
}

mkdir -p Mirrors
mkdir -p Projects
cd Mirrors

echo "----------> Starting Git backup @ $TIME <----------"

read -a projects <<< $PATHS
for path_with_namespace in "${projects[@]}"
  do
    clean=$(sed -e "s/\"$PREFIX\":/""/g" <<< "$path_with_namespace")
    while IFS=/ read -r org proj
    do
      # O=$(sed -e "s/\"$PREFIX\":/""/g" <<< "$path_with_namespace")
      # O=$(sed -e "s/\"/""/g" <<< $org)
      P=$(sed -e "s/\"/""/g" <<< $proj)
  	  if [[ $P == *\/* ]]
         then
         while IFS=/ read -r subOrg project
         do
             S=$(sed -e "s/\"/""/g" <<< $subOrg)
             P=$(sed -e "s/\"/""/g" <<< $project)
             O=$(sed -e "s/\"/""/g" <<< $org)
             handleProject
         done <<< "$proj"
       else
       	S=""
       	P=$(sed -e "s/\"/""/g" <<< $proj)
        O=$(sed -e "s/\"/""/g" <<< $org)
        handleProject
      fi
  done <<< "$clean"
done

echo "Finished updating $ALL_REPOS repos. $UPDATED_REPOS had new commits"
