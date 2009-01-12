namespace :pfsense do 
  desc "Add committer"
  task :add_committer, :projslug, :committer, :needs => :environment do |task, args|
    @committer = User.find_by_login(args[:committer])
    @project = Project.find_by_slug(args[:projslug])
    @repository = @project.mainline_repository
    if @repository.add_committer(@committer)
      @committership = @repository.committerships.find_by_user_id(@committer.id)
      @project.create_event(Action::ADD_COMMITTER, @committership, User.find_by_login('billm'))
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

  desc "Create project"
  task :create_project => :environment do
    project = {
                :title => 'pfSense import test minus binaries',
                :slug => 'pfsense-import-test-minus-binaries',
                :license => 'BSD License',
                :home_url => 'http://www.pfsense.org/',
                :description => 'Test import, please do not fork. Thanks'
              }
    p = Project.new(project)
    u = User.find_by_login 'billm'
    p.user = u
    if p.save
      p.create_event(Action::CREATE_PROJECT, p, u)
    end
  end

  desc "Re-create project"
  task :recreate_project => :environment do
    project = Project.find_by_slug 'pfsense-import-test-minus-binaries'
    project.destroy if !project.nil?
    Rake::Task[ "pfsense:create_project" ].execute
  end
end

