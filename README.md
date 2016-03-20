# Rubygems TOP 1000 downloaded gems

Converting those to nix to test the defaultGemConfig.

```sql
'/var/db/postgresql/rubygems-1000.csv' With Csv;
Copy(select name, versions.number from rubygems LEFT JOIN versions ON
rubygems.id=versions.rubygem_id WHERE versions.latest=True ORDER BY downloads
DESC LIMIT 1000) To '/var/db/postgresql/rubygems-1000.csv' With Csv;
```

```sh
sudo mv /var/db/postgresql/rubygems-1000.csv .
```

