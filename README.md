# backMyDeb

backMyDeb is a script that allows you to back up folders, database, make specific requests on you're database, encrypt the archive etc.. and upload the archive with plowshare

### Installation

```sh
apt-get install plowshare
```

### Configuration

```sh
# Archive password
COMPR_PASS="jujTKj6OLmyrttrletlrtTI456y"

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

### License

The script Real IP are distributed under the [The MIT License](https://opensource.org/licenses/MIT).

