#!/bin/bash
# Template for using with `git bisect run`
# For an example of a fully expanded file, see sinon-1526.sh
# Example run 
# ../my-test-script.sh # Test FAIL
# git bisect bad master 
# git checkout v2.0.0
# ../my-test-script.sh # Test OK
# git bisect good 
# git bisect run ../my-test-script.sh


artefact="some-resulting-file.js"

##
build(){
    # run compile step, Makefile, grunt, gulp, whatever, that results in a file
    echo "we are producing files" > $artefact
    
    # check for existence of the produced file - totally optional
    (( $? == 0 )) && [[ -e $artefact ]]
}

clean(){
    rm $artefact
    git reset --hard

    # Maybe also add `git clean -fd`? Remember that this file then needs to be outside the repo ...
}


# the actual test: this can be whatever you like, as long as it exits with a non-zero exit code on error
#Examples: see the sample `max-size` for a test that simply checks if a file exceeds some size threshold
do_test(){
    #node my-test-that-exits-with-non-zero-when-failing.js
    (( 1 + 1 == 2 ))
}

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

