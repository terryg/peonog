module Helpers

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

    def paginate(query)
      @page     = (params[:page] || 1).to_i
      @per_page = (params[:per_page] || 4).to_i

      @pages       = query.chunks_of(@per_page)
      @total_count = @pages.count
      @page_count  = @pages.length
      
      @pages[@page - 1]
    end

    def pagination_links(uri)
      [%(<ul class="paginator">),
       intermediate_links.join("\n"),
       '</ul>'].join
    end
    
    def intermediate_links(uri)
      (1..@page_count).map do |page|
        if @page == page
          sb = "["
          eb = "]"
        end
        "<li>#{sb}<a href=\"/#{uri}?page=#{page}\">#{page}</a>#{eb}</li>"
      end
    end


  end
