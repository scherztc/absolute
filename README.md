#Absolute

[![Build Status](https://travis-ci.org/curationexperts/absolute.png?branch=master)](https://travis-ci.org/curationexperts/absolute)
[![Coverage Status](https://coveralls.io/repos/curationexperts/absolute/badge.png)](https://coveralls.io/r/curationexperts/absolute)

## Prerequisites
* [ImageMagick](http://www.imagemagick.org/)
* [ffmpeg](http://www.ffmpeg.org/)
* [fits](https://code.google.com/p/fits)
* [ghostscript](http://ghostscript.com)


### Installing ImageMagick
**Note:**
If you install ImageMagick using homebrew, and you see an error like this when you run the specs:
"Magick::ImageMagickError: no decode delegate for this image format (something.tif)"

Reinstall with a switch for libtiff:

```bash
brew install imagemagick --with-libtiff
```

### Installing ffmpeg & fits & ghostscript

See the instructions in the [Sufia README]() about [installing fits](https://github.com/projecthydra/sufia#install-fitssh) and [installing ffmpeg](https://github.com/projecthydra/sufia#if-you-want-to-enable-transcoding-of-video-install-ffmpeg-version-10). 
Ghostscript maintains installation instructions [here](http://ghostscript.com/doc/current/Install.htm).

## Installing and Configuring Absolute

### Install dependencies with Bundler

```bash
bundle install
```

### Set up config files
```bash
cp config/database.yml.sample config/database.yml
cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb
cp config/solr.yml.sample config/solr.yml
cp config/redis.yml.sample config/redis.yml
cp config/fedora.yml.sample config/fedora.yml
cp config/devise.yml.sample config/devise.yml
```
!!! Important. Open config/devise.yml and generate a new id
!!! Edit config/initializers/secret_token.rb and config/devise.yml replace the sample keys with your own keys.  You can use rake to generate a new secret key:

```bash
rake secret
```

### Set up database

```bash
rake db:schema:load
rake db:seed
```

### Get a copy of hydra-jetty
```bash
rake jetty:clean
rake jetty:config
rake jetty:start
```

## Development

### Starting the workers

```bash
RAILS_ENV=development QUEUE=* VERBOSE=1 rake resque:work

# run the schedule workers
RAILS_ENV=development bundle exec resque-scheduler
```

## Developer notes

### Explaining what partials are being used

If you set an environment variable like this:

```bash
EXPLAIN_PARTIALS=true rails s
```

you'll get helpful comments in the source like this:

```html
<!-- START PARTIAL app/views/shared/_header.html.erb -->
```

### Importing fedora objects from Case Western's existing fedora

Information about importing object is now on [the wiki](https://github.com/curationexperts/absolute/wiki/Migration-Script)

### Exporting the imported URLs to a Handle.net batch file:

```
rake export:handles

Exported 223 records to handles-2014-08-06T11:48:51.txt
```

Then take this file and import them using the handle.net batch tool.

## Deploying to the Sandbox

During the May/June 2014 SOW:

First, set up an ssh config entry:

```
Host casedeploy
Hostname 54.204.33.124
User deploy
IdentityFile /path/to/my/private/key
```

Next, connect to casedeploy via ssh to test the config. (If this fails, your public keys are missing or outdated on the sandbox server - let the team know.)

Finally, deploy code and update the server with the command 

```
bundle exec cap sandbox deploy
```

## Deploying to the Case vm with Oracle

During the May/June 2014 SOW:

First, set up an ssh config entry:

```
Host casehydradev
  Hostname hydra-dev.case.edu
  User deploy
  IdentityFile /path/to/my/private/key
  ForwardAgent no
```

Next, connect to casehydradev via ssh to test the config. (If this fails, your public keys are missing or outdated on the hydradev server - let the team know.)

Next, check out the oracle branch with the command 

```
git checkout oracle
```

Finally, deploy code and update the server with the command

```
bundle exec cap casehydradev deploy
```

