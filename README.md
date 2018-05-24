# backMyDeb

backMyDeb is a bash script that allows you to backup your website, specific folders, databases, make specific queries on your database before backup, encrypt the archive, etc.
 
### Installation

```sh
apt-get install plowshare
```

### Configuration

```sh
# Archive password
COMPR_PASS=""

# Database informations
DB_HOST="localhost"
DB_NAME=""
DB_USER=""
DB_PASS=""

# Informations to upload you're backup with plowshare (1fichier, uptobox etc.)
C_MAIL=""
C_PASS=""
```

### Usage

```sh
chmod +x backup.sh
./backup.sh
```

### Cron

All day - 11h PM

```
crontab -e
0 23 * * * bash /root/backup.sh &> /dev/null
```

### License

The script Real IP are distributed under the [The MIT License](https://opensource.org/licenses/MIT).
