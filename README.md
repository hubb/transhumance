![Transhumance image by Journal du Trek](http://www.journaldutrek.com/upload/tr/transhumance-avec-jean-pierre-berger-806/transhumance-avec-jean-pierre-berger-806.jpg)

# Transhumance

> While `ALTER TABLE` is executing, the original table is readable by other sessions. Updates and writes to the table are stalled until the new table is ready, and then are automatically redirected to the new table without any failed updates. - [dev.mysql.com](http://dev.mysql.com/doc/refman/5.1/en/alter-table.html)

If your database holds million of records and you can't afford the downtime caused by the write lock when you need to alter its schema, [*Transhumance*](http://en.wikipedia.org/wiki/Transhumance) is for you.

*Transhumance* provides a minimal DSL on top of `ActiveRecord::Migration`


## Install & usage

Either `gem install transhumance` or add to your `Gemfile`

```
gem 'transhumance'
```

and `bundle install`


Generate a new migration with `rails generate migration MyMigration`

```
require 'transhumance'

class MyMigration < ActiveRecord::Migration
  def up
    Transhumance.new(
      context: self,
      source: 'table',
      target: 'table_tmp',
      chunk_size: 200,
      logger: Logger.new(File.join('tmp', 'transhumance_table'))
      debug: true,
    ).with_schema_changes do |target|
	    remove_column target, :column_a
    end.run
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

Then you can run `rake db:migrate`

## How it works

One way to change the structure of a database having millions of records, while it keep receiving reads and writes, is to copy the data to a temporary table.

If you don't want to cause more contention, you'll need to proceed in chunks. Finding the chunk size which match best your setup will require you to practice your migration on a test database. Who doesn't test anyway?

*Transhumance* takes care of creating that temporary table, applying any schema changes you want, and copying your data in configurable chunks to the new table.

While your data is being copied, your application will still being able to access the table, creating and updating records.

To ensure the atomicity of your data, *Transhumance* will keep mirroring chunks of data until it becomes acceptable to lock the tables, copy one last time and swap them.


### Available table transformations

Basically every table transformations available in *ActiveRecord::Migration* is supported by *Transhumance*.

- `add_column(table_name, column_name, type, options)`: Adds a new column to the table
- `rename_column(table_name, column_name, new_column_name)`: Renames a column but keeps the type and content.
- `change_column(table_name, column_name, type, options)`: Changes the column to a different type using the same parameters as add_column.
- `remove_column(table_name, column_names)`: Removes the column listed in column_names from the table called table_name.


### Available index transformations

- `add_index(table_name, column_names, options)`: Adds a new index with the name of the column. Other options include :name, :unique (e.g. { name: 'users_name_index', unique: true }) and :order (e.g. { order: { name: :desc } }).
- `remove_index(table_name, column: column_name)`: Removes the index specified by column_name.
- `remove_index(table_name, name: index_name)`: Removes the index specified by index_name.


## License

MIT licence. Copyright (c) 2013 HouseTrip Ltd.
