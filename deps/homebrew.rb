dep 'homebrew binary in place' do
  requires 'homebrew git repo'
  met? { which 'brew' }
  meet {
    cd var(:homebrew_prefix) do
      log_shell "Resetting to HEAD", "git reset --hard"
    end
  }
end

dep 'homebrew git repo' do
  requires_when_unmet 'writable.fhs', 'git'
  def prefix
    Babushka::BrewHelper.present? ? Babushka::BrewHelper.prefix : '/usr/local'
  end
  def repo
    Babushka::GitRepo.new prefix
  end
  met? {
    if repo.exists? && !repo.include?('ec2d785212af2c35b57f8c405b0855169d24dc0c')
      unmeetable "There is a non-homebrew repo at #{prefix}."
    else
      repo.exists?
    end
  }
  meet {
    git "git://github.com/mxcl/homebrew.git" do |path|
      log_shell "Gitifying #{prefix}", "cp -r .git '#{prefix}'"
    end
  }
end
