json.array!(@categories) do |category|
  json.extract! category, :id, :name, :cn_name
  json.url category_url(category, format: :json)
end
