class Paginator
  include Sinatra::Lennon::Helpers

  def initialize(max_pages, current)
    @max_pages = max_pages
    @current = current.to_i || 1
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
    links.join(', ')
  end
  
  def prev
    if @current > 1
      link_to "Prev", "/page/#{@current-1}"
    end
  end
  
  def next
    if @max_pages > @current
      link_to "Next", "/page/#{@current+1}"
    end
  end
end