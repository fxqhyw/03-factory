require_relative 'factory'
# basic usage example

Customer = Factory.new(:name, :address, :zip)

joe = Customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)

p joe.name
p joe['name']
p joe[:name]
p joe[0]

Customer2 = Factory.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end

p Customer2.new('Dave', '123 Main').greeting
