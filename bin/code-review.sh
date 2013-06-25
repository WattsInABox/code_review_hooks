#!/bin/bash

# get the repository name
if [ $(git rev-parse --is-bare-repository) = true ]
then
    repo=$(basename "$PWD") 
else
    repo=$(basename $(git rev-parse --show-toplevel))
fi

# phabricator must be uppercase letters only
phabricator_repo=$(sed 's/[0-9\-]*//g'<<<$repo)
phabricator_repo="`echo $phabricator_repo|tr '[a-z]' '[A-Z]'`"

# get the revision id if there is one
revision_id=`arc which ${BASH_ARGV[0]} | grep -o '   D[0-9]\{1,100\} ' | grep -o '[0-9]\{1,100\}'`

# set the reviewers

cmd="echo '{}' | arc call-conduit user.whoami"
eval response=\`${cmd}\`

cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; puts JSON(%Q[${response}])[%Q[response]][%Q[userName]]'"
eval me=\`${cmd}\`

# get the owners
cmd="echo '{\"repositoryCallsign\": \"${phabricator_repo}\"}' | arc call-conduit owners.query"
eval response=\`${cmd}\`

cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; response = JSON(%Q[${response}])[%Q[response]]; puts response[response.keys.first][%Q[owners]].to_json'"
eval phids=\`${cmd}\`

cmd="echo '{\"phids\": ${phids}}' | arc call-conduit user.query"
eval response=\`${cmd}\`

cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; puts JSON(%Q[${response}])[%Q[response]].reject{|user| user[%Q[userName]] == %Q[${me}]}.collect{|user| user[%Q[userName]]}.join(%Q[,])'"
eval reviewers=\`${cmd}\`

arc diff --reviewers $reviewers --skip-binaries "$@"
status=$?

if [[ $status != 0 ]]
then
  echo "Commit aborted - arc died with status ${status}"
  exit $status
else
    if [ "${revision_id}" != "" ]
    then
      cmd="echo '{\"revision_id\": ${revision_id}, \"action\": \"add_reviewers\", \"added_reviewers\": ${phids}, \"message\": \"revision updated\"}' | arc call-conduit differential.createcomment"
      eval response=\`${cmd}\`
      echo $response
    fi    
fi