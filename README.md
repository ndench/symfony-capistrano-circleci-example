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

```
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
set :default_env, { composer: "composer.phar" }

# Allow the web user to access the gache and log paths
set :file_permissions_users, ["www-data"]
set :file_permissions_paths, [fetch(:cache_path), fetch(:log_path)]
```
