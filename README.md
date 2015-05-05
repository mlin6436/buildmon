# buildmon

This is a snapshot of a well established dashboard project in the BBC to help dev teams get an idea of build status of Jenkins/Hudson jobs at a glance.

### Setup

[Dashing](http://shopify.github.io/dashing/) is the backbone of the project. Therefore, having ruby is crucial. I suggest every dev to use [rvm](https://rvm.io/rvm/basics) if possbile, the instruciton for installing ruby using rvm can be found [here](https://github.com/mlin6436/cornerstone/blob/master/macos/install-ruby.sh). And the ruby version I use is 1.9.3, but feel free to use later versions.

Once ruby is configured, try the following commands:

```bash
$ git clone git@github.com:mlin6436/buildmon.git
$ cd buildmon
$ bundle install
$ sudo dashing start &
```

By now, the dashboard should compile fine and attempt to start. While there could be complaints about endpoints, certificates and etc, you might find the answer in the following sections.

### Project Structure

### Configuration

### Certificate
