# Microsoft SQL Server

The MSSQL could be installed to the machine during its provisioning - the user will be asked a question whether he/she wants to have it.

Alongside with the server the system will get an [official SQLSRV ODBC PHP driver](https://github.com/Microsoft/msphpsql) which allows using the MSSQL within PHP.

**WARNING:** the SQLSRV ODBC driver is available only for PHP7+. For PHP 5.6 the `sybase` package will allow to interact with a MSSQL database via [mssql_*](http://php.net/manual/ru/book.mssql.php) functions which were [removed in PHP7+](http://php.net/manual/en/function.mssql-connect.php#function.mssql-connect-refsynopsisdiv).

## Usage

- Default superuser: `sa`.
- Default password: `secur1tY`.

Refer to the [default configuration](../../../scripts/roles/cikit-mssql/defaults/main.yml) for more.

### Examples

#### CLI

```bash
sqlcmd -S localhost -U sa -P secur1tY
```

Upload a database snapshot.

```bash
sqlcmd -S localhost -U sa -P secur1tY -d DATABASE_NAME -i /path/to/script.sql -x
```

#### PHP 5.6

```php
$connection = mssql_connect('localhost', 'sa', 'secur1tY');
```

#### PHP 7+

```php
$connection = sqlsrv_connect('localhost', [
  'Database' => 'parline', 
  'UID' => 'sa', 
  'PWD' => 'secur1tY',
]));
```
