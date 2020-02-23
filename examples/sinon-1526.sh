#!/bin/bash

# Test for Sinon issue 1526
# REQUIREMENTS: phantomic has been installed
# Example run from sinon dir: 
# git bisect bad master
# git bisect good v2.0.0
# git bisect run ../git-bisect-scripts/sinon-1526.sh
# ...
# ec74e944173e53fd71afa19e073f1262448534b9 is the first bad commit

artefact="browser-bundle-with-test.js"

cat << EOF > 1526-test.js
var stub = sinon.stub();
var shouldNotGetHere = false;

stub.onFirstCall()
    .throws();

try {
    stub();
    shouldNotGetHere = true;
} catch(e) {
    console.log("OK");
}

if(shouldNotGetHere) throw new Error("FAIL");
EOF


build(){
    npm install \
    && ./build.js \
    && cat pkg/sinon.js 1526-test.js > $artefact
}

clean(){
    rm $artefact
    git reset --hard
}


do_test(){
	phantomic $artefact
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

