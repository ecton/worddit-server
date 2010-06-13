namespace :database do
  desc "Update Views"
  task :update_views do |task, args|
    @entities.each{|e| e.refresh_design_doc}
  end
end