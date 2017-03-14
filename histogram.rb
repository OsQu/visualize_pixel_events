class Histogram
  def initialize(data)
    @data = data
    @buckets = @data.values.map(&:keys).flatten.uniq
  end

  def to_gnuplot_dat
    buffer = ""
    buffer << "# This file was created automatically by visualize_pixel_events\n"
    buffer << header
    buffer << data_rows

    buffer
  end

  private

  def header
    "time\t" + @buckets.join("\t") + "\n"
  end

  def data_rows
    rows = @data.map do |time, row|
      ([time] + assign_row_to_buckets(row)).join("\t")
    end

    rows.join("\n")
  end

  def assign_row_to_buckets(row)
    @buckets.map do |event|
      row[event] || 0
    end
  end
end
