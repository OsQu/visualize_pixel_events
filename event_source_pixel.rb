require 'ostruct'

class EventSourcePixel
  class << self
    def find_by_product_catalog_id(api, product_catalog_id)
      external_event_sources = api.get_connections(
        product_catalog_id,
        :external_event_sources,
        fields: "id,name,source_type"
      )

      event_source =
        if external_event_sources.length > 1
          STDERR.puts "Multiple event sources found, enter index: "
          external_event_sources.each_with_index do |source, index|
            STDERR.puts "[#{index}] #{source.inspect}"
          end
          i = gets.to_i
          external_event_sources[i]
        else
          external_event_sources[0]
        end

      new(api, event_source["id"])
    end

    def find_by_product_set_id(api, product_set_id)
      product_set = api.get_object(product_set_id, fields: "product_catalog")
      self.find_by_product_catalog_id(api, product_set["product_catalog"]["id"])
    end
  end

  def initialize(api, id)
    @api = api
    @id = id
  end

  def data
    @data ||= begin
      @api.get_object(@id, fields: "name,last_fired_time")
    end
  end

  def stats(from: 7.days.ago, duration: 1.day)
    @api.get_connections(
      @id,
      "stats",
      aggregation: "event",
      start_time: from.iso8601,
      end_time: (from + duration).iso8601
    ).each_with_object({}) do |stat, memo|
      memo[stat["timestamp"]] = mangle_stat_line(stat)
    end
  end

  private

  def mangle_stat_line(stat)
    stat["data"].each_with_object({}) do |pixel_event, memo|
      memo[pixel_event["value"]] = pixel_event["count"]
    end
  end

end
