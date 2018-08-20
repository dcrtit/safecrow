require 'safecrow'

RSpec.describe Safecrow do

  it "has a version number" do
    expect(Safecrow::VERSION).not_to be nil
  end

  it "calculate commission" do
    {"price"=>123, "supplier_service_cost"=>4, "consumer_service_cost"=>0}
    expect(Safecrow.calculate(1500)['price']).to be 1500
  end
end
