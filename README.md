How to set up continuos deployment with Capistrano and CircleCI
============

The following instructions are complied from:
* My own experience
* [Capistrano's GitHub](https://github.com/capistrano/capistrano)
* [Capistrano-Symfony's GitHub](https://github.com/capistrano/symfony)
* [A Medium post by tomnewbyau](https://medium.com/@tomnewbyau/continuous-delivery-with-symfony-circleci-capistrano-add0df48347d)
* [A Medium post by jontorrado](https://medium.com/@jontorrado/deploying-a-symfony-application-with-capistrano-a954a1a03819)

1. [install ruby](https://www.ruby-lang.org/en/documentation/installation/)
2. [install bundler](https://bundler.io/)

```bash
$ gem install bundler
```

3. create Gemfile

```ruby
# Gemfile
source 'https://rubygems.org' do
    gem 'capistrano',  '~> 3.9'
    gem 'capistrano-symfony', '~> 1.0.0.rc2'
end
```

4. install capistrano

```bash
$ bundle install
```

5. capify your project
Set `STAGES` to a comma separated list of all your environments.
This will create your deployment config files.

```bash
$ bundle exec cap install STAGES=prod,test,...
```

6. add the capistrano-symfony plugin to you Capfile

```ruby
# Capfile
require 'capistrano/symfony'
```

7. update project deployment settings in `config/deploy.rb`

```ruby
# config/deploy.rb

# Set your application name
set :application, "circlestrano"

# Set your repo url, capistrano will clone it for every deployment
set :repo_url, "git@github.com:ndench/symfony-capistrano-circleci-example.git"

# Set the location to deploy to on the remote server
set :deploy_to, "/srv/www/grishue"

# Add parameters.yml to the linked files to keep it between deployments
append :linked_files, "app/config/parameters.yml"

# I like to use composer installed as a .phar in the project root
# If you like global composer, ignore this
SSHKit.config.command_map[:composer] = "php composer.phar"

# Allow the web user to access the gache and log paths
set :file_permissions_users, ["www-data"]
set :file_permissions_paths, [fetch(:cache_path), fetch(:log_path)]
```

8. update environment specific settings in `config/deploy/*.rb`

```ruby
# config/deploy/prod.rb

# Configure the server to deploy to and user to deploy as
server "circlestrano.tk", user: "deploy"

# If you want a different branch deployed to each environment 
#set :branch prod
```

9. copy parameters.yml to your server
Make sure you copy up the correct parameters file, I'm just using the development one.
This will be symlinked into `app/config/parameters.yml` during the deploy.
Make sure you change the owner to the `deploy user`.

```bash
$ scp app/config/parameters.yml root@circlestrano.tk:/srv/www/circlestrano/shared/app/config/parameters.yml
$ ssh root@circlestrano.tk 'chown deploy:deploy /srv/www/circlestrano/shared/app/config/parameters.yml'
```

10. deploy!

```bash
$ cap prod deploy
```

11. set up circleci
    - log into [circleci](https://circleci.com) with your GitHub account.
    - go to the projects page and create a new project on your repo

12. circlelify your project
Create circle.yml with your circleci configuration.
Now when you push to master it will automatically build and run tests!

```yaml
# circle.yml
machine:
  php:
    version: 7.1.3

test:
  override:
    - vendor/bin/phpunit --coverage-text=coverage.txt
```

13. create a webhook
Create an (incoming-webhook)[https://api.slack.com/incoming-webhooks] in slack, and save the
webhook url.

Put that webhook into a `scripts/notify.sh` script.
This script will be run after the auto deployment, so you get notified of it's success.

```bash
#!/usr/bin/env bash

HERE='<!here>'
COMMITMSG=$(git log --format=%B -n 1 $CIRCLE_SHA1)
COVERAGE=""

if [ -f "build/coverage.txt" ]; then
  COVERAGE=$(grep Summary --after-context 3 grishue/coverage.txt | grep Lines | tr --squeeze-repeats ' ' | cut -d\  -f3)
  COVERAGE="\nTest Coverage: $COVERAGE"
fi

curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$HERE Deployed branch \`$CIRCLE_BRANCH\` of \`$CIRCLE_PROJECT_REPONAME\` to update it to\n \`\`\`$COMMITMSG\`\`\` :tada: :rocket: $COVERAGE\"}" https://hooks.slack.com/services/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
```

14. continuous deployment
Configure CircleCi for auto deployment.

```yaml
# circle.yml
deployment:
  master:
    branch: master
    commands:
      - bundle install
      - bundle exec cap prod deploy REVISION=$CIRCLE_SHA1
      - scripts/notify.sh

```

15. add ssh key to circleci project
    - generate an ssh key: `ssh-keygen`
    - go to projects -> settings -> ssh permissions
    - click 'add ssh key'
    - paste in the contents of the private key you generated
    - on your server, add the contents of the public key to `~/.ssh/authorized_keys` for the deploy user

16. enjoy your continuous deployments!
