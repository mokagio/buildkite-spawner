Run `bundle install`, then:

1. Spawn builds with:

```
BK_API_TOKEN=... bundle exec ruby spawner.rb \
  <pipeline> \
  <branch> \
  <commit_full_sha> \
  <number_of_builds_to_spawn> \
  <organization> \
  <author_name> \
  <author_email>
```

2. Collect the results

```
BK_API_TOKEN=... bundle exec ruby results_collector.rb \
  <pipeline> \
  <commit> \
  <total_builds> \
  <organization>
```