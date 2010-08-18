class Paginator
  include Sinatra::Lennon::Helpers

  def initialize(max_pages, current)
    @max_pages = max_pages
    @current = (current || 1).to_i
  end

  def pages
    links = []
    1.upto @max_pages do |i|
      if i == @current
        links << i
      else
        links << link_to( i, "/page/#{i}")
      end
    end
    links.join(', ') if links.length > 1
  end
  
  def prev(str='Previous')
    if @current > 1
      link_to str, "/page/#{@current-1}"
    end
  end
  
  def next(str='Next')
    if @max_pages > @current
      link_to str, "/page/#{@current+1}"
    end
  end
end