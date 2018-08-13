[![Build Status](https://travis-ci.com/QultureRocks/snapshotable.svg?branch=master)](https://travis-ci.com/QultureRocks/snapshotable)

# Snapshotable

This gem is intended to work as a model history, saving important information about it (and its relations) over time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snapshotable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install snapshotable

## Setup

### Creating the model and migration
We provide a helpful generator to create migrations and models easily. Simply run:
```
rails generate snapshotable:create <model_to_be_snapshoted>
```

Example:
```
rails generate snapshotable:create user
```

This would create a `create_user_snapshot` migration
```
class CreateContractSnapshots < ActiveRecord::Migration
  def change
    create_table :user_snapshots do |t|
      # model to be snapshoted
      t.references :user, index: true, null: false, foreign_key: true

      # snapshoted_object
      t.jsonb :object, null: false
      t.timestamps null: false
    end
  end
end
```

and a `UserSnapshot` model
```
class UserSnapshot < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :object, presence: true
end
```

### Saving relation information

It's possible to add `--has_one` or `--has_many` options to the generator, which creates the needed attributes

Example:
```
rails generate snapshotable:create user --has_one profile photo --has_many groups friends 
```

This would create a `create_user_snapshot` migration
```
class CreateContractSnapshots < ActiveRecord::Migration
  def change
    create_table :user_snapshots do |t|
      # model to be snapshoted
      t.references :user, index: true, null: false, foreign_key: true

      # snapshoted_attributes
      t.jsonb :object, null: false
      
      t.jsonb :profile_object, null: false
      t.jsonb :photo_object, null: false

      t.jsonb :groups_object, null: false, array: true, default: []
      t.jsonb :friends_object, null: false, array: true, default: []

      t.timestamps null: false
    end
  end
end
```

In this case, the model won't change, but you could modify it manually if you wish.

### Setting the base model

Set which attributes should be saved on the Snapshot using `snapshot` on the model
```
snapshot :id, :name, :age, profile: [:description], photo: [:url], groups: [:name], friends: [:name, :age]
```

### Creating a Snapshot

Run `take_snapshot!` to save a new snapshot from a model instance. This will only save a new snapshot if any of the saved fields have changed.

In the example above a `UserSnapshot` would be created like this:
```
{
  user_id: user.id,
  object: {
    id: user.id,
    name: user.name,
    age: user.age
  },
  profile_object: {
    description: user.profile.description
  },
  photo_object: {
    url: user.photo.url
  },
  groups_object: [{
    name: user.groups.first.name
  },
  {
    name: user.groups.second.name
  }],
  friends_object: [{
    name: user.friends.first.name,
    age: user.friends.first.age
  },
  {
    name: user.friends.second.name,
    age: user.friends.second.age
  }]
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).