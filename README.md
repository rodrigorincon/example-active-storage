# How to use the active storage to save images on S3

Active Storage is the Rails feature for handle with files related to some database record. Usually used for images, but this feature works for other types of files too.

By default, Active Storage stores the files in a folder inside the project folder, but you can easily change for store the files in the cloud. Here we'll store on AWS S3.

## Configuring active storage

First of all, add activestorage in Gemfile.

```
gem 'activestorage'
```

After it, run `bundle install`.

Second step: create a new migration for store metadata about the files.

```
rails active_storage:install
```

This command will create a migration to store some data about the files and will permit your models find the correct files for whichc attribute.

Disclaimer: The file is not saved on database, just the relation to know which file belongs to which user and the respective metadata.

After it, run the migration.

```
rails db:migrate
```

Third step: in your model when you'll use the storage, add the following line 

```
has_one_attached :my_file
```

you can change `my_file` for any other name that makes more sense for your project. For example, in this tutorial I'll store the user photo, so I'll use the name `photo` in the user model.

```
has_one_attached :photo
```

Disclaimer: You don't need to add any new column on your model. Your schema will be the same.


## Configuring to use S3

In Gemfile, add the s3 SDK.

```
gem 'aws-sdk-s3', require: false
```

After it, run `bundle install`.

Second step: in the `config/storage.yml` file change the amazon commented lines as the example below.

```
amazon:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  region: <%= ENV["AWS_REGION"] %>
  bucket: MY-BUCKET-NAME
```

Here we're configurating how the project will storage the files in which case. This file shows where the files must be stored when we use local filesystem, amazon, azure and other solutions. Each solution has a key and its configuration attributes.

In the amazon case, the attributes are the AWS service (S3), access key and secret, region and bucket name. More optional attributes can be used. To know more about, read the documentation here [https://guides.rubyonrails.org/active_storage_overview.html](https://guides.rubyonrails.org/active_storage_overview.html).

If you want to keep the environment buckets separated, you can do it something like it.

```
amazon_dev:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  region: <%= ENV["AWS_REGION"] %>
  bucket: MY-BUCKET-NAME-DEV

amazon_prod:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  region: <%= ENV["AWS_REGION"] %>
  bucket: MY-BUCKET-NAME-PROD
```

Third step: create an .env and .env.sample files with your environment variables, that changes between development, staging and production. Here we'll add the sensitive values that can't be hardcoded. To create that files, run `touch .env` and `touch .env.sample`. In both files write something like it

```
AWS_ACCESS_KEY_ID=
AWS_REGION=
AWS_SECRET_ACCESS_KEY=
```

In the .env you'll put the true values and the sample file you can keep it like it. Don't forget to add .env in the .gitignore, this file must not be commited!

Fourth step: in `config/environments/development.rb` and `config/environments/production.rb` (and other environments that you want) change the line `config.active_storage.service = :local` to

```
config.active_storage.service = :amazon_dev
config.active_storage.prefix = "folder-name"
```

Note that we are using the same name we used on storage.yml file. The `config.active_storage.service` line define which of the definitions created on storage file will be used by active storage. So in this example, `config/environments/development.rb` will have `config.active_storage.service = :amazon_dev` and `config/environments/production.rb` will have `config.active_storage.service = :amazon_prod`.

 The `config.active_storage.prefix = "folder-name"` define with folder inside the bucket will store the files. If you want to store on the root you don't need to use this line. Unfortenally the storage.yml doesn't support this behavior, so we need to define it in these files.

 ### Additional step: defining the filename

 The configuration above will work, but the file names will be a random string name and without the extension. We can define a familiar name, as the model ID or some other attribute for the image. In this tutorial I'll use the user email to name the file. 

To do it, create a concern to be used for all models that use Active Storage. Let's name this concern as `attached_image_handler.rb`.

attached_image_handler.rb
```
module AttachedImageHandler
  extend ActiveSupport::Concern

  included do
    before_create :set_filename
  end

  def file
  	object_name = self.attachment_reflections.keys.first
    self.send(object_name)
  end

  def image_url
    file.url.split("?").first
  end

  def set_filename
  	if file.attached?
      extension = file.filename.extension
      prefix_bucket = Rails.application.config.active_storage.prefix
      file.blob.update(key: "#{prefix_bucket}/#{self.email}.#{extension}_#{file.key}.#{extension}")
    end
  end
end
```

The "before_create :set_filename" informs the set_filename method will be called only when the user is created. The "file" method calls the method corresponding to the file name defined in the model. In this tutorial, the file name is "photo", so the file method will call `self.photo`. If you change the name in `has_one_attached` line the method called will change too. The file method ensures that different models with different names for their files can use the methods in this concern.

The `set_filename` method changes the file name as you want. Change the last line to name as you prefer. In this example I'm naming as EMAIL.EXTENSION_RANDOM_STRING.EXTENSION.

The `image_url` is the method to get the URL for the file on S3. It's the same as call `photo.url`, but works for any name you use for the file and remove the querystrings.

The last thing we need to do is add the concern in our models. In this tutorial we just need to add it in `user.rb` model.

```
include AttachedImageHandler
```

### Extra: controller to add and see users

This tutorial has 2 routes to create and see the users created. The project is API only, so the controller receives the email and the image to be stored and returns the email and the image URL. The controller file shows how to test it.

### Running the project

To run the project, run `./setup`. This command will create the docker containers, install libs and create the database with all migrations, with everything ready to use.

For using, run `docker-compose up`. To access the application container for testing, run specs or access rails console run `docker-compose exec example_storage_app bash`.
