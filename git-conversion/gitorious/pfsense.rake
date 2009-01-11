namespace :pfsense do 
  desc "Add committer"
  task :add_committer, :projslug, :committer, :needs => :environment do |task, args|
    @committer = User.find_by_login(args[:committer])
    @repository = Project.find_by_slug(args[:projslug]).mainline_repository
    if @repository.add_committer(@committer)
      @committership = @repository.committerships.find_by_user_id(@committer.id)
      @project.create_event(Action::ADD_COMMITTER, @committership, current_user)
      puts "Adding #{args[:committer]} to project #{args[:projslug]}"
    else
      puts "#{args[:committer]} already allowed to commit to #{args[:projslug]}"
    end
  end

  desc "Add all committers"
  task :add_committers, :projslug, :needs => :environment do |task, args|
    projslug = 'pfsense-import-test-minus-binaries'
    args.with_defaults(:projslug => projslug)
    %w(mfuchs smos sdale aturetta ermal cmb sullrich simoncpu).each do |username|
      Rake::Task[ "pfsense:add_committer" ].execute( :projslug => args[:projslug], :committer => username )
    end
  end
end

