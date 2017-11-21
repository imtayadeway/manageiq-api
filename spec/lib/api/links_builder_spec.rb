RSpec.describe Api::LinksBuilder do
  describe "#links" do
    it "returns self, first, next, and last links when it is the first page" do
      offsets = { "offset" => 0, "limit" => 2 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 7)
      links = link_builder.links
      expect(links.keys).to match_array([:self, :first, :next, :last])
      expect(links[:self]).to eq(create_href(offsets))
      expect(links[:next]).to eq(create_href("offset" => 2, "limit" => 2))
      expect(links[:last]).to eq(create_href("offset" => 6, "limit" => 2))
    end

    it "returns all of the links if it is a middle page" do
      offsets = { "offset" => 2, "limit" => 2 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 7)
      links = link_builder.links

      expect(links.keys).to match_array([:self, :next, :previous, :first, :last])
      expect(links[:self]).to eq(create_href(offsets))
      expect(links[:next]).to eq(create_href("offset" => 4, "limit" => 2))
      expect(links[:previous]).to eq(create_href("offset" => 0, "limit" => 2))
      expect(links[:first]).to eq(create_href("offset" => 0, "limit" => 2))
      expect(links[:last]).to eq(create_href("offset" => 6, "limit" => 2))
    end

    it "returns self, previous, first, last if it is the last page" do
      offsets = { "offset" => 3, "limit" => 2 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 3)
      links = link_builder.links
      expect(links.keys).to eq([:self, :previous, :first, :last])
      expect(links[:self]).to eq(create_href(offsets))
      expect(links[:previous]).to eq(create_href("offset" => 1, "limit" => 2))
      expect(links[:first]).to eq(create_href("offset" => 0, "limit" => 2))
      expect(links[:last]).to eq(create_href("offset" => 2, "limit" => 2))
    end

    it "always returns self, first, and last" do
      offsets = { "offset" => 0, "limit" => 3 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 3)
      links = link_builder.links

      expect(links.keys).to match_array([:self, :first, :last])
      expect(links[:self]).to eq(create_href(offsets))
    end

    it "previous link is equal to first link if previous offset would be 0" do
      offsets = { "offset" => 10, "limit" => 12 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 22)
      links = link_builder.links

      expect(links[:previous]).to eq(links[:first])
    end

    it "will construct a valid URI when there are no incoming query params" do
      builder = Api::LinksBuilder.new("http://example.com/api/features", 1)

      expected = {
        :first => "http://example.com/api/features?offset=0",
        :last  => "http://example.com/api/features?offset=0",
        :self  => "http://example.com/api/features?offset=0"
      }
      expect(builder.links).to match(expected)
    end
  end

  describe "#pages" do
    let(:offsets) { { "offset" => 0, "limit" => 2 } }

    it "returns correct page count when last page count is less than the limit" do
      link_builder = Api::LinksBuilder.new(create_href(offsets), 7)
      expect(link_builder.pages).to eq(4)
    end

    it "returns correct page count when there is only one page" do
      link_builder = Api::LinksBuilder.new(create_href(offsets), 2)
      expect(link_builder.pages).to eq(1)
    end

    it "returns correct page count when there are no subquery results" do
      link_builder = Api::LinksBuilder.new(create_href(offsets), 0)
      expect(link_builder.pages).to eq(0)
    end

    it "returns the correct page count when last page count is equal to the limit" do
      offsets = { "offset" => 0, "limit" => 3 }
      link_builder = Api::LinksBuilder.new(create_href(offsets), 6)
      expect(link_builder.pages).to eq(2)
    end
  end

  def create_href(offsets)
    "/api/vms?offset=#{offsets["offset"]}&limit=#{offsets["limit"]}"
  end
end
