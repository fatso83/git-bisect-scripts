# git-bisect-scripts
Scripts usable with [Git bisect](https://git-scm.com/docs/git-bisect) - the best way to find where a regression was introduced in your project.

## What do I do?
Customize the [template](https://github.com/fatso83/git-bisect-scripts/blob/master/full-template.sh) for your project.

See this [expanded working example](https://github.com/fatso83/git-bisect-scripts/blob/master/sinon-1526.sh) 
for a test script used in an actual case, sinonjs/sinon#1526.

## Example usage

```
$ cp full-template.sh ../my-test-script.sh

$ vim ../my-test-script.sh

$ ../my-test-script.sh 
Test FAIL

$ git bisect bad master 

$ git checkout v2.0.0

$ ../my-test-script.sh 
Test OK

$ git bisect good 

$ git bisect run ../my-test-script.sh
```

