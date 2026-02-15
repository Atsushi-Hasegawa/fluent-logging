#### rubyをインストール
```
cd /usr/local
sudo wget  http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
sudo tar xvfz ruby-2.2.2.tar.gz
sudo ./configure
sudo make 
sudo make install
```
#### jrubyをインストール
```
sudo wget https://s3.amazonaws.com/jruby.org/downloads/1.7.20/jruby-bin-1.7.20.tar.gz
sudo tar xvfz jruby-bin-1.7.20.tar.gz
```

#### .profile,.bashrcをパスを登録
```
### ~/.profile
PATH="$PATH:/usr/local/jruby-1.7.20/bin"

### ~/.bashrc
alias sudo="sudo env PATH=$PATH"
```

#### norikraをインストール
```
sudo gem install norikra
```

#### fluentdをインストール
```
sudo gem install fluentd
```

#### growthforecastをインストール
- centosの場合
```
sudo yum groupinstall "Development Tools"
sudo yum install pkgconfig glib2-devel gettext libxml2-devel pango-devel cairo-devel
``` 
#### cpanmのインストール
```
curl -LOk http://xrl.us/cpanm
sudo chmod +x cpanm
cpanm local::lib
cpanm -n GrowthForecast
```

### perlをインストール
```
sudo yum install -y perl-devel
```

#### growthforecastの起動
```
mkdir -p /var/grouwthforecast/data
growthforecast.pl --data-dir /home/user/growthforecast
```

#### norikraの起動・停止
```
norikra start
norikra stop
```

