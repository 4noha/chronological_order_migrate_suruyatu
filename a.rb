require 'systemu'

def iterate
  puts "Now: " + `git show -s --format=%H`
  #puts `bundle exec rake db:migrate`
  tmp = %q( bundle exec rake db:migrate )
  unless tmp[2]
    puts "Iterate error."
    init
    nil
  else
    puts tmp[1]
  end
end

def init
  puts "You can write settings."
  puts "Next, press Enter"
  gets
end

def migrate
  count = 0
  first = true
  commit_name = nil
  File.open("commit_log", "r+") do |f|
    f.each_line do |line|
      begin
        tmp = migrate_trial(line, commit_name, count)
        commit_name, count = tmp unless tmp.nil?
      end while !tmp
    end
  end
end

def migrate_trial(line, commit_name, count)
  if line.match("^db/migrate/") && !commit_name.nil?
    `git checkout #{commit_name}`
    commit_name = nil

    if first
      puts "Now first db migrate."
      first = false
      init
    end

    while !iterate
    end

    [commit_name, count]
  end
  if line.match("^commit [1234567890abcdef]*$")
    commit_name = line.split(" ")[1]
    count += 1
    puts "#{count} / #{COMMITS_COUNT}"
  end
  [commit_name, count]
rescue
  puts "Error."
  init
  nil
end

COMMITS_COUNT = `git log --oneline | wc -l`.to_i
`git log --name-only --reverse | grep -E "^commit [1234567890abcdef]*$|db/migrate/" > commit_log`
puts COMMITS_COUNT
migrate
