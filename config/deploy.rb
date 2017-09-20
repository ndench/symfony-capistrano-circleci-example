# config valid only for current version of Capistrano
lock "3.9.1"

set :application, "circlestrano"
set :repo_url, "git@github.com:ndench/symfony-capistrano-circleci-example.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/srv/www/circlestrano"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "app/config/parameters.yml"

# Default value for linked_dirs is ["var/logs"]
append :linked_dirs, "var/sessions"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Use the composer.phar in the repo
SSHKit.config.command_map[:composer] = "php composer.phar"

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :sessions_path, fetch(:var_path) + "/sessions"

# Use acl to set permissiosn
set :permission_method, :acl

# Set file permissions
set :file_permissions_users, ["www-data"]
set :file_permissions_paths, ["var", fetch(:cache_path), fetch(:log_path), fetch(:sessions_path)]
