module Qa::Authorities
  # for use with Faraday; encode spaces as '%20' not '+'
  class AssignFast::SpaceFixEncoder
    delegate :decode, to: Faraday::NestedParamsEncoder

    def encode(hash)
      encoded = Faraday::NestedParamsEncoder.encode(hash)
      encoded.gsub('+', '%20')
    end
  end
end
