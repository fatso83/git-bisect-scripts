#!/bin/bash
# Template for using with `git bisect run`. Place it outside (over) the folder the git repo resides in.
# ../my-test-script.sh # Test FAIL
# git bisect bad master 
# git checkout v2.0.0
# ../my-test-script.sh # Test OK
# git bisect good 
# git bisect run ../my-test-script.sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SINON_DIR="$SCRIPT_DIR/sinon"
PROJ_DIR="$SCRIPT_DIR/foodsharing/client"

# A single test run takes about 220 seconds on WSL (3m 40 secods)
main(){
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

build(){
    :
    cd $SINON_DIR
    yalc publish # installs a local version of Sinon at this commit using 'yalc'

    cd $PROJ_DIR
    yalc add sinon  # installs the yalc published sinon package from the local yalc repo 
    yarn install 
    # approx 161 seconds on WSL, after removing node_modules, on first try
}

clean(){
    cd $SINON_DIR
    #git reset --hard
    # rm -r node_modules

    # This step, cleaning up the client project was essential!
    #echo "Removing $PROJ_DIR/node_modules"
    #time rm -r "$PROJ_DIR/node_modules" # approx 30 seconds on WSL
    
    # not needed?
    #local f="$PROJ_DIR/test/_compiled.js" 
    #if [[ -e "$f" ]]; then
        #rm $f 
    #fi
    cd $PROJ_DIR
    git reset --hard
    git clean -fd # removes all yalc files, etc
}


# the actual test: this can be whatever you like, as long as it exits with a non-zero exit code on error
#Examples: see the sample `max-size` for a test that simply checks if a file exceeds some size threshold
do_test(){
   cd "$PROJ_DIR" 
   yarn test # approx 31 seconds on WSL
}

main
