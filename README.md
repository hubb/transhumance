# Transhumance

![Transhumance image by Journal du Trek](http://www.journaldutrek.com/upload/tr/transhumance-avec-jean-pierre-berger-806/transhumance-avec-jean-pierre-berger-806.jpg)

[Transhumance](http://en.wikipedia.org/wiki/Transhumance) is a ruby gem to make big fat migration on large datasets 

## Install & usage

Either `gem install transhumance` or add to your `Gemfile`

```
gem 'transhumance'
```

Then in an `ActiveRecord::Migration`

```
require 'transhumance'

class MyMigration < ActiveRecord::Migration
  def up
    t = Transhumance.new(
      context: self, 
      source: 'users', 
      target: 'users_wo_column', 
      chunk_size: 200, 
      logger: Logger.new(File.join('tmp', 'transhumance_users_wo_column'))
      debug: true,
    ).with_schema_changes do |target|
  	  remove_column target, :column
  	  rename_column target, :
    end.run
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
```

Then you can run `rake db:migrate`

## How it works

One of the safest way to migrate data on a DB with lots of contention and lots of data, is to copy your data to a newly created and temporary table on which you applied all the schema changes you want in the end.

Transhumance takes care of creating that temporary table, apply any schema changes you want, copy your data over in chunks. When it's done, it will copy the records which have been updated while you were copying things over the first time.

It will continue mirroring your data to the temporary table until the number of items to mirror is low enough.
Then it will lock both table, mirror any updated data and swap the tables.


### Available table transformations

Basically every table transformations available in `ActiveRecord::Migration` is supported by Transhumance.

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