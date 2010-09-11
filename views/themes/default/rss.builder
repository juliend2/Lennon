xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title options.conf.blog_title
    xml.description options.conf.blog_tagline
    xml.link options.conf.blog_url

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "#{options.conf.blog_url}/#{post.published_at.year}/#{post.published_at.month}/#{post.published_at.day}/#{post.slug}"
        xml.description { xml.cdata!(truncate_words(strip_tags(post.content), 200)) }
        xml.pubDate post.created_at.rfc822
        xml.guid "#{options.conf.blog_url}/#{post.published_at.year}/#{post.published_at.month}/#{post.published_at.day}/#{post.slug}"
      end
    end
  end
end

