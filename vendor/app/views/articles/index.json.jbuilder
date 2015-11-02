json.array!(@articles) do |article|
  json.extract! article, :id, :title, :keyword, :content, :source
  json.url article_url(article, format: :json)
end
