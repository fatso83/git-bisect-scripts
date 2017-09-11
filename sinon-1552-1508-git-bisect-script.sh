#!/bin/bash
# Regression finding script for https://github.com/sinonjs/sinon/issues/1552
#
# Example run
# ../sinon-1552-1508-git-bisect-script.sh # Test FAIL
# git bisect bad master
# git checkout v2.0.0
# ../sinon-1552-1508-git-bisect-script.sh # Test OK
# git bisect good
# git bisect run ../sinon-1552-1508-git-bisect-script.sh 


build(){
    npm install \
        && (./build.js || ./build)
}

clean(){
    git reset --hard

    # Maybe also add `git clean -fd`? Remember that this file then needs to be outside the repo ...
    git clean -fd

    rm -r node_modules
}

do_test(){
    cat > ../test.js << EOF

var sinon = require('./sinon/')
var test = {};

try {
    sinon.stub(test, 'foo');
}
catch(err){
    process.exit(0)
}
process.exit(1)

EOF
    node ../test.js
}

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

