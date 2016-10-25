module Qa::Authorities
  # for use with Faraday; encode spaces as '%20' not '+'
  class AssignFast::SpaceFixEncoder
    def encode(hash)
      encoded = Faraday::NestedParamsEncoder.encode(hash)
      encoded.gsub('+', '%20')
    end

    def decode(str)
      Faraday::NestedParamsEncoder.decode(str)
    end
  end
end
