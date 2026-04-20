# frozen_string_literal: true

namespace :libremedia do
  desc "Sync blogs.pravda.com.ua text posts for Ayder (creates/updates Post records)"
  task sync_ayder_pravda: :environment do
    user = User.find_by!(email: "ayder@gmail.com")
    Rake::Task["libremedia:sync_pravda_author_blog"].invoke(user.id, "muzhdabaev")
  end

  desc "Sync blogs.pravda.com.ua articles for a user (args: user_id, author_slug, locale, category_slug)"
  task :sync_pravda_author_blog, %i[user_id author_slug locale category_slug] => :environment do |_t, args|
    user = User.find(args[:user_id])
    author_slug = args[:author_slug].presence or raise "author_slug argument is required"
    locale = args[:locale].presence || "uk"
    category_slug = args[:category_slug].presence

    sleep_between = (ENV["PRAVDA_SLEEP"] || "1.5").to_f
    max_articles = ENV["PRAVDA_MAX_ARTICLES"]&.to_i
    download_images = ENV["PRAVDA_DOWNLOAD_IMAGES"] != "0"

    progress_state = { line_length: 0 }
    render_progress = lambda do |payload|
      stats = payload[:stats] || {}
      total = payload[:total].to_i
      index = payload[:index].to_i
      percent = total.positive? ? ((index.to_f / total) * 100).round(1) : 0.0
      bar_width = 28
      filled = total.positive? ? ((index.to_f / total) * bar_width).round : 0
      filled = 0 if filled.negative?
      filled = bar_width if filled > bar_width
      bar = "#{"=" * filled}#{"-" * (bar_width - filled)}"
      line = "[#{bar}] #{index}/#{total} #{percent}% | created: #{stats[:created] || 0} updated: #{stats[:updated] || 0} skipped: #{stats[:skipped] || 0} errors: #{stats[:errors] || 0} | #{payload[:external_id]}"
      print "\r#{line}"
      if progress_state[:line_length] > line.length
        print(" " * (progress_state[:line_length] - line.length))
      end
      progress_state[:line_length] = line.length
      $stdout.flush
    end

    http = Pravda::HttpClient.new(sleep_between: sleep_between)
    result = Pravda::AuthorBlogImportService.new(
      user: user,
      author_slug: author_slug,
      locale: locale,
      category_slug: category_slug,
      max_articles: max_articles,
      download_images: download_images,
      http: http,
      progress: lambda do |event, payload|
        case event
        when :start
          puts "[Pravda] Start user=#{payload[:user_id]} author=#{payload[:author_slug]} locale=#{payload[:locale]} sleep=#{sleep_between}s images=#{download_images}"
        when :phase
          puts "[Pravda] Phase=#{payload[:name]}"
        when :discovered
          puts "[Pravda] Found #{payload[:total]} article URLs"
        when :progress
          render_progress.call(payload)
        when :skip
          print "\n"
          puts "[Pravda] SKIP url=#{payload[:url]} reason=#{payload[:reason]}"
        when :error
          print "\n"
          puts "[Pravda] ERROR url=#{payload[:url]} message=#{payload[:message]}"
        when :finish
          print "\n"
          puts "[Pravda] Finished: #{payload[:stats]}"
        end
      end
    ).call

    puts "Pravda sync completed for user=#{user.id} author=#{author_slug}: #{result}"
  end

  desc "Re-render `Post#content_i18n` from `content_source_i18n` (e.g. after a renderer change)"
  task :rerender_posts, %i[user_id] => :environment do |_t, args|
    scope = Post.with_discarded
    scope = scope.where(author_id: args[:user_id]) if args[:user_id].present?

    total = scope.count
    puts "[Pravda] Re-rendering #{total} posts"
    done = 0
    scope.find_each(batch_size: 100) do |post|
      post.send(:rerender_content_per_locale!)
      Post.where(id: post.id).update_all(content_i18n: post.content_i18n)
      done += 1
      print "\r[Pravda] re-rendered #{done}/#{total}"
      $stdout.flush
    end
    puts
  end
end
