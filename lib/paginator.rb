class Paginator
  include Sinatra::Lennon::Helpers

  def initialize(max_pages, current)
    @max_pages = max_pages
    @current = current
  end

  def pages
    links = []
    current = @current || '1'
    1.upto @max_pages do |i|
      if i.to_s == current
        links << i
      else
        links << link_to( i, "/page/#{i}")
      end
    end
    links.join(', ')
  end

end