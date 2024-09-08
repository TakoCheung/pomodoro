```ERROR:  Error installing cocoapods:
The last version of drb (>= 0) to support your Ruby & RubyGems was 2.0.6. Try installing it with `gem install drb -v 2.0.6` and then running the current command again
drb requires Ruby version >= 2.7.0. The current ruby version is 2.6.10.210.
```

What I did to resolve : update ruby and install the gen required with 

```bash
brew install ruby
#follow the prompt to install whatever needed for cocoapods
sudo gem install cocoapods
```

zsh: command not found: flutter
```bash
#add flutter to the path
export PATH=".:$PATH:/Users/takocheung/Repo/flutter/bin"
```
or add the above script to ```bash ~/.zshrc```