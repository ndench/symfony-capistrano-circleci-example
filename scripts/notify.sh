#!/usr/bin/env bash

HERE='<!here>'
COMMITMSG=$(git log --format=%B -n 1 $CIRCLE_SHA1)
COVERAGE=""

if [ -f "build/coverage.txt" ]; then
  COVERAGE=$(grep Summary --after-context 3 grishue/coverage.txt | grep Lines | tr --squeeze-repeats ' ' | cut -d\  -f3)
  COVERAGE="\nTest Coverage: $COVERAGE"
fi

curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$HERE Deployed branch \`$CIRCLE_BRANCH\` of \`$CIRCLE_PROJECT_REPONAME\` to update it to\n \`\`\`$COMMITMSG\`\`\` :tada: :rocket: $COVERAGE\"}" https://hooks.slack.com/services/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
