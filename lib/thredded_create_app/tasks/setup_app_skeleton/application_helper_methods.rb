def page_title
  [content_for(:page_title) || content_for(:thredded_page_title),
   t('brand.name')].compact.join(' - ')
end

# @param datetime [DateTime]
# @param default [String] a string to return if time is nil.
# @return [String] html_safe datetime presentation
def time_ago(datetime, default: '-')
  timeago_tag datetime,
              lang: I18n.locale.to_s.downcase,
              format: (lambda do |t, _opts|
                t.year == Time.current.year ? :short : :long
              end),
              nojs: true,
              date_only: false,
              default: default
end

# Override the default timeago_tag_content from rails-timeago
def timeago_tag_content(time, time_options = {})
  if time_options[:nojs] &&
     (time_options[:limit].nil? || time_options[:limit] < time)
    t 'common.time_ago', time: time_ago_in_words(time)
  else
    I18n.l time.to_date, format: time_options[:format]
  end
end
