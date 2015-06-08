# encoding: utf-8
namespace :rubocop do
  task run: :environment do
    `rubocop --auto-correct --format html --out rubocop.html`
    end

  task show: :environment do
    `rubocop --format html --out rubocop.html`
  end
end
