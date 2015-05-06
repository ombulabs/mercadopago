require "bundler/gem_tasks"

task :default => :test

task :test do
  require "./test/test_mercado_pago.rb"
end

task :console do
  require 'pry'
  require 'mercadopago'

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/mercadopago\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end
