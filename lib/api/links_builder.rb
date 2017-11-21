module Api
  class LinksBuilder
    def initialize(href, counts)
      @href = URI.parse(href)
      @counts = counts if counts
    end

    def links
      {
        :self     => self_href,
        :next     => next_href,
        :previous => previous_href,
        :first    => first_href,
        :last     => last_href
      }.compact
    end

    def pages
      (paging_count / limit.to_f).ceil
    end

    private

    attr_reader :href, :counts

    def self_href
      @self_href ||= format_href(offset)
    end

    def format_href(new_offset)
      result = href.dup
      new_params = query_params.reject { |q| q.start_with?("offset=") }
      new_params.unshift("offset=#{new_offset}")
      result.query = new_params.join("&")
      result.to_s
    end

    def paging_count
      @paging_count ||= counts.subquery_count || counts.count
    end

    def next_href
      next_offset = offset + limit
      return if next_offset >= paging_count
      format_href(next_offset)
    end

    def previous_href
      return if offset.zero?
      prev_offset = offset - limit
      return first_href if prev_offset < 0
      format_href(prev_offset)
    end

    def first_href
      format_href(0)
    end

    def last_href
      last_offset = paging_count - (paging_count % limit)
      format_href(last_offset)
    end

    def limit
      param = query_params.detect { |q| q.start_with?("limit=") }
      param ? param.split("=").last.to_i : Settings.api.max_results_per_page
    end

    def offset
      param = query_params.detect { |q| q.start_with?("offset=") }
      param ? param.split("=").last.to_i : 0
    end

    def query_params
      href.query.to_s.split("&")
    end
  end
end
