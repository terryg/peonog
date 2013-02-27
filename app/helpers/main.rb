class Main
  helpers do

    # Your helpers go here. You can also create another file in app/helpers with the same format.
    # All helpers defined here will be available across all the application.
    #
    # @example A helper method for date formatting.
    #
    #   def format_date(date, format = "%d/%m/%Y")
    #     date.strftime(format)
    #   end

    # Generate HAML and escape HTML by default.
    def haml(template, options = {}, locals = {})
      options[:escape_html] = true unless options.include?(:escape_html)
      super(template, options, locals)
    end

    # Render a partial and pass local variables.
    #
    # Example:
    #   != partial :games, :players => @players
    def partial(template, locals = {})
      haml(template, {:layout => false}, locals)
    end

    # Store file on S3, returning filename
    #
    # Example:
    #   store_on_s3(temp_file, filename)
    def store_on_s3(temp_file, filename)
      value = (0...32).map{(65+rand(26)).chr}.join
      ext = File.extname(filename)
      fkey = value  + ext
      fname = 'public/uploads/' + fkey
      File.open(fname, "w") do |f|
        f.write(temp_file.read)
      end
      
      AWS::S3::S3Object.store(fkey, open(fname), ENV['S3_BUCKET_NAME'])
      
      return fkey
    end

  end
end
