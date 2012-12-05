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
    %w(mfuchs smos sdale aturetta ermal cmb sullrich simoncpu helder).each do |username|
      Rake::Task[ "pfsense:add_committer" ].execute( :projslug => args[:projslug], :committer => username )
    end
  end

  desc "Create project"
  task :create_project, :projslug, :projname, :needs => :environment do |task, args|
    puts "Creating project: #{args[:projslug]}"
    title = args[:projname]
    slug = String.new(args[:projslug])
    project = {
                :title => title,
                :slug => slug,
                :license => 'BSD License',
                :home_url => 'http://www.pfsense.org/',
                :description => 'Test import, please do not fork. Thanks'
              }
    p = Project.new(project)
    u = User.find_by_login('billm')
    p.user = u
    if p.save
      p.create_event(Action::CREATE_PROJECT, p, u)
    end
  end

  desc "Re-create project"
  task :recreate_project, :projname, :projslug, :needs => :environment do |task, args|
    puts "Recreating project: #{args[:projslug]}"
    project = Project.find_by_slug args[:projslug]
    project.destroy if !project.nil?
    Rake::Task[ "pfsense:create_project" ].execute( :projslug => args[:projslug], :projname => args[:projname] )
  end
end

