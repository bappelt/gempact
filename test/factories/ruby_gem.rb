FactoryGirl.define do

  factory :ruby_gem do
    sequence(:name) {|n| "awesome_gem#{n}"}
    ranked_at Date.today
  end

end