
namespace :bag do

  def each_bag(dir, &block)
    Dir.foreach(dir) do |fname|
      next if fname == '.' or fname == '..'
      bag = BagIt::Bag.new(File.join(dir, fname))
      block.call(bag)
    end
  end

  desc 'Import Bags from directory provided'
  task :import, [:bag_directory] => :environment do |t, args|
    each_bag(args[:bag_directory]) do |bag|
      puts "ingested: #{bag.bag_dir}"
      bag.manifest!
      bag.tagmanifest!
      Hybag.ingest(bag).review!
    end
  end

  desc 'Add hybag.yml files to bags'
  task :configure, [:bag_directory, :yaml] => :environment do |t, args|
    each_bag(args[:bag_directory]) do |bag|
      FileUtils::cp args[:yaml], bag.bag_dir
    end
  end

  desc 'Remove all bags from the directory; defaults to default write_bag location'
  task :cleanup, [:bag_directory] => :environment do |t, args|
    # TODO: don't hard code default bag path; get it from Hybag
    # GenericAsset.new.bag_path.split("/")[0...-1] ?
    args.with_defaults(:bag_directory => File.join('tmp', 'bags'))
    each_bag(args[:bag_directory]) do |bag|
      next if item == '.' or item == '..'
      FileUtils.rm_r(bag.bag_dir, :force => true)
    end
  end

end
