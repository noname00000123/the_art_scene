devlog:      tail -f log/unicorn.stdout.log log/unicorn.stderr.log log/sidekiq.log
# redis:       redis-server ./config/redis.conf
sidekiq:      bundle exec sidekiq
elastic:     ../elasticsearch-1.7.1/bin/elasticsearch
web:         bundle exec unicorn -c ./config/unicorn.rb --port $PORT
