# AWS Lambda Functions

These are the Lambda functions we use to support this project.  They are mostly
used to start up AWS SWF Workflows based on triggers (cron, sns, etc).  It is
structured as an [Apex](http://apex.run/) project.

In order to deploy you'll need to:

+ install Apex ([instructions](http://apex.run/#installation))
+ install the main node packages `npm install`
+ install the redis node packages `(cd redis; npm install)`
+ set up AWS credentials ([instructions](http://apex.run/#aws-credentials))
+ deploy `apex deploy`
