#!/bin/sh

echo "Would you like to submit this change for review? (y/n)"
read send_to_phabricator

status=0
case $send_to_phabricator in
  "y" )
    # get the repository name
    if [ $(git rev-parse --is-bare-repository) = true ]
    then
        repo=$(basename "$PWD") 
    else
        repo=$(basename $(git rev-parse --show-toplevel))
    fi

    # phabricator must be uppercase letters only
    phabricator_repo=$(sed 's/[0-9]*//g'<<<$repo)
    phabricator_repo="`echo $phabricator_repo|tr '[a-z]' '[A-Z]'`"

    # set the reviewers

    cmd="echo '{}' | arc call-conduit user.whoami"
    eval response=\`${cmd}\`

    cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; puts JSON(%Q[${response}])[%Q[response]][%Q[userName]]'"
    eval me=\`${cmd}\`

    # get the owners
    cmd="echo '{\"repositoryCallsign\": \"${phabricator_repo}\"}' | arc call-conduit owners.query"
    eval response=\`${cmd}\`

    cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; response = JSON(%Q[${response}])[%Q[response]]; puts response[response.keys.first][%Q[owners]].to_json'"
    eval response=\`${cmd}\`

    cmd="echo '{\"phids\": ${response}}' | arc call-conduit user.query"
    eval response=\`${cmd}\`

    cmd="ruby -e 'require \"rubygems\"; require \"json/pure\"; puts JSON(%Q[${response}])[%Q[response]].reject{|user| user[%Q[userName]] == %Q[${me}]}.collect{|user| user[%Q[userName]]}.join(%Q[,])'"
    eval response=\`${cmd}\`

    arc diff --reviewers $response "$@"
    status=$?
    ;;
esac

if [[ $status != 0 ]]
then
  echo "Commit aborted - arc died with status ${status}"
  exit $status
fi

