require "esapad/version"

require "time"
require "esa"
require "denv"
require "pry"

Denv.load

class Esapad
  DEFAULT_PER_PAGE = 20

  def initialize
    @client = Esa::Client.new(access_token: ENV["ESA_ACCESS_TOKEN"], current_team: ENV["ESA_TEAM"])
  end

  def update_pages_list(target_page_id)
    flow_updated_md = generate_updated_md("flow")
    stock_updated_md = generate_updated_md("stock")

    recently_liked_md = generate_recently_liked_md

    target_page = @client.post(ENV["ESA_TARGET_PAGE_ID"])
    target_page_md = target_page.body["body_md"]

    target_page_md = replace_pages_list_md(target_page_md, "flow", flow_updated_md)
    target_page_md = replace_pages_list_md(target_page_md, "stock", stock_updated_md)
    target_page_md = replace_liked_posts_md(target_page_md, recently_liked_md)

    if target_page_md != target_page.body["body_md"]
      target_page_md = replace_updated_time(target_page_md)
      @client.update_post(target_page_id, body_md: target_page_md, updated_by: "esa_bot")
      puts "Updated: #{ target_page.body["url"] }"
    end
  end

  def blog_query
    ENV["BLOG_CATEGORY"] || "category:日報/"
  end

  def fetch_updated_pages(kind)
    query = case kind
      when "flow"
        "wip:false #{blog_query} -body:RECENTLY-UPDATED-POSTS"
      when "stock"
        "wip:false -#{blog_query} -body:RECENTLY-UPDATED-POSTS"
    end
    @client.posts(q: query, per_page: per_page).body["posts"]
  end

  def generate_updated_md(kind)
    posts = fetch_updated_pages(kind)
    posts.map {|post|
      <<-MARKDOWN

      <li>
        <a href="#{ post["url"] }">#{ post["full_name"] }</a>
        <div class="recently-updated-posts-metadata" style="font-size: 90%;">
          <span class="post-list__date">#{ Time.parse(post["updated_at"]).strftime("%Y-%m-%d %H:%M") }</span>
          by <img src="#{ post["updated_by"]["icon"] }" width="20px" height="20px" />
          <a href="https://mwed.esa.io/users/#{ post["updated_by"]["screen_name"] }">#{ post["updated_by"]["screen_name"] }</a>
        </div>
      </li>
      MARKDOWN
    }.join
  end

  def generate_recently_liked_md
    posts = (1..3).
      map {|page| @client.posts(q: "wip:false created:>#{Date.today - 60} stars:>3", page: page).body["posts"] }.
      flatten.
      sort_by {|post| -post["stargazers_count"] }.
      slice(0, 20).
      sort_by {|post| -Time.parse(post["updated_at"]).to_i }.
      map {|post|
        <<-MARKDOWN

        <li>
          <a href="#{ post["url"] }">#{ post["full_name"] }</a>
          <span class="recently-liked-posts-metadata" style="font-size: 90%;"> :star: #{ post["stargazers_count"] } </span>
        </li>
        MARKDOWN
      }.join
  end

  private

  def replace_pages_list_md(original_md, kind, updated_md)
    original_md.gsub(
      /<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-START -->(.+)<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-END -->/m,
      "<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-START -->#{updated_md}<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-END -->"
    )
  end

  def replace_updated_time(original_md)
    original_md.gsub(
      /<!-- RECENTLY-UPDATED-POSTS-UPDATED-START -->(.+)<!-- RECENTLY-UPDATED-POSTS-UPDATED-END -->/m,
      "<!-- RECENTLY-UPDATED-POSTS-UPDATED-START -->\n更新日時: #{ Time.now.strftime("%Y-%m-%d %H:%M") }\n<!-- RECENTLY-UPDATED-POSTS-UPDATED-END -->",
    )
  end

  def replace_liked_posts_md(original_md, updated_md)
    original_md.gsub(
      /<!-- RECENTLY-LIKED-POSTS-START -->(.+)<!-- RECENTLY-LIKED-POSTS-END -->/m,
      "<!-- RECENTLY-LIKED-POSTS-START -->#{updated_md}<!-- RECENTLY-LIKED-POSTS-END -->"
    )
  end

  def per_page
    @per_page ||= ENV["PER_PAGE"] || DEFAULT_PER_PAGE
  end
end
