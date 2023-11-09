#!/bin/bash
# Template for using with `git bisect run`. Place it outside (over) the folder the git repo resides in.
# For an example of a fully expanded file, see sinon-1526.sh
# Example run 
# ../my-test-script.sh # Test FAIL
# git bisect bad master 
# git checkout v2.0.0
# ../my-test-script.sh # Test OK
# git bisect good 
# git bisect run ../my-test-script.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#######################
### CUSTOMIZE START ###
# Customize the clean, build and do_test sections, as well as ARTEFACT (if relevant for the cleanup/test)
#######################
ARTEFACT="some-resulting-file.js"
build(){
    # run compile step, Makefile, grunt, gulp, whatever, that results in a file
    echo "we are producing files" > $ARTEFACT
    
    # check for existence of the produced file - totally optional
    (( $? == 0 )) && [[ -e $ARTEFACT ]]
}

clean(){
    [[ -e "$ARTEFACT" ]] && rm $ARTEFACT 
    git reset --hard

    # Maybe also add `git clean -fd`? Remember that this file then needs to be outside the repo ...
    
    # rm -r node_modules
}


# the actual test: this can be whatever you like, as long as it exits with a non-zero exit code on error
#Examples: see the sample `max-size` for a test that simply checks if a file exceeds some size threshold
do_test(){
    #node my-test-that-exits-with-non-zero-when-failing.js
    (( 1 + 1 == 2 ))
}
### CUSTOMIZE END ###



####################################################################################
########## DO NOT MODIFY BELOW #####################################################
# You do not need to customize these functions: just customize the clean, build and do_test sections
####################################################################################
verify-correct-script-location(){
    pushd "$SCRIPT_DIR"
    if git status 2>/dev/null >/dev/null; then
        echo "It seems the script resides in a Git directory ($SCRIPT_DIR)" 
        echo "Move it outside the repo to avoid it interfering with the Git Bisect process."
        exit 1
    fi
    popd
}

main(){
    verify-correct-script-location

    clean

    build

    # Ignore the results of this test if the build step failed
    if (( $? != 0 ));then
        echo "Build step erred! Skipping current commit to avoid false negatives ..."

        # Returning 125 in a script is equivalent to doing a `git bisect skip` on the CLI
        # See `git help bisect` for more info
        exit 125
    fi

    do_test

    STATUS=$?

    if (( $STATUS == 0 )); then
        echo "Test OK"
    else
        echo "Test FAIL"
    fi

    exit $STATUS
}


main
