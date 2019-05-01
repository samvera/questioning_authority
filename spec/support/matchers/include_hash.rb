RSpec::Matchers.define :include_hash do |expected_hash|
  match do |actual_array|
    actual_array.any? { |a_hash| a_hash == expected_hash }
  end
end
