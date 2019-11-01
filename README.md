# Buildkite builds spawner

Dumb script to spawn builds on [Buildkite](https://buildkite.com).

Run `bundle install`, then:

### 1. Spawn builds with:

```
BK_API_TOKEN=... bundle exec ruby spawner.rb \
  --number number_of_builds_to_spawn \
  --commit commit_full_sha \
  --branch branch_where_commit_is \
  --pipeline your_pipeline_name \
  --organization your_org_on_buildkite \
  --author name_to_show_on_buildkite \
  --email email_to_show_on_buildkite
```

### 2. Collect the results

```
BK_API_TOKEN=... bundle exec ruby results_collector.rb \
  --commit commit_full_sha \
  --number how_many_builds_where_spawend \ # this will soon be computed
  --pipeline your-pipeline \
  --organization your_org_on_buildkite
```

All the options other than the Buildkite token, `branch` and `commit` can be read in a local `spawner.yml` file.

```yml
organization: 'acme_inc'
pipeline: 'acme_app'
author: "Gios 🤖"
email: 'gio@acme.com'
```

You can define your `BK_API_TOKEN` in a `.env` file.

```
BK_API_TOKEN=<your_token>
```

**Do not check-in `.env` in your source control**, unless you want to expose the token to anyone with access to the repository.
