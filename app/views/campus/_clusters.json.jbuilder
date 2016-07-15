clusters.each do |k, v|
  json.set! k do
    json.extract! v, :name, :mapping
  end
end
