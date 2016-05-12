require "esapad/version"

require "time"
require "esa"
require "denv"
require "pry"

Denv.load

class Esapad
  FETCH_PAGES = 1..1

  def initialize
    @client = Esa::Client.new(access_token: ENV["ESA_ACCESS_TOKEN"], current_team: ENV["ESA_TEAM"])
  end

  def update_pages_list(target_page_id)
    flow_updated_md = generate_updated_md("flow")
    stock_updated_md = generate_updated_md("stock")

    target_page = @client.post(ENV["ESA_TARGET_PAGE_ID"])
    target_page_md = target_page.body["body_md"]

    target_page_md = replace_pages_list_md(target_page_md, "flow", flow_updated_md)
    target_page_md = replace_pages_list_md(target_page_md, "stock", stock_updated_md)

    if target_page_md != target_page.body["body_md"]
      target_page_md = replace_updated_time(target_page_md)
      @client.update_post(target_page_id, body_md: target_page_md)
      puts "Updated: #{ target_page.body["url"] }"
    end
  end

  def fetch_updated_pages(kind)
    FETCH_PAGES.
      map {|page| @client.posts(q: "wip:false kind:#{kind} -body:RECENTLY-UPDATED-POSTS", page: page).body["posts"] }.
      flatten
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
    }.join("\n")
  end

  private

  def replace_pages_list_md(original_md, kind, updated_md)
    original_md.gsub(
      /<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-START -->(.+)<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-END -->/m,
      "<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-START -->\n#{updated_md}<!-- RECENTLY-UPDATED-#{kind.upcase}-POSTS-END -->"
    )
  end

  def replace_updated_time(original_md)
    original_md.gsub(
      /<!-- RECENTLY-UPDATED-POSTS-UPDATED-START -->(.+)<!-- RECENTLY-UPDATED-POSTS-UPDATED-END -->/m,
      "<!-- RECENTLY-UPDATED-POSTS-UPDATED-START -->\n更新日時: #{ Time.now.strftime("%Y-%m-%d %H:%M") }\n<!-- RECENTLY-UPDATED-POSTS-UPDATED-END -->",
    )
  end
end
