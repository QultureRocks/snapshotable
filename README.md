
# CacheableModels

This gem is intended to work as a model history, saving important information about it (and its relations) over time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cacheable_models'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cacheable_models

## How it works

CacheableModels adds a `cache!` method to the model that creates a new record on the database using static information, so if something changes, it doesn't affect the cache.
Record are only created if something that is being saved to the cache has changed. We recommend running a daily or weekly task to generate new cached instances, but nothing stops you from creating one every time something changes.

## Usage

1. Create cache model and migration
 
 You should create a new model called `<model_to_cache>Cache` with at least a jsonb `cache` attribute and it must `belongs_to` the original model.
 If you wish to save information about its associations you should add a jsonb attribute `<association_name>_cache`.
 
Example:
- Migration

```
class CreateEmployeeCache < ActiveRecord::Migration[5.1]
  def change
    create_table :employee_caches do |t|
      t.references :employee, index: true, null: false, foreign_key: true
      t.string :company_name
      t.jsonb :cache, null: false
      t.jsonb :supervisor_cache, null: false
      t.jsonb :subordinates_cache, null: false, array: true, default: []

      t.timestamps null: false
    end
  end
end
```

- Model

```
class EmployeeCache < ApplicationRecord
  belongs_to :employee

  validates :employee, presence: true
  validates :cache, presence: true
  validates :supervisor_cache, presence: true
end
```

2. Configure model to be cached

Firstly the original model must have a `has_many` relation to the cached one.
Then, you can use:

- `cache` to configure which attributes should be saved

```
class EmployeeCache < ApplicationRecord
  cache :name, :id, :age, supervisor: [:name, :age], subordinates: [:name]
end
```

- `custom_cache` to set mappings directly to the cached model (instead of the `cache` attribute inside it), this helps if you'd like to add more relations to the Cache model

```
class EmployeeCache < ApplicationRecord
  custom_cache company_id: :company_id
end
```

3. Use it!

In the example developed here, calling `employee.cache!` should generate something like:

```
{
  employee_id,
  company_id,
  cache: {
    name,
    id,
    age
  },
  supervisor_cache: {
    name,
    age
  },
  subordinates_cache: [{
    name
  },
  {
    name
  }]
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).