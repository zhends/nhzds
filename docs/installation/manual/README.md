# Manual installation of OpenProject 7.0 with Apache on Ubuntu 14.04. LTS

**IMPORTANT: We strongly recommend to use the [OpenProject installers](https://www.openproject.org/download-and-installation) (packaged installation). There is no real advantage installing OpenProject manually.**


This tutorial helps you to deploy OpenProject 7.0. Please, aware that:

This guide requires that you have a clean Ubuntu 14.04 x64 installation
with administrative rights. We have tested the installation guide on an
Ubuntu Server image, but it should work on any derivative.

OpenProject will be installed with a MySQL database (the guide should
work similarly with PostgreSQL).

OpenProject will be served in a production environment with Apache
(this guide should work similarly with other servers, like nginx and others)

Note: We have highlighted commands to execute like this


```bash
[user@host] command to execute
```

The `user` is the operating system user the command is executed with.
In our case it will be `root` for most of the time or `openproject`.

If you find any bugs or you have any recommendations for improving this
tutorial, please, feel free to create a pull request against this guide.

# Prepare your environment

Create a dedicated user for OpenProject:

```bash
sudo groupadd openproject
sudo useradd --create-home --gid openproject openproject
sudo passwd openproject #(enter desired password)
```

## Installation of essentials

```bash
[root@host] apt-get update -y
[root@host] apt-get install -y zlib1g-dev build-essential           \
                    libssl-dev libreadline-dev                      \
                    libyaml-dev libgdbm-dev                         \
                    libncurses5-dev automake                        \
                    imagemagick libmagickcore-dev libmagickwand-dev \
                    libtool bison libffi-dev git curl               \
                    libxml2 libxml2-dev libxslt1-dev # nokogiri
```

## Installation of memcached

```bash
[root@host] apt-get install -y memcached
```

## Installation of MySQL


```bash
[root@host] apt-get install mysql-server libmysqlclient-dev
```

During the installation you will be asked to set the root password.


We use the following command to open a `mysql` console and create
the OpenProject database.

```bash
[root@host] mysql -uroot -p
```

You may replace the string `openproject` with the desired username and
database name. The password `my_password` should definitely be changed.

```sql
mysql> CREATE DATABASE openproject CHARACTER SET utf8;
mysql> CREATE USER 'openproject'@'localhost' IDENTIFIED BY 'my_password';
mysql> GRANT ALL PRIVILEGES ON openproject.* TO 'openproject'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> QUIT
```

## Installation of Ruby

The are several possibilities to install Ruby on your machine. We will
use [rbenv](http://rbenv.org/). Please be aware that the actual installation of a specific Ruby version takes some
time to finsih.

```bash
[root@host] su openproject --login
[openproject@host] git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
[openproject@host] echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
[openproject@host] echo 'eval "$(rbenv init -)"' >> ~/.profile
[openproject@host] source ~/.profile
[openproject@host] git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

[openproject@host] rbenv install 2.3.0
[openproject@host] rbenv rehash
[openproject@host] rbenv global 2.3.0
```

To check our Ruby installation we run `ruby --version`. It should output
something very similar to:

```
ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-linux]
```

## Installation of Node

The are several possibilities to install Node on your machine. We will
use [nodenv](https://github.com/OiNutter/nodenv#installation). Please
run `su openproject --login` if you are the `root` user. If you are
already the `openproject` user you can skip this command. Please be
aware that the actual installation of a specific node version takes some
time to finsih.

```bash
[openproject@host] git clone https://github.com/OiNutter/nodenv.git ~/.nodenv
[openproject@host] echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.profile
[openproject@host] echo 'eval "$(nodenv init -)"' >> ~/.profile
[openproject@host] source ~/.profile
[openproject@host] git clone git://github.com/OiNutter/node-build.git ~/.nodenv/plugins/node-build

[openproject@host] nodenv install 6.9.1
[openproject@host] nodenv rehash
[openproject@host] nodenv global 6.9.1
```

To check our Node installation we run `node --version`. It should output
something very similar to:

```
v6.9.1
```

## Installation of OpenProject

We will install the OpenProject Community Edition. It contains the recommended set of plugins for use
with OpenProject. For more information, see https://github.com/opf/openproject-ce.


```bash
[openproject@host] cd ~
[openproject@host] git clone https://github.com/opf/openproject-ce.git --branch stable/7 --depth 1
[openproject@host] cd openproject-ce
[openproject@host] gem install bundler
[openproject@host] bundle install --deployment --without postgres sqlite development test therubyracer docker
[openproject@host] npm install
```

## Configure OpenProject

Create and configure the database configuration file in config/database.yml
(relative to the openproject-ce directory).

```bash
[openproject@host] cp config/database.yml.example config/database.yml
```

Now we edit the `config/database.yml` file and insert our database credentials.
It should look like this (please keep in mind that you have to use the values
you used above: user, database and password):

```yaml
production:
  adapter: mysql2
  database: openproject
  host: localhost
  username: openproject
  password: my_password
  encoding: utf8

development:
  adapter: mysql2
  database: openproject
  host: localhost
  username: openproject
  password: my_password
  encoding: utf8
```

Next we configure email notifications (this example uses a gmail account) by creating the `configuration.yml` in config directory.

```bash
[openproject@host] cp config/configuration.yml.example config/configuration.yml
```

Now we edit the `configuration.yml` file to suit our needs.

```yaml
production:                          #main level
  email_delivery_method: :smtp       #settings for the production environment
  smtp_address: smtp.gmail.com
  smtp_port: 587
  smtp_domain: smtp.gmail.com
  smtp_user_name: ***@gmail.com
  smtp_password: ****
  smtp_enable_starttls_auto: true
  smtp_authentication: plain
```

Starting with 5.0, OpenProject directly manages your repositories. To
use this feature you have to configure OpenProject as shown
[here](./repository-integration.md).

Add this line into `configuration.yml` file at the end of the file for
a better performance of OpenProject:

```yaml
rails_cache_store: :memcache
```

__NOTE:__ You should validate your `yml` files, for example with
http://www.yamllint.com/. Both, the `database.yml` and `configuration.yml`
file are sensitive to whitespace. It is pretty easy to write
invalid `yml` files without seeing the error. Validating those files
prevents you from such errors.


## Finish the installation of OpenProject

```bash
[openproject@host] cd ~/openproject-ce
[openproject@host] RAILS_ENV="production" ./bin/rake db:create
[openproject@host] RAILS_ENV="production" ./bin/rake db:migrate
[openproject@host] RAILS_ENV="production" ./bin/rake db:seed
[openproject@host] RAILS_ENV="production" ./bin/rake assets:precompile
```

**NOTE:** When not specified differently, the default data loaded via db:seed will have an english localization. You can choose to seed in a different language by specifying the language via the `LOCALE` environment variable on the call to `db:seed`. E.g.
```bash
[openproject@all] RAILS_ENV="production" LOCALE=fr ./bin/rake db:seed
```
will seed the database in the french language.

### Secret token

You need to generate a secret key base for the production environment with `./bin/rake secret` and make that available through the environment variable `SECRET_KEY_BASE`.
In this installation guide, we will use the local `.profile` of the OpenProject user. You may alternatively set the environment variable in `/etc/environment` or pass it to the server upon start manually in `/etc/apache2/envvars`.

```bash
[openproject@host] echo "export SECRET_KEY_BASE=$(./bin/rake secret)" >> ~/.profile
[openproject@host] source ~/.profile
```

## Serve OpenProject with Apache and Passenger

First, we exit the current bash session with the openproject user,
so that we are again in a root shell.

```bash
[openproject@ubuntu] exit
```

Then, we prepare apache and passenger:

```bash
[root@host] apt-get install -y apache2 libcurl4-gnutls-dev      \
                               apache2-dev libapr1-dev \
                               libaprutil1-dev
[root@ubuntu] chmod o+x "/home/openproject"
```

Now, the Passenger gem is installed and integrated into apache.

```bash
[root@ubuntu] su openproject --login
[openproject@ubuntu] cd ~/openproject-ce
[openproject@ubuntu] gem install passenger
[openproject@ubuntu] passenger-install-apache2-module
```

If you are running on a Virtual Private Server, you need to make sure you have atleast 1024mb of RAM before running the `passenger-install-apache2-module`.

Follow the instructions passenger provides.
The passenger installer will ask you the question in "Which languages are you
interested in?". We are interested only in ruby.

The passenger installer tells us to edit the apache config files.
To do this, continue as the root user:

```bash
[openproject@host] exit
```

As told by the installer, create the file /etc/apache2/mods-available/passenger.load and add the following line.
But before copy&pasting the following lines, check if the content (especially the version numbers!) is the same as the passenger-install-apache2-module installer said. When you're in doubt, do what passenger tells you.


```apache
LoadModule passenger_module /home/openproject/.rbenv/versions/2.1.6/lib/ruby/gems/2.1.0/gems/passenger-5.0.14/buildout/apache2/mod_passenger.so
```

Then create the file /etc/apache2/mods-available/passenger.conf with the following contents (again, take care of the version numbers!):

```apache
   <IfModule mod_passenger.c>
     PassengerRoot /home/openproject/.rbenv/versions/2.1.6/lib/ruby/gems/2.1.0/gems/passenger-5.0.14
     PassengerDefaultRuby /home/openproject/.rbenv/versions/2.1.6/bin/ruby
   </IfModule>
```

Then run:

```bash
[root@openproject] a2enmod passenger
```

As the root user, create the file /etc/apache2/sites-available/openproject.conf with the following contents:

```apache
SetEnv EXECJS_RUNTIME Disabled

<VirtualHost *:80>
   ServerName yourdomain.com
   # !!! Be sure to point DocumentRoot to 'public'!
   DocumentRoot /home/openproject/openproject-ce/public
   <Directory /home/openproject/openproject-ce/public>
      # This relaxes Apache security settings.
      AllowOverride all
      # MultiViews must be turned off.
      Options -MultiViews
      # Uncomment this if you're on Apache >= 2.4:
      Require all granted
   </Directory>

   # Request browser to cache assets
   <Location /assets/>
     ExpiresActive On ExpiresDefault "access plus 1 year"
   </Location>

</VirtualHost>
```

Let's enable our new openproject site (and disable the default site, if necessary)

```bash
[root@host] a2dissite 000-default
[root@host] a2ensite openproject
```

Now, we (re-)start Apache:

```bash
[root@host] service apache2 restart
```

Your OpenProject installation should be accessible on port 80 (http). A default admin-account is created for you having the following credentials:

Username: `admin`
Password: `admin`

Please, change the password on the first login. Also, we highly recommend to configure the SSL module in Apache for https communication.

## Activate background jobs

OpenProject sends (some) mails asynchronously by using background jobs. All such jobs are collected in a queue, so that a separate process can work on them. This means that we have to start the background worker. To automate this, we put the background worker into a cronjob.

```bash
[root@all] su - openproject -c "bash -l"
[openproject@all] crontab -e
```

Now, the crontab file opens in the standard editor. Add the following entry to the file:

```cron
*/1 * * * * cd /home/openproject/openproject-ce; /home/openproject/.rvm/gems/ruby-2.1.5/wrappers/rake jobs:workoff
```

This will start the worker job every minute.

## Repository integration

OpenProject can (by default) browse Subversion and Git repositories, but it does not serve them to git/svn clients.

We do however support an integration with the Apache webserver to create and serve repositories on the fly, including integration into the fine-grained project authorization system of OpenProject.

OpenProject ships with support for so-called *managed* repositories, which can be created and maintained directly within OpenProject and are linked to a single project.

The complete guide for the integration of Subversion and Git repositories can be found in the [repository integration guide](repository-integration.md).

## Follow-Ups

Your OpenProject installation is ready to run. However, there are some things to consider:

* Regularly backup your OpenProject installation. See the [backup guide](backup-guide.md) for details.
* Serve OpenProject via https
* Watch for OpenProject updates. We advise to always run the latest stable version of OpenProject (especially for security updates). Information on how to perform an update can been found in the [upgrade guide](upgrade-guide.md). You can find out about new OpenProject releases in our [news](https://community.openproject.org/projects/openproject/news), or on [twitter](https://twitter.com/openproject).


## Plug-In installation (Optional)

This step is optional.

OpenProject can be extended by various plug-ins, which extend OpenProject's capabilities.
For general information and a list of all plug-ins known to us, refer to to the [plug-in page](https://community.openproject.org/projects/openproject/wiki/OpenProject_Plug-Ins).

OpenProject plug-ins are separated in ruby gems. You can install them by listing them in a file called `Gemfile.plugins`. An example `Gemfile.plugins` file looks like this:

```ruby
# Required by backlogs
gem "openproject-meeting", git: "https://github.com/finnlabs/openproject-meeting.git", :tag => "v4.2.2"
```

If you have modified the `Gemfile.plugin` file, always repeat the following steps of the OpenProject installation:

```bash
[openproject@all] cd ~/openproject-ce
[openproject@all] bundle install
[openproject@all] npm install
[openproject@all] RAILS_ENV="production" ./bin/rake db:migrate
[openproject@all] RAILS_ENV="production" ./bin/rake db:seed
[openproject@all] RAILS_ENV="production" ./bin/rake assets:precompile
```

Restart the OpenProject server afterwards:

```bash
[openproject@all] touch ~/openproject-ce/tmp/restart.txt
```

The next web-request to the server will take longer (as the application is restarted). All subsequent request should be as fast as always.

We encourage you to extend OpenProject yourself by writing a plug-in. Please, read the [plugin-contributions](https://community.openproject.org/projects/openproject/wiki/Developing_Plugins) guide for more information.

## Troubleshooting

You can find the error logs for apache here:
<pre>/var/log/apache2/error.log</pre>

The OpenProject logfile can be found here:
<pre>/home/openproject/openproject-ce/log/production.log</pre>

If an error occurs, it should be logged there.

If you need to restart the server (for example after a configuration change), do

```bash
[openproject@all] touch ~/openproject-ce/tmp/restart.txt
```

## Frequently asked questions (FAQ)

* **I followed the installation guide faithfully and OpenProject is running. Now, how do I log in?**

  The `db:seed` command listed above creates a default admin-user. The username is `admin` and the default password is `admin`. You are forced to change the admin password on the first login.
  If you cannot login as the admin user, make sure that you have executed the `db:seed` command.

  ```bash
  [openproject@all] RAILS_ENV="production" ./bin/rake db:seed
  ```

* **When accessing OpenProject, I get an error page. How do I find out what went wrong?**

  Things can go wrong on different levels. You can find the apache error logs here:
  <pre>/var/log/apache2/error.log</pre>
  The OpenProject log can be found here:
  <pre>/home/openproject/openproject-ce/log/production.log</pre>

* **I cannot solve an error, not even with the log files. How do I get help?**

  You can find help in [the OpenProject forums](https://community.openproject.org/projects/openproject/boards). Please tell us, if possible, what you have done (e.g. which guide you have used to install OpenProject), how to reproduce the error, and provide the appropriate error logs.
  It often helps to have a look at the already answered questions, or to search the Internet for the error. Most likely someone else has already solved the same problem.

* **I get errors, since I have installed an OpenProject plug-in**

  With each new OpenProject core version, the plug-ins might need to be updated. Please make sure that the plug-in versions of all you plug-ins works with the OpenProject version you use.
  Many plug-ins follow the OpenProject version with their version number (So, if you have installed OpenProject version 4.1.0, the plug-in should also have the version 4.1.0).

## Questions, comments, and feedback

If you have any further questions, comments, feedback, or an idea to enhance this guide, please tell us at the appropriate community [forum](https://community.openproject.org/projects/openproject/boards/9).
[Follow OpenProject on twitter](https://twitter.com/openproject), and follow the news on [openproject.org](http://openproject.org) to stay up to date.

