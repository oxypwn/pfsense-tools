namespace :pfsense do 
  desc "Add committers"
  task(:add_committers => :environment) do
    projslug = 'pfsense-import-test-minus-binaries'
    %w(mfuchs smos sdale aturetta ermal cmb sullrich simoncpu).each do |username|
      @committer = User.find_by_login(username)
      @repository = Project.find_by_slug(projslug).repositories.first
      if @repository.add_committer(@committer)
        @committership = @repository.committerships.find_by_user_id(@committer.id)
        @project.create_event(Action::ADD_COMMITTER, @committership, current_user)
        puts "Adding #{username} to project #{projslug}"
      else
        puts "#{username} already allowed to commit to #{projslug}"
      end
    end
  end
end

